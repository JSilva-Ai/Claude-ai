import 'loop_signals.dart';
import 'policy_ref.dart';
import 'risk_assessment.dart';

/// The thresholds and weights that turn signals into a [RiskAssessment].
///
/// Every number here is a hypothesis about a product nobody has used yet, in
/// the same spirit as `ConfidenceCalibration` in 2A: versioned rather than
/// constant, so re-tuning against real data later does not quietly invalidate
/// an assessment already shown to someone. [RiskPolicy.v1] is the starting
/// point, not a truth.
class RiskPolicy {
  const RiskPolicy(this.version, {required this.bands, required this.weights});

  static const RiskPolicy v1 = RiskPolicy(
    PolicyVersion('risk-v1'),
    bands: RiskBands(low: 0.25, medium: 0.50, high: 0.75),
    weights: RiskWeights(),
  );

  final PolicyVersion version;
  final RiskBands bands;
  final RiskWeights weights;

  RiskAssessment evaluate(LoopSignals signals) {
    final List<RiskReasonEntry> reasons = <RiskReasonEntry>[];

    if (signals.isOverdue) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.deadlineApproaching,
          weight: weights.overdue,
        ),
      );
    } else {
      final Duration? left = signals.timeUntilDeadline;
      if (left != null && left <= weights.approachingWindow) {
        reasons.add(
          RiskReasonEntry(
            reason: LoopRiskReason.deadlineApproaching,
            weight: weights.approaching,
          ),
        );
      }
    }

    final Duration? waiting = signals.waitingFor;
    if (waiting != null && waiting >= weights.longWait) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.waitingTooLong,
          weight: weights.waitingTooLong,
        ),
      );
    }

    final double? confidence = signals.basisConfidence?.value;
    if (confidence != null && confidence < weights.lowConfidenceBelow) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.lowConfidence,
          weight: weights.lowConfidence,
        ),
      );
    }

    final Duration? proposalAge = signals.proposalAge;
    if (proposalAge != null && proposalAge >= weights.staleProposalAfter) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.staleProposal,
          weight: weights.staleProposal,
        ),
      );
    }

    if (signals.contradictedByUser) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.contradictedByUser,
          weight: weights.contradicted,
        ),
      );
    }

    if (signals.evidenceUngrounded) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.evidenceUngrounded,
          weight: weights.ungrounded,
        ),
      );
    }

    if (signals.failedVerifications > 0) {
      reasons.add(
        RiskReasonEntry(
          reason: LoopRiskReason.repeatedVerificationFailure,
          weight: (weights.perFailedVerification * signals.failedVerifications)
              .clamp(0.0, weights.failedVerificationCeiling),
        ),
      );
    }

    final double raw = reasons.fold(
      0.0,
      (double sum, RiskReasonEntry r) => sum + r.weight,
    );
    final double score = raw.clamp(0.0, 1.0);

    return RiskAssessment(
      score: score,
      band: bands.of(score),
      reasons: reasons,
      evaluatedAt: signals.now,
      policy: PolicyRef(id: 'risk', version: version),
    );
  }
}

/// The score cut points, named so a caller reads `bands.of(score)` rather than
/// three inline comparisons repeated at every call site.
class RiskBands {
  const RiskBands({
    required this.low,
    required this.medium,
    required this.high,
  });

  /// Below this: [RiskBand.low]. At or above [high]: [RiskBand.critical].
  final double low;
  final double medium;
  final double high;

  RiskBand of(double score) {
    if (score >= high) return RiskBand.critical;
    if (score >= medium) return RiskBand.high;
    if (score >= low) return RiskBand.medium;
    return RiskBand.low;
  }
}

/// How much each reason contributes, and the thresholds that decide whether it
/// applies at all.
///
/// A flat class of named doubles rather than a map: every weight is visible at
/// the definition site, and a typo in a string key cannot silently produce a
/// weight of zero.
class RiskWeights {
  const RiskWeights({
    this.overdue = 0.55,
    this.approaching = 0.30,
    this.approachingWindow = const Duration(hours: 24),
    this.waitingTooLong = 0.25,
    this.longWait = const Duration(days: 3),
    this.lowConfidence = 0.20,
    this.lowConfidenceBelow = 0.5,
    this.staleProposal = 0.15,
    this.staleProposalAfter = const Duration(days: 7),
    this.contradicted = 0.90,
    this.ungrounded = 0.35,
    this.perFailedVerification = 0.20,
    this.failedVerificationCeiling = 0.40,
  });

  final double overdue;
  final double approaching;
  final Duration approachingWindow;

  final double waitingTooLong;
  final Duration longWait;

  final double lowConfidence;
  final double lowConfidenceBelow;

  final double staleProposal;
  final Duration staleProposalAfter;

  final double contradicted;
  final double ungrounded;

  final double perFailedVerification;
  final double failedVerificationCeiling;
}
