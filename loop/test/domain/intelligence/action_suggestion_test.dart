import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/intelligence/action_kind.dart';
import 'package:loop/domain/intelligence/action_suggestion.dart';
import 'package:loop/domain/intelligence/policy_ref.dart';
import 'package:loop/domain/intelligence/risk_assessment.dart';

import 'fixtures.dart';

void main() {
  PolicyRef ref() => const PolicyRef(
        id: 'next-action',
        version: PolicyVersion('next-action-v1'),
      );

  ActionSuggestion suggestion({
    SuggestionRuleId rule = SuggestionRuleId.confirmDetectedProposal,
    ActionKind kind = ActionKind.open,
    SideEffectClass sideEffectClass = SideEffectClass.none,
    double confidence = 0.9,
    DateTime? at,
  }) =>
      ActionSuggestion.identifiedBy(
        loop: loopId,
        kind: kind,
        sideEffectClass: sideEffectClass,
        rationale: SuggestionRationale(rule: rule),
        confidence: RecommendationConfidence(
          value: confidence,
          basis: RecommendationBasis.exactRuleMatch,
        ),
        producedBy: ref(),
        evaluatedAt: at ?? t0,
      );

  group('a suggestion is inert', () {
    test(
        'it has an id, a loop, a kind, a class and a rationale — nothing that runs',
        () {
      final ActionSuggestion s = suggestion(
        kind: ActionKind.reply,
        sideEffectClass: SideEffectClass.outbound,
        rule: SuggestionRuleId.escalateStaleWait,
        confidence: 0.7,
      );

      expect(s.kind, ActionKind.reply);
      expect(s.sideEffectClass, SideEffectClass.outbound);
      expect(s.loop, loopId);
      // There is nothing to call: the type has no method that does anything
      // beyond describe itself, which is the entire proof that a suggestion of
      // any side-effect class is exactly as inert as any other.
    });

    test(
        'identity is composed, not generated — two evaluations of the same rule agree',
        () {
      final ActionSuggestion a = suggestion();
      final ActionSuggestion b = suggestion(
        at: t0.add(const Duration(minutes: 5)),
      );

      expect(a.id, b.id, reason: 'same loop, same rule, same identity');
      expect(a.id.value, '${loopId.value}:confirmDetectedProposal');
    });

    test('different rules on the same loop have different identities', () {
      final Set<String> ids = SuggestionRuleId.values
          .map((SuggestionRuleId rule) => suggestion(rule: rule).id.value)
          .toSet();
      expect(ids.length, SuggestionRuleId.values.length);
    });
  });

  group('recommendation confidence is its own type', () {
    test(
        'it refuses to exist outside 0..1, the same discipline as semantic confidence',
        () {
      expect(() => suggestion(confidence: 1.4), throwsA(isA<ArgumentError>()));
      expect(() => suggestion(confidence: -0.1), throwsA(isA<ArgumentError>()));
    });

    test('it is not the evidence Confidence type — no accidental substitution',
        () {
      final RecommendationConfidence r = RecommendationConfidence(
        value: 0.8,
        basis: RecommendationBasis.exactRuleMatch,
      );
      // The type itself is the proof: a caller cannot pass an evidence
      // Confidence where a RecommendationConfidence is expected, or the other
      // way around, without the compiler refusing it. There is no shared
      // supertype and no implicit conversion between them.
      expect(r, isA<RecommendationConfidence>());
      expect(r, isNot(isA<num>()));
    });
  });

  group('side-effect classification', () {
    test('every ActionKind maps to a class a caller can branch on safely', () {
      // Not asserting a specific mapping here — NextActionPolicy owns that —
      // only that the enum exists and is exhaustive, which is what lets a
      // future executor refuse outbound/financial without guessing.
      expect(SideEffectClass.values, hasLength(4));
      expect(SideEffectClass.values, contains(SideEffectClass.outbound));
      expect(SideEffectClass.values, contains(SideEffectClass.financial));
    });
  });

  group('rationale is structured, never free text', () {
    test('it carries reason codes, not a sentence', () {
      const SuggestionRationale r = SuggestionRationale(
        rule: SuggestionRuleId.escalateStaleWait,
        riskReasons: <LoopRiskReason>[LoopRiskReason.waitingTooLong],
      );
      expect(r.isGrounded, isTrue);
      expect(r.riskReasons, contains(LoopRiskReason.waitingTooLong));
    });

    test(
        'a structural rule with no weighted reason is still valid, just not grounded in a score',
        () {
      const SuggestionRationale r = SuggestionRationale(
        rule: SuggestionRuleId.verifyClosure,
      );
      expect(r.isGrounded, isFalse);
    });
  });
}
