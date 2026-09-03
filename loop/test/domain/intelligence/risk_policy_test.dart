import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/policy_ref.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/intelligence/risk_policy.dart';
import 'package:loop/domain/loop/loop_state.dart';

import 'fixtures.dart';

void main() {
  group('a quiet loop has no risk and no reasons', () {
    test('open, no deadline, no wait, no confidence issue', () {
      final RiskAssessment a = riskOf(signals(state: LoopState.open));

      expect(a.band, RiskBand.low);
      expect(a.score, 0);
      expect(a.reasons, isEmpty);
    });
  });

  group('every reason is named, not just a number', () {
    test('overdue produces deadlineApproaching with a positive weight', () {
      final RiskAssessment a = riskOf(
        signals(deadline: t0.subtract(const Duration(hours: 1))),
      );

      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.deadlineApproaching),
      );
      expect(
        a.reasons
            .firstWhere(
              (RiskReasonEntry r) =>
                  r.reason == LoopRiskReason.deadlineApproaching,
            )
            .weight,
        greaterThan(0),
      );
    });

    test('a long wait produces waitingTooLong', () {
      final RiskAssessment a = riskOf(
        signals(
          state: LoopState.waiting,
          waitingFor: const Duration(days: 4),
        ),
      );
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.waitingTooLong),
      );
    });

    test('a short wait produces nothing — the threshold is a real boundary',
        () {
      final RiskAssessment a = riskOf(
        signals(
          state: LoopState.waiting,
          waitingFor: const Duration(hours: 2),
        ),
      );
      expect(a.reasons, isEmpty);
    });

    test('low semantic confidence produces lowConfidence', () {
      final RiskAssessment a = riskOf(signals(confidence: 0.3));
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.lowConfidence),
      );
    });

    test('high semantic confidence produces nothing from that reason', () {
      final RiskAssessment a = riskOf(signals(confidence: 0.9));
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        isNot(contains(LoopRiskReason.lowConfidence)),
      );
    });

    test('a stale, unconfirmed proposal produces staleProposal', () {
      final RiskAssessment a = riskOf(
        signals(
          state: LoopState.detected,
          proposalAge: const Duration(days: 10),
        ),
      );
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.staleProposal),
      );
    });

    test('a user rejection produces contradictedByUser, and it dominates', () {
      final RiskAssessment a = riskOf(signals(contradictedByUser: true));
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.contradictedByUser),
      );
      expect(a.band, anyOf(RiskBand.high, RiskBand.critical));
    });

    test('a broken provenance chain produces evidenceUngrounded', () {
      final RiskAssessment a = riskOf(signals(evidenceUngrounded: true));
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.evidenceUngrounded),
      );
    });

    test('a failed verification produces repeatedVerificationFailure', () {
      final RiskAssessment a = riskOf(signals(failedVerifications: 2));
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        contains(LoopRiskReason.repeatedVerificationFailure),
      );
    });

    test('reasons compose: more than one can apply at once', () {
      final RiskAssessment a = riskOf(
        signals(
          state: LoopState.waiting,
          waitingFor: const Duration(days: 5),
          confidence: 0.2,
        ),
      );
      expect(a.reasons.length, 2);
      expect(a.score, greaterThan(0.25));
    });

    test('a non-zero score always carries at least one reason', () {
      // The invariant the type's own doc promises: a risk with no reasons is
      // treated as a bug, not a possible output.
      for (final double confidence in <double>[0.1, 0.3, 0.49]) {
        final RiskAssessment a = riskOf(signals(confidence: confidence));
        if (a.score > 0) expect(a.reasons, isNotEmpty);
      }
    });
  });

  group('bands are named boundaries, not a hidden formula', () {
    const RiskBands bands = RiskBands(low: 0.25, medium: 0.50, high: 0.75);

    test('exact boundaries round up to the higher band', () {
      expect(bands.of(0.0), RiskBand.low);
      expect(bands.of(0.24), RiskBand.low);
      expect(bands.of(0.25), RiskBand.medium);
      expect(bands.of(0.49), RiskBand.medium);
      expect(bands.of(0.50), RiskBand.high);
      expect(bands.of(0.74), RiskBand.high);
      expect(bands.of(0.75), RiskBand.critical);
      expect(bands.of(1.0), RiskBand.critical);
    });
  });

  group('thresholds are a versioned policy, not a constant', () {
    test('every assessment records which policy produced it', () {
      final RiskAssessment a = riskOf(signals(confidence: 0.3));
      expect(
        a.policy,
        const PolicyRef(id: 'risk', version: PolicyVersion('risk-v1')),
      );
    });

    test('a different policy can disagree about the same signals', () {
      const RiskPolicy strict = RiskPolicy(
        PolicyVersion('risk-test-strict'),
        bands: RiskBands(low: 0.05, medium: 0.10, high: 0.20),
        weights: RiskWeights(),
      );

      final LoopSignals lowConfidence = signals(confidence: 0.45);
      expect(RiskPolicy.v1.evaluate(lowConfidence).band, RiskBand.low);
      expect(strict.evaluate(lowConfidence).band, isNot(RiskBand.low));
    });
  });

  group('risk is independent of LoopState', () {
    test(
        'the same signals score the same regardless of which state they are attached to',
        () {
      // Risk is documented as an evaluation over signals, never the state
      // machine's business — this is the direct proof: only `state` changes
      // between the two calls, and the deadline-driven score does not move.
      final DateTime deadline = t0.add(const Duration(hours: 2));
      for (final LoopState state in LoopState.values) {
        final RiskAssessment a = riskOf(
          signals(state: state, deadline: deadline),
        );
        final RiskAssessment b = riskOf(
          signals(state: LoopState.open, deadline: deadline),
        );
        expect(
          a.score,
          b.score,
          reason: '${state.name} should not change the score',
        );
      }
    });
  });

  group('deterministic repeatability', () {
    test('the same signals evaluated twice produce equal assessments', () {
      final LoopSignals fixed = signals(
        state: LoopState.waiting,
        waitingFor: const Duration(days: 4),
        confidence: 0.3,
      );
      final RiskAssessment a = riskOf(fixed);
      final RiskAssessment b = riskOf(fixed);

      expect(a.score, b.score);
      expect(a.band, b.band);
      expect(
        a.reasons.map((RiskReasonEntry r) => r.reason),
        b.reasons.map((RiskReasonEntry r) => r.reason),
      );
      expect(a.policy, b.policy);
    });
  });

  group('missing and low-confidence evidence', () {
    test(
        'no basis confidence at all — a loop the user typed — is not penalised',
        () {
      final RiskAssessment a = riskOf(signals());
      expect(
        a.reasons.map((r) => r.reason),
        isNot(contains(LoopRiskReason.lowConfidence)),
      );
    });

    test('evidenceUngrounded and lowConfidence are independent reasons', () {
      final RiskAssessment a = riskOf(
        signals(evidenceUngrounded: true, confidence: 0.2),
      );
      expect(a.reasons.length, 2);
    });
  });
}
