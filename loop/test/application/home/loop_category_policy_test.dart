import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/home/loop_category_policy.dart';
import 'package:loop/core/models/loop_category.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/intelligence/policy_ref.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';
import 'package:loop/domain/loop/loop_state.dart';

import '../../domain/fixtures.dart';

RiskAssessment _riskAt(RiskBand band) => RiskAssessment(
      score: 0,
      band: band,
      reasons: const <RiskReasonEntry>[],
      evaluatedAt: t0,
      policy: const PolicyRef(id: 'risk', version: PolicyVersion('test')),
    );

LoopSignals _signalsFor(LoopState state, {DateTime? deadline}) => LoopSignals(
      state: state,
      now: t0,
      isPinned: false,
      isSuppressed: false,
      deadline: deadline,
      timeUntilDeadline: deadline?.difference(t0),
    );

void main() {
  group('categoriesFor', () {
    test('a resolved loop is DONE and nothing else', () {
      final Set<LoopCategory> categories = categoriesFor(
        loop: loopIn(LoopState.resolved),
        risk: _riskAt(RiskBand.low),
        signals: _signalsFor(LoopState.resolved),
        now: t0,
      );
      expect(categories, <LoopCategory>{LoopCategory.done});
    });

    test('an abandoned loop is in no category — not DONE, not open work', () {
      final Set<LoopCategory> categories = categoriesFor(
        loop: loopIn(LoopState.abandoned),
        risk: _riskAt(RiskBand.critical),
        signals: _signalsFor(LoopState.abandoned),
        now: t0,
      );
      expect(categories, isEmpty);
    });

    test('high or critical risk is AT RISK; medium and low are not', () {
      for (final RiskBand band in <RiskBand>[
        RiskBand.high,
        RiskBand.critical,
      ]) {
        expect(
          categoriesFor(
            loop: loopIn(LoopState.open),
            risk: _riskAt(band),
            signals: _signalsFor(LoopState.open),
            now: t0,
          ),
          contains(LoopCategory.atRisk),
          reason: '${band.name} should be AT RISK',
        );
      }
      for (final RiskBand band in <RiskBand>[RiskBand.medium, RiskBand.low]) {
        expect(
          categoriesFor(
            loop: loopIn(LoopState.open),
            risk: _riskAt(band),
            signals: _signalsFor(LoopState.open),
            now: t0,
          ),
          isNot(contains(LoopCategory.atRisk)),
          reason: '${band.name} should not be AT RISK',
        );
      }
    });

    test('LoopState.waiting is WAITING, regardless of risk', () {
      expect(
        categoriesFor(
          loop: loopIn(LoopState.waiting),
          risk: _riskAt(RiskBand.low),
          signals: _signalsFor(LoopState.waiting),
          now: t0,
        ),
        contains(LoopCategory.waiting),
      );
    });

    test(
        'a deadline on today\'s local calendar date is TODAY, even hours '
        'apart from now', () {
      final DateTime earlyThisMorning = DateTime(t0.year, t0.month, t0.day, 1);
      expect(
        categoriesFor(
          loop: loopIn(LoopState.open),
          risk: _riskAt(RiskBand.low),
          signals: _signalsFor(LoopState.open, deadline: earlyThisMorning),
          now: t0,
        ),
        contains(LoopCategory.today),
      );
    });

    test('a deadline on a different calendar date is not TODAY', () {
      final DateTime tomorrow = t0.add(const Duration(days: 1));
      expect(
        categoriesFor(
          loop: loopIn(LoopState.open),
          risk: _riskAt(RiskBand.low),
          signals: _signalsFor(LoopState.open, deadline: tomorrow),
          now: t0,
        ),
        isNot(contains(LoopCategory.today)),
      );
    });

    test(
        'a loop can be AT RISK and TODAY at once — the reference design\'s '
        'own overlap', () {
      final Set<LoopCategory> categories = categoriesFor(
        loop: loopIn(LoopState.open),
        risk: _riskAt(RiskBand.critical),
        signals: _signalsFor(LoopState.open, deadline: t0),
        now: t0,
      );
      expect(categories, <LoopCategory>{
        LoopCategory.atRisk,
        LoopCategory.today,
      });
    });

    test(
        'an unremarkable open loop belongs to no card, and that is a '
        'valid, empty answer', () {
      expect(
        categoriesFor(
          loop: loopIn(LoopState.open),
          risk: _riskAt(RiskBand.low),
          signals: _signalsFor(LoopState.open),
          now: t0,
        ),
        isEmpty,
      );
    });
  });
}
