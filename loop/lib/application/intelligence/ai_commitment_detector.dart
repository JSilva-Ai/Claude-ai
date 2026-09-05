import 'dart:async';

import '../../domain/intelligence/ai/model_inference_metadata.dart';
import '../../domain/intelligence/ai/model_inference_request.dart';
import '../../domain/intelligence/ai/model_output_validator.dart';
import '../../domain/intelligence/ai/raw_model_commitment_output.dart';
import '../../domain/intelligence/commitment_candidate.dart';
import '../../domain/intelligence/policy_ref.dart';
import 'model_gateway.dart';

/// What calling [AICommitmentDetector.detect] produced.
///
/// Four shapes, mirroring [ModelValidationResult] plus the one failure mode
/// validation cannot see: the gateway itself never answered. This is the
/// type a caller — the fallback composer, the evaluation harness — actually
/// branches on; nothing here is ever unwrapped into a bare
/// `CommitmentCandidate?` before that branch happens, because "no candidate"
/// and "AI unavailable" require different responses (the first is a real
/// answer, the second means fall back to the rule baseline) and collapsing
/// them would lose exactly that distinction.
sealed class AIDetectionOutcome {
  const AIDetectionOutcome();
}

/// A validated candidate — semantically the same [CommitmentCandidate] type
/// [CommitmentCandidateDetector] produces, never a richer or looser shape
/// that would need its own comparison logic.
final class AIDetectionCandidate extends AIDetectionOutcome {
  const AIDetectionCandidate({required this.candidate, required this.metadata});

  final CommitmentCandidate candidate;
  final ModelInferenceMetadata metadata;
}

/// The model validated cleanly and reported nothing here — a real,
/// trustworthy answer, not a failure.
final class AIDetectionNoCandidate extends AIDetectionOutcome {
  const AIDetectionNoCandidate(this.metadata);

  final ModelInferenceMetadata metadata;
}

/// The model answered, but [ModelOutputValidator] refused it — a
/// hallucinated evidence id, an out-of-schema reason code, an unparseable
/// date. A finding about the model, not a transport failure; metadata is
/// still attached because a rejection is exactly the case an evaluation run
/// most wants to be able to attribute to a specific model and prompt
/// version.
final class AIDetectionRejected extends AIDetectionOutcome {
  const AIDetectionRejected({required this.reason, required this.metadata});

  final String reason;
  final ModelInferenceMetadata metadata;
}

/// The gateway itself did not produce a usable answer — timeout, rate
/// limit, provider failure, or anything else [ModelGatewayFailure] names.
/// This is the outcome that means "fall back to the rule baseline", not
/// "the model said no".
final class AIDetectionUnavailable extends AIDetectionOutcome {
  const AIDetectionUnavailable(this.reason);

  final ModelInferenceFailureReason reason;
}

/// The alternative inference engine alongside `CommitmentCandidateDetector`
/// — never a replacement authority for it.
///
/// Structurally this class can produce exactly one thing a caller can use as
/// domain input: an [AIDetectionCandidate] wrapping a [CommitmentCandidate].
/// It has no method that constructs a `Commitment`, a `Loop`, or a
/// `UserAssertion`, and nothing it returns can be mistaken for one — the
/// same "the type signature is the proof" discipline
/// `SourceIngestion`/`IngestionResult` already established in 3B for why
/// ingestion cannot manufacture a `Loop` either.
///
/// [timeout] bounds every call — a model is always slower than the
/// deterministic rules, and nothing here waits indefinitely for one. A
/// caller that needs LOOP to keep working while AI is unavailable calls
/// `CommitmentDetectionWithFallback` instead of this class directly.
class AICommitmentDetector {
  const AICommitmentDetector({
    required this.gateway,
    this.validator = const ModelOutputValidator(),
    this.timeout = const Duration(seconds: 20),
  });

  final ModelGateway gateway;
  final ModelOutputValidator validator;
  final Duration timeout;

  Future<AIDetectionOutcome> detect(ModelInferenceRequest request) async {
    final ModelGatewayResponse response;
    try {
      response = await gateway.infer(request).timeout(timeout);
    } on TimeoutException {
      return const AIDetectionUnavailable(ModelInferenceFailureReason.timeout);
    }

    return switch (response) {
      ModelGatewayFailure(:final reason) => AIDetectionUnavailable(reason),
      ModelGatewaySuccess(:final output, :final metadata) => _validated(
          output: output,
          metadata: metadata,
          request: request,
        ),
    };
  }

  AIDetectionOutcome _validated({
    required RawModelCommitmentOutput output,
    required ModelInferenceMetadata metadata,
    required ModelInferenceRequest request,
  }) {
    final ModelValidationResult result = validator.validate(
      output: output,
      request: request,
    );

    return switch (result) {
      ModelValidationNoCandidate() => AIDetectionNoCandidate(metadata),
      ModelValidationRejected(:final reason) => AIDetectionRejected(
          reason: reason,
          metadata: metadata,
        ),
      ModelValidationAccepted(
        :final claim,
        :final evidenceIds,
        :final reasons,
        :final confidence,
      ) =>
        AIDetectionCandidate(
          candidate: CommitmentCandidate.identifiedBy(
            evidence: evidenceIds,
            claim: claim,
            confidence: CandidateConfidence(confidence),
            reasons: reasons,
            producedBy: PolicyRef(
              id: 'ai-commitment-detection',
              version: PolicyVersion(metadata.promptVersion),
            ),
            evaluatedAt: request.referenceTime,
          ),
          metadata: metadata,
        ),
    };
  }
}
