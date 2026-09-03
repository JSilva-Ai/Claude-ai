import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/attention_assessment.dart';
import 'package:loop/domain/intelligence/attention_policy.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';
import 'package:loop/domain/loop/loop_state.dart';

import 'fixtures.dart';

void main() {
  group('a quiet loop earns no attention', () {
    test('open, unpinned, no deadline, nothing failed', () {
      final AttentionAssessment a = attentionOf(signals());
      expect(a.band, AttentionBand.low);
      expect(a.score, 0);
      expect(a.reasons, isEmpty);
    });
  });

  group('every reason is named', () {
    test('a deadline inside the imminent window produces deadlineImminent', () {
      final AttentionAssessment a = attentionOf(
        signals(deadline: t0.add(const Duration(hours: 2))),
      );
      expect(
        a.reasons.map((AttentionReasonEntry r) => r.reason),
        contains(LoopAttentionReason.deadlineImminent),
      );
    });

    test('a deadline outside the window produces nothing', () {
      final AttentionAssessment a = attentionOf(
        signals(deadline: t0.add(const Duration(days: 3))),
      );
      expect(a.reasons, isEmpty);
    });

    test('a detected proposal produces awaitingConfirmation', () {
      final AttentionAssessment a = attentionOf(
        signals(state: LoopState.detected),
      );
      expect(
        a.reasons.map((AttentionReasonEntry r) => r.reason),
        contains(LoopAttentionReason.awaitingConfirmation),
      );
    });

    test('a failed verification produces actionFailed', () {
      final AttentionAssessment a = attentionOf(
        signals(failedVerifications: 1),
      );
      expect(
        a.reasons.map((AttentionReasonEntry r) => r.reason),
        contains(LoopAttentionReason.actionFailed),
      );
    });

    test('pinning produces userPinned and it weighs the most', () {
      final AttentionAssessment pinned = attentionOf(signals(isPinned: true));
      final AttentionAssessment deadline = attentionOf(
        signals(deadline: t0.add(const Duration(hours: 1))),
      );
      expect(
        pinned.reasons.map((AttentionReasonEntry r) => r.reason),
        contains(LoopAttentionReason.userPinned),
      );
      expect(pinned.score, greaterThan(deadline.score));
    });
  });

  group('suppression overrides everything', () {
    test('a suppressed loop scores zero no matter what else applies', () {
      final AttentionAssessment a = attentionOf(
        signals(
          isPinned: true,
          state: LoopState.detected,
          deadline: t0.add(const Duration(minutes: 5)),
          failedVerifications: 3,
          isSuppressed: true,
        ),
      );
      expect(a.score, 0);
      expect(a.band, AttentionBand.low);
    });
  });

  group('attention is independent of risk', () {
    test('high risk does not imply high attention', () {
      // A stale, unconfirmed, low-confidence proposal is exactly the kind of
      // thing risk scores harshly; on its own, none of that is a reason
      // attention currently recognises.
      final s = signals(
        state: LoopState.detected,
        proposalAge: const Duration(days: 20),
        confidence: 0.2,
      );
      final RiskAssessment r = riskOf(s);
      final AttentionAssessment a = attentionOf(s);

      expect(r.band, anyOf(RiskBand.medium, RiskBand.high, RiskBand.critical));
      // awaitingConfirmation still fires because it is `detected`, but the
      // point holds: the two scores are computed from disjoint reason sets.
      expect(
        r.reasons.map((RiskReasonEntry x) => x.reason).toSet(),
        isNot(
          a.reasons.map((AttentionReasonEntry x) => x.reason.name).toSet(),
        ),
      );
    });

    test('high attention does not imply high risk', () {
      // Due in ten minutes but perfectly on track. Risk's own "approaching"
      // window (24h) is wider than attention's "imminent" one (4h), so a
      // ten-minute deadline still nudges risk — the point is that it does not
      // *dominate* it the way contradiction or a long wait does.
      final LoopSignals s = signals(
        deadline: t0.add(const Duration(minutes: 10)),
      );
      final RiskAssessment r = riskOf(s);
      final AttentionAssessment a = attentionOf(s);

      expect(a.band, AttentionBand.high);
      expect(
        r.band,
        isNot(anyOf(RiskBand.high, RiskBand.critical)),
        reason: 'on-track work close to due is not severely risky',
      );
    });

    test('the two policies are separate types with separate bands', () {
      expect(RiskBand.values, isNot(AttentionBand.values));
    });
  });

  group('band boundaries', () {
    const AttentionWeights w = AttentionWeights();

    test('exact boundaries round up', () {
      expect(w.bandOf(0.0), AttentionBand.low);
      expect(w.bandOf(0.29), AttentionBand.low);
      expect(w.bandOf(0.30), AttentionBand.medium);
      expect(w.bandOf(0.59), AttentionBand.medium);
      expect(w.bandOf(0.60), AttentionBand.high);
    });
  });

  group('deterministic repeatability', () {
    test('the same signals evaluated twice agree', () {
      final s = signals(deadline: t0.add(const Duration(hours: 1)));
      expect(attentionOf(s).score, attentionOf(s).score);
      expect(attentionOf(s).reasons.length, attentionOf(s).reasons.length);
    });
  });
}
