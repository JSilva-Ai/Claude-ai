import '../loop/loop_state.dart';
import 'attention_assessment.dart';
import 'loop_signals.dart';
import 'policy_ref.dart';

/// Turns [LoopSignals] into an [AttentionAssessment].
///
/// Deliberately thin next to [RiskPolicy]: 2A's signals support four honest
/// attention reasons and no more. A fifth — "the user is likely free right
/// now", say — needs a context signal ([ContextIntelligence]'s job, and that
/// port is a contract with no implementation this phase) or a friction signal
/// (also not yet computable; see `FrictionAssessment`'s doc comment). Padding
/// the list with reasons the signals cannot back would be exactly the
/// fabrication the brief prohibits.
class AttentionPolicy {
  const AttentionPolicy(this.version, {required this.weights});

  static const AttentionPolicy v1 = AttentionPolicy(
    PolicyVersion('attention-v1'),
    weights: AttentionWeights(),
  );

  final PolicyVersion version;
  final AttentionWeights weights;

  AttentionAssessment evaluate(LoopSignals signals) {
    final List<AttentionReasonEntry> reasons = <AttentionReasonEntry>[];

    final Duration? left = signals.timeUntilDeadline;
    if (left != null && !left.isNegative && left <= weights.imminentWindow) {
      reasons.add(
        AttentionReasonEntry(
          reason: LoopAttentionReason.deadlineImminent,
          weight: weights.deadlineImminent,
        ),
      );
    }

    if (signals.state == LoopState.detected) {
      reasons.add(
        AttentionReasonEntry(
          reason: LoopAttentionReason.awaitingConfirmation,
          weight: weights.awaitingConfirmation,
        ),
      );
    }

    if (signals.failedVerifications > 0) {
      reasons.add(
        AttentionReasonEntry(
          reason: LoopAttentionReason.actionFailed,
          weight: weights.actionFailed,
        ),
      );
    }

    if (signals.isPinned) {
      reasons.add(
        AttentionReasonEntry(
          reason: LoopAttentionReason.userPinned,
          weight: weights.userPinned,
        ),
      );
    }

    final double raw = reasons.fold(
      0.0,
      (double sum, AttentionReasonEntry r) => sum + r.weight,
    );
    // Suppression overrides every signal: the person asked not to see this,
    // which is a stronger statement than any reason above can produce.
    final double score = signals.isSuppressed ? 0.0 : raw.clamp(0.0, 1.0);

    return AttentionAssessment(
      score: score,
      band: weights.bandOf(score),
      reasons: reasons,
      evaluatedAt: signals.now,
      policy: PolicyRef(id: 'attention', version: version),
    );
  }
}

class AttentionWeights {
  const AttentionWeights({
    this.deadlineImminent = 0.60,
    this.imminentWindow = const Duration(hours: 4),
    this.awaitingConfirmation = 0.30,
    this.actionFailed = 0.50,
    this.userPinned = 0.70,
    this.mediumAt = 0.30,
    this.highAt = 0.60,
  });

  final double deadlineImminent;
  final Duration imminentWindow;
  final double awaitingConfirmation;
  final double actionFailed;
  final double userPinned;

  final double mediumAt;
  final double highAt;

  AttentionBand bandOf(double score) {
    if (score >= highAt) return AttentionBand.high;
    if (score >= mediumAt) return AttentionBand.medium;
    return AttentionBand.low;
  }
}
