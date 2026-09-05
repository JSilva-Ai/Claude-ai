import '../../../domain/evidence/data_sensitivity.dart';
import '../../../domain/evidence/source_ref.dart';
import '../../../domain/ids.dart';
import '../../../domain/intelligence/ai/model_inference_request.dart';
import '../../../domain/intelligence/commitment_candidate.dart';
import '../../../domain/intelligence/commitment_candidate_policy.dart';
import '../../../domain/intelligence/ports/source_signal.dart';
import '../ai_commitment_detector.dart';

/// One curated input, run through both detectors identically.
///
/// [expectedHasCandidate] is optional — a gold label where the corpus author
/// is confident of the right answer, absent where a case exists to observe
/// disagreement rather than to grade it. Nothing here invents a gold label
/// that was not deliberately set.
class CommitmentEvaluationCase {
  const CommitmentEvaluationCase({
    required this.name,
    required this.text,
    required this.sourceKind,
    required this.evidence,
    required this.referenceTime,
    this.locale = 'en',
    this.expectedHasCandidate,
  });

  final String name;
  final String text;
  final EvidenceSource sourceKind;
  final List<EvidenceId> evidence;
  final DateTime referenceTime;
  final String locale;

  /// Null when this case exists to observe behaviour, not to grade it.
  final bool? expectedHasCandidate;
}

/// The two detectors' answers to one case, side by side.
///
/// This is architectural groundwork, not a quality claim: [agree] compares
/// only whether a candidate exists and, when both do, whether their claim
/// kind matches — a real precision/recall study needs a corpus far larger
/// than the handful of representative cases this phase curates, and the
/// brief is explicit that a tiny corpus must never be read as statistically
/// significant.
class CommitmentEvaluationResult {
  const CommitmentEvaluationResult({
    required this.caseName,
    required this.ruleCandidate,
    required this.aiOutcome,
  });

  final String caseName;
  final CommitmentCandidate? ruleCandidate;
  final AIDetectionOutcome aiOutcome;

  CommitmentCandidate? get aiCandidate => switch (aiOutcome) {
        AIDetectionCandidate(:final candidate) => candidate,
        _ => null,
      };

  /// True when both detectors agree there is no candidate, or both produced
  /// one with the same [Claim.kind]. False whenever they disagree on
  /// presence or on direction — a finding for a human to read, never
  /// something this class resolves on its own; see the brief's explicit
  /// instruction that disagreement is not automatic authority for either
  /// side.
  bool get agree {
    final CommitmentCandidate? ai = aiCandidate;
    if (ruleCandidate == null && ai == null) return true;
    if (ruleCandidate == null || ai == null) return false;
    return ruleCandidate!.claim.kind == ai.claim.kind;
  }
}

/// Runs the same curated Evidence cases through
/// `CommitmentCandidateDetector` and [AICommitmentDetector] and reports both
/// answers side by side.
///
/// This class computes no precision/recall/F1 statistics — see
/// [CommitmentEvaluationResult.agree]'s own doc for why a small, curated
/// corpus must not be dressed up as a statistically meaningful benchmark.
/// What it gives a caller is the raw comparison data a human, or a larger
/// offline evaluation run, can build real metrics from later.
class CommitmentEvaluationHarness {
  const CommitmentEvaluationHarness({
    required this.ai,
    this.rules = const CommitmentCandidateDetector(),
  });

  final AICommitmentDetector ai;
  final CommitmentCandidateDetector rules;

  Future<List<CommitmentEvaluationResult>> run(
    List<CommitmentEvaluationCase> cases,
  ) async {
    final List<CommitmentEvaluationResult> results =
        <CommitmentEvaluationResult>[];
    for (final CommitmentEvaluationCase c in cases) {
      final CommitmentCandidate? ruleCandidate = rules.detect(
        signal: SourceSignal(text: c.text, sensitivity: _ordinary),
        sourceKind: c.sourceKind,
        evidence: c.evidence,
        referenceTime: c.referenceTime,
      );

      final AIDetectionOutcome aiOutcome = await ai.detect(
        ModelInferenceRequest(
          kind: ModelInferenceKind.commitmentDetection,
          evidence: <ModelEvidenceView>[
            for (final EvidenceId id in c.evidence)
              ModelEvidenceView(id: id, text: c.text, sourceKind: c.sourceKind),
          ],
          locale: c.locale,
          referenceTime: c.referenceTime,
        ),
      );

      results.add(
        CommitmentEvaluationResult(
          caseName: c.name,
          ruleCandidate: ruleCandidate,
          aiOutcome: aiOutcome,
        ),
      );
    }
    return results;
  }
}

const DataSensitivity _ordinary = DataSensitivity.ordinary;
