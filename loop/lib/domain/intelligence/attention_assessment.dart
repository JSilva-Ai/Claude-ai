import 'loop_signals.dart';
import 'policy_ref.dart';

/// How much a loop deserves the user's attention *right now* — distinct from
/// [RiskAssessment], which asks how likely it is to go wrong.
///
/// The architecture is explicit that these must not collapse into one number:
/// a loop can be high risk and low immediate attention (badly overdue, but the
/// only next step is a reminder that already fired an hour ago — nothing new
/// to look at) or low risk and high attention (due in ten minutes, but
/// perfectly on track). A single score cannot hold both facts; two can.
enum AttentionBand { low, medium, high }

/// A single, named contributor to an attention score. Same shape as
/// [RiskReasonEntry] for the same reason: a number with no name behind it is
/// not an explanation.
class AttentionReasonEntry {
  const AttentionReasonEntry({required this.reason, required this.weight});

  final LoopAttentionReason reason;
  final double weight;

  @override
  String toString() =>
      'AttentionReasonEntry(${reason.name}, ${weight.toStringAsFixed(2)})';
}

/// What this phase can actually detect as worth surfacing.
enum LoopAttentionReason {
  /// A deadline is imminent — closer than risk's own "approaching" window.
  deadlineImminent,

  /// The engine is not sure this is even a real loop; the person has not said.
  awaitingConfirmation,

  /// A closure could not be verified and the loop is back with the user.
  actionFailed,

  /// The user pinned it. The one purely manual signal, and it always wins.
  userPinned,
}

/// A deterministic judgement of how much a loop merits surfacing now.
///
/// Like [RiskAssessment], never persisted as truth — re-derived from
/// [LoopSignals] by a versioned policy.
class AttentionAssessment {
  const AttentionAssessment({
    required this.score,
    required this.band,
    required this.reasons,
    required this.evaluatedAt,
    required this.policy,
  });

  final double score;
  final AttentionBand band;
  final List<AttentionReasonEntry> reasons;
  final DateTime evaluatedAt;
  final PolicyRef policy;

  @override
  String toString() =>
      'AttentionAssessment(${band.name}, ${score.toStringAsFixed(2)}, '
      '${reasons.length} reasons, $policy)';
}
