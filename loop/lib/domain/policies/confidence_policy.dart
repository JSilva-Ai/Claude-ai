import '../evidence/capture_integrity.dart';
import '../evidence/confidence.dart';
import '../evidence/confidence_calibration.dart';

/// The rules that turn confidence into behaviour.
///
/// Explicit composition, not Bayesian theatre. We cannot estimate independence
/// between two signals, so pretending to multiply probabilities would dress a
/// guess as mathematics. What we can do is state the rule, version it, and test
/// it — which is what this is.
class ConfidencePolicy {
  const ConfidencePolicy(this.calibration);

  final ConfidenceCalibration calibration;

  /// What the interface may do with an inference at this confidence.
  VisibilityDecision decide(Confidence confidence) {
    if (confidence.value < calibration.showThreshold) {
      return VisibilityDecision.hidden;
    }
    if (confidence.value >= calibration.autoOpenThreshold) {
      return VisibilityDecision.autoOpen;
    }
    return VisibilityDecision.needsConfirmation;
  }

  /// Two producers reaching the same conclusion.
  ///
  /// The stronger one, plus a fixed bonus, capped. Machines agreeing with each
  /// other never reaches certainty — only a person can do that.
  Confidence combineAgreeing(
    Confidence a,
    Confidence b, {
    required DateTime now,
  }) {
    final double stronger = a.value >= b.value ? a.value : b.value;
    final double combined = _clamp(stronger + calibration.agreementBonus);
    return Confidence(
      value: combined > calibration.ceiling ? calibration.ceiling : combined,
      basis: ConfidenceBasis.modelInference,
      method: a.value >= b.value ? a.method : b.method,
      under: calibration.version,
      computedAt: now,
    );
  }

  /// The person confirmed. A floor, not an overwrite: the inference that was
  /// confirmed keeps its own record, and this is the number that supersedes it.
  Confidence withUserConfirmation(Confidence c, {required DateTime now}) {
    return Confidence(
      value: c.value > calibration.userConfirmFloor
          ? c.value
          : calibration.userConfirmFloor,
      basis: ConfidenceBasis.userAsserted,
      method: c.method,
      under: calibration.version,
      computedAt: now,
    );
  }

  /// The person said no. Zero — and the original inference still exists, which
  /// is the whole point: a rejection is a label on a mistake, not its deletion.
  Confidence withUserRejection(Confidence c, {required DateTime now}) {
    return Confidence(
      value: 0,
      basis: ConfidenceBasis.userAsserted,
      method: c.method,
      under: calibration.version,
      computedAt: now,
    );
  }

  /// Semantic confidence may never exceed what the capture allows.
  ///
  /// The one line that ties the two axes together. Without it a model can be
  /// 0.95 certain about a sentence an OCR pass invented.
  Confidence capByIntegrity(
    Confidence semantic,
    Iterable<CaptureIntegrity> sources,
  ) {
    double ceiling = 1.0;
    for (final CaptureIntegrity integrity in sources) {
      if (integrity.confidenceCeiling < ceiling) {
        ceiling = integrity.confidenceCeiling;
      }
    }
    if (semantic.value <= ceiling) return semantic;
    return semantic.copyWith(value: ceiling);
  }

  static double _clamp(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);
}
