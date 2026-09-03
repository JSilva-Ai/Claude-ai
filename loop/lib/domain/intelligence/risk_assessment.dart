import 'loop_signals.dart';
import 'policy_ref.dart';

/// A coarse read on how likely a loop is to fail, for anywhere a number would
/// be false precision — a card colour, a sort bucket, a threshold in a policy
/// that only needs to know "is this bad".
///
/// Four values, not a continuum with three cut lines memorised by every
/// caller. The boundaries themselves live in [RiskPolicy.bands], versioned
/// like everything else here.
enum RiskBand { low, medium, high, critical }

/// A single, named contributor to a risk score.
///
/// This is the answer to "why is this at risk?", and it is required to be an
/// answer a machine can check: each reason names the [LoopRiskReason] it is,
/// how much it weighed, and — critically — nothing here is prose. A sentence
/// can be generated from this later, in whatever language the reader wants;
/// generating the *reason itself* would mean trusting a model's explanation of
/// a decision a deterministic policy actually made.
class RiskReasonEntry {
  const RiskReasonEntry({required this.reason, required this.weight});

  final LoopRiskReason reason;

  /// This reason's share of the score, before banding. Signed, so a reason
  /// that reduces risk — evidence is solid, nothing is pending — is
  /// expressible without inventing a second list for it.
  final double weight;

  @override
  String toString() =>
      'RiskReasonEntry(${reason.name}, ${weight.toStringAsFixed(2)})';
}

/// The reasons this phase's signals can actually support.
///
/// Restricted on purpose to what [LoopSignals] can supply: a reason with no
/// field behind it would be a claim the product cannot back up. Two the
/// architecture named are deliberately absent — `blocked` and
/// `missingDependency` describe a state this phase has no signal for (there is
/// no dependency graph yet), and `repeatedFailure` is expressed instead as
/// [LoopSignals.failedVerifications], which is the concrete thing the signal
/// actually observed.
enum LoopRiskReason {
  /// A known deadline is close or has passed.
  deadlineApproaching,

  /// The loop is `waiting` and has been for a while.
  waitingTooLong,

  /// The basis inference's own semantic confidence is low.
  lowConfidence,

  /// A `detected` proposal has sat unconfirmed for a while — evidence the
  /// engine itself is unsure this loop is real.
  staleProposal,

  /// The person rejected the reading this loop stands on. The strongest
  /// signal there is, and it should dominate whatever else is true.
  contradictedByUser,

  /// The provenance chain does not fully resolve. Not evidence that anything
  /// is wrong with the *loop* — evidence something may be wrong with the
  /// *store* — and named separately so the two are never confused downstream.
  evidenceUngrounded,

  /// A closure was checked and did not hold, one or more times.
  repeatedVerificationFailure,
}

/// A deterministic judgement of a loop's risk, produced from [LoopSignals] by
/// a versioned [RiskPolicy] — never persisted as truth on the [Loop] itself.
///
/// This is the type the architecture asked for directly: risk is an
/// *evaluation*, re-derivable at any moment from the loop's current signals,
/// and a stale [RiskAssessment] sitting in a cache is exactly that — stale
/// data, not a stale fact about the loop.
class RiskAssessment {
  const RiskAssessment({
    required this.score,
    required this.band,
    required this.reasons,
    required this.evaluatedAt,
    required this.policy,
  });

  /// 0..1. Internal — see [band] for what callers outside this policy should
  /// actually branch on.
  final double score;

  final RiskBand band;

  /// Never empty for a non-zero score: a risk with no reasons is a risk that
  /// cannot be explained, which this layer treats as a bug rather than a
  /// possible output.
  final List<RiskReasonEntry> reasons;

  final DateTime evaluatedAt;
  final PolicyRef policy;

  @override
  String toString() =>
      'RiskAssessment(${band.name}, ${score.toStringAsFixed(2)}, '
      '${reasons.length} reasons, $policy)';
}
