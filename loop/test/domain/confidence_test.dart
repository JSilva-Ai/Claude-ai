import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/evidence/capture_integrity.dart';
import 'package:loop/domain/evidence/confidence.dart';
import 'package:loop/domain/evidence/confidence_calibration.dart';
import 'package:loop/domain/policies/confidence_policy.dart';

import 'fixtures.dart';

/// A second calibration, existing only in this test — which is the point: the
/// thresholds are configuration, so a different set is expressible without
/// touching the policy that applies them.
const ConfidenceCalibration cautious = ConfidenceCalibration(
  version: CalibrationVersion('conf-test-cautious'),
  showThreshold: 0.60,
  autoOpenThreshold: 0.90,
  agreementBonus: 0.05,
  ceiling: 0.92,
  userConfirmFloor: 0.99,
  rule: CombinationRuleId.maxPlusBonusV1,
);

void main() {
  const ConfidencePolicy v1 = ConfidencePolicy(ConfidenceCalibration.v1);

  double capped(Confidence c, List<CaptureIntegrity> sources) =>
      v1.capByIntegrity(c, sources).value;

  group('a confidence is a number with a provenance', () {
    test('it refuses to exist outside 0..1', () {
      expect(() => confidence(1.2), throwsA(isA<ArgumentError>()));
      expect(() => confidence(-0.1), throwsA(isA<ArgumentError>()));
      expect(() => confidence(double.nan), throwsA(isA<ArgumentError>()));
    });

    test('it records which calibration produced it', () {
      expect(confidence(0.5).under, const CalibrationVersion('conf-v1'));
    });

    test('it records which producer produced it', () {
      expect(confidence(0.5).method.toString(), 'rule:promise-verb@v3');
    });
  });

  group('conf-v1 golden table', () {
    // These numbers are a hypothesis about a product nobody has used yet. The
    // table exists so changing them is a deliberate act with a new version,
    // rather than an edit nobody notices.
    const List<(double, VisibilityDecision)> golden =
        <(double, VisibilityDecision)>[
      (0.00, VisibilityDecision.hidden),
      (0.39, VisibilityDecision.hidden),
      (0.40, VisibilityDecision.needsConfirmation),
      (0.74, VisibilityDecision.needsConfirmation),
      (0.75, VisibilityDecision.autoOpen),
      (1.00, VisibilityDecision.autoOpen),
    ];

    for (final (double value, VisibilityDecision expected) in golden) {
      test('$value → ${expected.name}', () {
        expect(v1.decide(confidence(value)), expected);
      });
    }
  });

  group('calibration is versioned, not constant', () {
    test('another calibration decides differently on the same number', () {
      const ConfidencePolicy careful = ConfidencePolicy(cautious);
      final Confidence c = confidence(0.5);

      expect(v1.decide(c), VisibilityDecision.needsConfirmation);
      expect(careful.decide(c), VisibilityDecision.hidden);
    });

    test('numbers produced under an old calibration keep their version', () {
      // Recalibrating must not rewrite history: a decision made in March stays
      // explainable under March's calibration.
      const ConfidencePolicy careful = ConfidencePolicy(cautious);
      final Confidence old = confidence(0.8);
      final Confidence fresh = careful.withUserConfirmation(old, now: t0);

      expect(old.under, const CalibrationVersion('conf-v1'));
      expect(fresh.under, const CalibrationVersion('conf-test-cautious'));
      expect(fresh.value, 0.99, reason: "the cautious calibration's floor");
    });
  });

  group('composition', () {
    test('two agreeing producers beat either alone, but never reach certainty',
        () {
      final Confidence combined = v1.combineAgreeing(
        confidence(0.6),
        confidence(0.7),
        now: t0,
      );

      expect(combined.value, closeTo(0.80, 1e-9));

      final Confidence high = v1.combineAgreeing(
        confidence(0.89),
        confidence(0.88),
        now: t0,
      );
      expect(high.value, ConfidenceCalibration.v1.ceiling);
      expect(
        high.value,
        lessThan(1.0),
        reason: 'machines agreeing is not proof',
      );
    });

    test('a person confirming sets a floor and does not lower a higher number',
        () {
      expect(v1.withUserConfirmation(confidence(0.5), now: t0).value, 0.95);
      expect(v1.withUserConfirmation(confidence(0.98), now: t0).value, 0.98);
      expect(
        v1.withUserConfirmation(confidence(0.5), now: t0).basis,
        ConfidenceBasis.userAsserted,
      );
    });

    test('a person rejecting zeroes it', () {
      expect(v1.withUserRejection(confidence(0.9), now: t0).value, 0);
    });
  });

  group('capture integrity and semantic confidence are separate axes', () {
    test('integrity caps semantics, and the cap is the weakest source', () {
      final Confidence sure = confidence(0.95);

      expect(
        capped(sure, <CaptureIntegrity>[CaptureIntegrity.verbatim]),
        0.95,
        reason: 'a faithful record does not limit meaning',
      );
      expect(
        capped(sure, <CaptureIntegrity>[CaptureIntegrity.transcribed]),
        0.80,
        reason:
            'a model may not be surer of a sentence than we are of the text',
      );
      expect(
        capped(sure, <CaptureIntegrity>[
          CaptureIntegrity.verbatim,
          CaptureIntegrity.transcribed,
        ]),
        0.80,
        reason: 'the weakest link decides',
      );
    });

    test('a low semantic confidence is not raised by perfect integrity', () {
      // The axes are independent: capping only ever lowers. Being sure we read
      // the text correctly says nothing about having understood it.
      final Confidence unsure = confidence(0.3);
      expect(
        capped(unsure, <CaptureIntegrity>[CaptureIntegrity.verbatim]),
        0.3,
      );
    });

    test('integrity is not expressed as a confidence value', () {
      // Each level carries a ceiling, which is a limit on something else — not
      // a probability that the fact is true.
      expect(CaptureIntegrity.verbatim.confidenceCeiling, 1.0);
      expect(CaptureIntegrity.parsed.confidenceCeiling, 0.95);
      expect(CaptureIntegrity.transcribed.confidenceCeiling, 0.80);
      expect(CaptureIntegrity.userReported.confidenceCeiling, 0.90);
    });
  });
}
