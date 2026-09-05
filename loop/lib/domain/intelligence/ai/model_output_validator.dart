import '../../evidence/claim.dart';
import '../../evidence/source_ref.dart';
import '../../ids.dart';
import '../commitment_candidate.dart';
import 'model_inference_request.dart';
import 'raw_model_commitment_output.dart';

/// What validating a [RawModelCommitmentOutput] decided.
///
/// Three shapes, not two: "the model said nothing was here" and "the model
/// said something was here but it does not check out" are different facts,
/// and collapsing them into one null would throw away exactly the
/// distinction a future evaluation run needs — a rejected output is a
/// finding about the model, an honest no-candidate is not.
sealed class ModelValidationResult {
  const ModelValidationResult();
}

/// The model reported no commitment — accepted at face value; there is
/// nothing here to hallucinate about a *negative* answer.
final class ModelValidationNoCandidate extends ModelValidationResult {
  const ModelValidationNoCandidate();
}

/// The output failed validation and must not become a candidate. [reason]
/// is for logs and tests, the same discipline `LoopFailure.debugMessage`
/// already holds domain refusals to — never surfaced to a user.
final class ModelValidationRejected extends ModelValidationResult {
  const ModelValidationRejected(this.reason);
  final String reason;
}

/// Everything needed to build a [CommitmentCandidate], already checked
/// against the request it answers.
final class ModelValidationAccepted extends ModelValidationResult {
  const ModelValidationAccepted({
    required this.claim,
    required this.evidenceIds,
    required this.reasons,
    required this.confidence,
  });

  final Claim claim;
  final List<EvidenceId> evidenceIds;
  final List<CommitmentSignalReason> reasons;
  final double confidence;
}

/// The one gate every model answer passes through before it can become a
/// [CommitmentCandidate].
///
/// This is where the brief's hallucination and prompt-injection defenses
/// actually live, mechanically rather than by convention: an evidence id the
/// request never offered, a reason code or claim kind outside the closed
/// sets [CommitmentSignalReason]/[ClaimKind] already define, an
/// out-of-bounds confidence, or an unparseable date each fail the whole
/// output closed. There is no partial-trust path — a `RawModelCommitmentOutput`
/// either validates completely or produces nothing a caller can use as a
/// candidate at all, and nothing here ever falls back to guessing at what
/// the model "probably meant".
///
/// Authorship receives its own, unconditional rule, independent of anything
/// the model claims: a confident direction (`oweDeliverable` /
/// `awaitingResponse`) is only ever honoured when every piece of evidence
/// the candidate cites is [EvidenceSource.manual] — the same rule
/// `CommitmentCandidateDetector` applies to the deterministic path, for the
/// same reason (`EvidenceSource` still cannot distinguish sent from
/// received). A model insisting otherwise is not trusted; the claim is
/// downgraded to [ClaimKind.other] and [CommitmentSignalReason.ambiguousActor]
/// is added, exactly as if the rule-based detector had produced it.
class ModelOutputValidator {
  const ModelOutputValidator();

  ModelValidationResult validate({
    required RawModelCommitmentOutput output,
    required ModelInferenceRequest request,
  }) {
    if (!output.hasCandidate) return const ModelValidationNoCandidate();

    final double? confidence = output.confidence;
    if (output.claimKind == null || confidence == null) {
      return const ModelValidationRejected(
        'a candidate requires both claimKind and confidence',
      );
    }
    if (confidence.isNaN || confidence < 0 || confidence > 1) {
      return ModelValidationRejected('confidence out of bounds: $confidence');
    }

    final ClaimKind? kind = _claimKindByName(output.claimKind!);
    if (kind == null) {
      return ModelValidationRejected('unknown claim kind: ${output.claimKind}');
    }

    if (output.evidenceIds.isEmpty) {
      return const ModelValidationRejected(
        'a candidate must reference at least one evidence id from the request',
      );
    }
    final Map<String, ModelEvidenceView> byId = <String, ModelEvidenceView>{
      for (final ModelEvidenceView v in request.evidence) v.id.value: v,
    };
    final List<EvidenceId> evidenceIds = <EvidenceId>[];
    for (final String rawId in output.evidenceIds) {
      final ModelEvidenceView? view = byId[rawId];
      if (view == null) {
        // Hallucination containment: an id the request never offered is
        // refused outright, never silently dropped from the list.
        return ModelValidationRejected(
          'evidence id not present in the request: $rawId',
        );
      }
      evidenceIds.add(view.id);
    }

    final List<CommitmentSignalReason> reasons = <CommitmentSignalReason>[];
    for (final String code in output.reasonCodes) {
      final CommitmentSignalReason? reason = _reasonByName(code);
      if (reason == null) {
        return ModelValidationRejected('unknown reason code: $code');
      }
      reasons.add(reason);
    }

    DateTime? deadline;
    if (output.deadlineIso != null) {
      deadline = DateTime.tryParse(output.deadlineIso!);
      if (deadline == null) {
        return ModelValidationRejected(
          'unparseable deadline: ${output.deadlineIso}',
        );
      }
    }

    final bool confidentDirection =
        kind == ClaimKind.oweDeliverable || kind == ClaimKind.awaitingResponse;
    final bool everyCitedItemIsManual = evidenceIds
        .map((EvidenceId id) => byId[id.value]!.sourceKind)
        .every((EvidenceSource s) => s == EvidenceSource.manual);

    final ClaimKind resolvedKind;
    if (confidentDirection && !everyCitedItemIsManual) {
      // The model asserted a direction Evidence cannot support. Never
      // trusted at face value — downgraded exactly as the deterministic
      // detector would have produced it itself.
      resolvedKind = ClaimKind.other;
      if (!reasons.contains(CommitmentSignalReason.ambiguousActor)) {
        reasons.add(CommitmentSignalReason.ambiguousActor);
      }
    } else {
      resolvedKind = kind;
    }

    return ModelValidationAccepted(
      claim: Claim(
        kind: resolvedKind,
        by: deadline,
        sourceQuote: output.sourceQuote,
      ),
      evidenceIds: evidenceIds,
      reasons: reasons,
      confidence: confidence,
    );
  }

  ClaimKind? _claimKindByName(String name) {
    for (final ClaimKind k in ClaimKind.values) {
      if (k.name == name) return k;
    }
    return null;
  }

  CommitmentSignalReason? _reasonByName(String name) {
    for (final CommitmentSignalReason r in CommitmentSignalReason.values) {
      if (r.name == name) return r;
    }
    return null;
  }
}
