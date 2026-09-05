import '../../domain/evidence/source_ref.dart';
import '../../domain/ids.dart';
import '../../domain/intelligence/ai/model_inference_request.dart';
import '../../domain/intelligence/commitment_candidate.dart';
import '../../domain/intelligence/commitment_candidate_policy.dart';
import '../../domain/intelligence/ports/source_signal.dart';
import 'ai_commitment_detector.dart';

/// Which detector actually produced a [CommitmentDetectionOutcome] —
/// evaluation-relevant metadata, never anything a caller needs to branch
/// product behaviour on.
enum CommitmentDetectionSource { rules, ai }

/// A candidate together with which engine produced it — what
/// [CommitmentDetectionWithFallback] actually returns, so a caller (or a
/// test) can see that AI unavailability was handled without having to
/// re-derive it from the absence of AI-specific fields.
class CommitmentDetectionOutcome {
  const CommitmentDetectionOutcome({
    required this.candidate,
    required this.source,
  });

  final CommitmentCandidate? candidate;
  final CommitmentDetectionSource source;
}

/// One routing policy among several the seam could support later — this is
/// the only one 3D implements, deliberately: try AI, and whenever it does
/// not produce a usable answer, fall back to the deterministic baseline
/// rather than leaving LOOP unable to reason at all.
///
/// `RULES ONLY`, `AI ONLY` and `AI ONLY WHEN UNCERTAIN` are real, named
/// alternatives the brief asks this architecture to leave room for — not
/// implemented here, because a router choosing between four strategies is
/// exactly the complexity 3D was told not to build prematurely. What this
/// class proves is the one behaviour that is not optional: existing LOOP
/// functionality must not depend on a model being reachable.
///
/// [AIDetectionRejected] also falls back to rules, on purpose: a validated
/// rejection means the model's answer failed containment (a hallucinated
/// evidence id, an out-of-schema value), which is a reason to distrust that
/// specific answer, not a reason to leave the caller with nothing.
class CommitmentDetectionWithFallback {
  const CommitmentDetectionWithFallback({
    required this.ai,
    this.rules = const CommitmentCandidateDetector(),
  });

  final AICommitmentDetector ai;
  final CommitmentCandidateDetector rules;

  Future<CommitmentDetectionOutcome> detect({
    required SourceSignal signal,
    required EvidenceSource sourceKind,
    required List<EvidenceId> evidence,
    required DateTime referenceTime,
    required String locale,
  }) async {
    final AIDetectionOutcome aiOutcome = await ai.detect(
      ModelInferenceRequest(
        kind: ModelInferenceKind.commitmentDetection,
        evidence: <ModelEvidenceView>[
          for (final EvidenceId id in evidence)
            ModelEvidenceView(
              id: id,
              text: signal.text,
              sourceKind: sourceKind,
            ),
        ],
        locale: locale,
        referenceTime: referenceTime,
      ),
    );

    return switch (aiOutcome) {
      AIDetectionCandidate(:final candidate) => CommitmentDetectionOutcome(
          candidate: candidate,
          source: CommitmentDetectionSource.ai,
        ),
      AIDetectionNoCandidate() => const CommitmentDetectionOutcome(
          candidate: null,
          source: CommitmentDetectionSource.ai,
        ),
      AIDetectionRejected() || AIDetectionUnavailable() => _ruleFallback(
          signal: signal,
          sourceKind: sourceKind,
          evidence: evidence,
          referenceTime: referenceTime,
        ),
    };
  }

  CommitmentDetectionOutcome _ruleFallback({
    required SourceSignal signal,
    required EvidenceSource sourceKind,
    required List<EvidenceId> evidence,
    required DateTime referenceTime,
  }) =>
      CommitmentDetectionOutcome(
        candidate: rules.detect(
          signal: signal,
          sourceKind: sourceKind,
          evidence: evidence,
          referenceTime: referenceTime,
        ),
        source: CommitmentDetectionSource.rules,
      );
}
