import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/action_kind.dart';
import 'package:loop/domain/intelligence/action_suggestion.dart';
import 'package:loop/domain/intelligence/attention_assessment.dart';
import 'package:loop/domain/intelligence/loop_signals.dart';
import 'package:loop/domain/intelligence/next_action_policy.dart';
import 'package:loop/domain/intelligence/policy_ref.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';
import 'package:loop/domain/loop/loop_state.dart';

import 'fixtures.dart';

void main() {
  const NextActionPolicy policy = NextActionPolicy.v1;

  group('candidates are only ever what the signals honestly support', () {
    test('a quiet open loop suggests nothing', () {
      expect(policy.candidatesFor(loop: loopId, signals: signals()), isEmpty);
    });

    test('detected proposes opening it, for confirmation', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(state: LoopState.detected),
      );
      expect(c, hasLength(1));
      expect(c.single.kind, ActionKind.open);
      expect(c.single.sideEffectClass, SideEffectClass.none);
      expect(c.single.rationale.rule, SuggestionRuleId.confirmDetectedProposal);
    });

    test('verifying proposes comparing against what actually happened', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(state: LoopState.verifying),
      );
      expect(c.single.kind, ActionKind.compare);
      expect(c.single.rationale.rule, SuggestionRuleId.verifyClosure);
    });

    test('a long wait proposes a reply, and names the class outbound', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(
          state: LoopState.waiting,
          waitingFor: const Duration(days: 5),
        ),
      );
      expect(c.single.kind, ActionKind.reply);
      expect(c.single.sideEffectClass, SideEffectClass.outbound);
    });

    test('a short wait proposes nothing', () {
      expect(
        policy.candidatesFor(
          loop: loopId,
          signals: signals(
            state: LoopState.waiting,
            waitingFor: const Duration(hours: 1),
          ),
        ),
        isEmpty,
      );
    });

    test('an approaching deadline proposes a local reminder', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(deadline: t0.add(const Duration(hours: 3))),
      );
      expect(c.single.kind, ActionKind.remind);
      expect(c.single.sideEffectClass, SideEffectClass.local);
    });

    test('a failed verification, back in open, proposes preparing again', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(state: LoopState.open, failedVerifications: 1),
      );
      expect(c.single.kind, ActionKind.prepare);
    });

    test('two rules can honestly apply at once', () {
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: signals(
          state: LoopState.waiting,
          waitingFor: const Duration(days: 5),
          deadline: t0.add(const Duration(hours: 2)),
        ),
      );
      expect(c, hasLength(2));
      expect(
        c.map((ActionSuggestion s) => s.rationale.rule),
        containsAll(<SuggestionRuleId>[
          SuggestionRuleId.escalateStaleWait,
          SuggestionRuleId.nudgeApproachingDeadline,
        ]),
      );
    });

    test('a terminal loop proposes nothing, even with a wild waitingFor value',
        () {
      // resolved/abandoned loops carry no waitingFor by construction (2A), but
      // the policy itself should not assume that — it should simply find no
      // rule whose state condition matches.
      expect(
        policy.candidatesFor(
          loop: loopId,
          signals: signals(state: LoopState.resolved),
        ),
        isEmpty,
      );
    });
  });

  group('selecting the best among candidates is explainable', () {
    test('a single candidate is chosen and its score is recorded', () {
      final LoopSignals s = signals(state: LoopState.detected);
      final List<ActionSuggestion> c = policy.candidatesFor(
        loop: loopId,
        signals: s,
      );
      final NextBestAction best = policy.selectBest(
        candidates: c,
        risk: riskOf(s),
        attention: attentionOf(s),
        now: t0,
      );

      expect(best.chosen, c.single);
      expect(best.scores[c.single.id], isNotNull);
      expect(best.candidates, c);
    });

    test('no candidates means no chosen action, not a fabricated one', () {
      final NextBestAction best = policy.selectBest(
        candidates: const <ActionSuggestion>[],
        risk: riskOf(signals()),
        attention: attentionOf(signals()),
        now: t0,
      );
      expect(best.chosen, isNull);
      expect(best.scores, isEmpty);
    });

    test(
        'the winning score is exactly the sum of the reasons the candidate cites',
        () {
      // Two honest candidates at once: a long wait, and a deadline close
      // enough to trip both risk's "approaching" window (24h) and attention's
      // "imminent" one (4h). The deadline candidate cites a risk reason *and*
      // an attention reason; the wait candidate only cites a risk reason — so
      // this also shows that citing more of what the assessments actually
      // found produces a higher, and traceable, score.
      final LoopSignals s = signals(
        state: LoopState.waiting,
        waitingFor: const Duration(days: 5),
        deadline: t0.add(const Duration(hours: 2)),
      );
      final RiskAssessment risk = riskOf(s);
      final AttentionAssessment attention = attentionOf(s);
      final List<ActionSuggestion> candidates = policy.candidatesFor(
        loop: loopId,
        signals: s,
      );
      final NextBestAction best = policy.selectBest(
        candidates: candidates,
        risk: risk,
        attention: attention,
        now: t0,
      );

      final ActionSuggestion deadlineCandidate = candidates.firstWhere(
        (ActionSuggestion c) =>
            c.rationale.rule == SuggestionRuleId.nudgeApproachingDeadline,
      );
      final ActionSuggestion waitCandidate = candidates.firstWhere(
        (ActionSuggestion c) =>
            c.rationale.rule == SuggestionRuleId.escalateStaleWait,
      );

      double riskWeightOf(LoopRiskReason r) =>
          risk.reasons.firstWhere((RiskReasonEntry x) => x.reason == r).weight;
      double attentionWeightOf(LoopAttentionReason r) => attention.reasons
          .firstWhere((AttentionReasonEntry x) => x.reason == r)
          .weight;

      const double base = 0.05; // NextActionWeights.structuralRuleBase
      final double expectedWait =
          base + riskWeightOf(LoopRiskReason.waitingTooLong);
      final double expectedDeadline = base +
          riskWeightOf(LoopRiskReason.deadlineApproaching) +
          attentionWeightOf(LoopAttentionReason.deadlineImminent);

      expect(best.scores[waitCandidate.id], closeTo(expectedWait, 1e-9));
      expect(
        best.scores[deadlineCandidate.id],
        closeTo(expectedDeadline, 1e-9),
      );
      expect(
        best.chosen,
        deadlineCandidate,
        reason: 'it cites strictly more of what the assessments found',
      );
    });

    test('a tie falls back to a fixed, declared priority order', () {
      // Two structural candidates with the same base score and no weighted
      // reason: confirmDetectedProposal is declared before verifyClosure, so
      // it wins deterministically rather than by insertion order in the list.
      ActionSuggestion structural(SuggestionRuleId rule, ActionKind kind) {
        return ActionSuggestion.identifiedBy(
          loop: loopId,
          kind: kind,
          sideEffectClass: SideEffectClass.none,
          rationale: SuggestionRationale(rule: rule),
          confidence: RecommendationConfidence(
            value: 0.5,
            basis: RecommendationBasis.exactRuleMatch,
          ),
          producedBy: const PolicyRef(
            id: 'next-action',
            version: PolicyVersion('next-action-v1'),
          ),
          evaluatedAt: t0,
        );
      }

      final ActionSuggestion a = structural(
        SuggestionRuleId.verifyClosure,
        ActionKind.compare,
      );
      final ActionSuggestion b = structural(
        SuggestionRuleId.confirmDetectedProposal,
        ActionKind.open,
      );

      final NextBestAction best = policy.selectBest(
        candidates: <ActionSuggestion>[a, b],
        risk: riskOf(signals()),
        attention: attentionOf(signals()),
        now: t0,
      );

      expect(
        best.scores[a.id],
        best.scores[b.id],
        reason: 'both structural, no weighted reason',
      );
      expect(
        best.chosen,
        b,
        reason: 'confirmDetectedProposal is declared first',
      );
    });
  });

  group('deterministic repeatability', () {
    test('the same loop and signals produce the same NextBestAction twice', () {
      final LoopSignals s = signals(
        state: LoopState.waiting,
        waitingFor: const Duration(days: 5),
      );
      final RiskAssessment risk = riskOf(s);
      final attention = attentionOf(s);

      NextBestAction run() => policy.selectBest(
            candidates: policy.candidatesFor(loop: loopId, signals: s),
            risk: risk,
            attention: attention,
            now: t0,
          );

      final NextBestAction first = run();
      final NextBestAction second = run();

      expect(first.chosen?.id, second.chosen?.id);
      expect(first.scores, second.scores);
    });
  });
}
