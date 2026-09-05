import 'confidence.dart';

/// How two agreeing conclusions are combined.
///
/// An identifier rather than a function, so the formula itself can be replaced
/// and the change is visible in the data: every number records the rule that
/// produced it.
enum CombinationRuleId { maxPlusBonusV1 }

/// The thresholds and the combination rule, as configuration with a version.
///
/// These numbers are hypotheses about a product nobody has used yet, not
/// permanent truths, and treating them as constants is how a guess becomes
/// folklore. Versioning them means they can be re-tuned against real data
/// while every past decision stays explainable under the calibration in force
/// when it was made.
class ConfidenceCalibration {
  const ConfidenceCalibration({
    required this.version,
    required this.showThreshold,
    required this.autoOpenThreshold,
    required this.agreementBonus,
    required this.ceiling,
    required this.userConfirmFloor,
    required this.rule,
  });

  /// The starting point, and only that. Written down here so that changing it
  /// is a deliberate act with a new version rather than an edit nobody notices.
  static const ConfidenceCalibration v1 = ConfidenceCalibration(
    version: CalibrationVersion('conf-v1'),
    showThreshold: 0.40,
    autoOpenThreshold: 0.75,
    agreementBonus: 0.10,
    ceiling: 0.90,
    userConfirmFloor: 0.95,
    rule: CombinationRuleId.maxPlusBonusV1,
  );

  final CalibrationVersion version;

  /// Below this, an inference does not exist for the user at all. Noise shown
  /// once costs more trust than ten quiet successes recover.
  final double showThreshold;

  /// At or above this, a detection may open directly instead of asking.
  final double autoOpenThreshold;

  /// What a second, independent agreeing inference is worth.
  final double agreementBonus;

  /// No amount of agreement between machines reaches certainty.
  final double ceiling;

  /// What a person's confirmation guarantees.
  final double userConfirmFloor;

  final CombinationRuleId rule;
}

/// What the interface should do with an inference at a given confidence.
enum VisibilityDecision {
  /// Not shown. It may still be recorded — being uncertain is not the same as
  /// being deleted.
  hidden,

  /// Shown as a proposal that asks before becoming a commitment.
  needsConfirmation,

  /// Confident enough to open on its own.
  autoOpen,
}
