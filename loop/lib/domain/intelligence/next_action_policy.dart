import '../ids.dart';
import '../loop/loop_state.dart';
import 'action_kind.dart';
import 'action_suggestion.dart';
import 'attention_assessment.dart';
import 'loop_signals.dart';
import 'policy_ref.dart';
import 'risk_assessment.dart';

/// The outcome of choosing among candidate suggestions for one loop.
///
/// [scores] is not incidental — it is the explanation. "Why this action?" is
/// answered by pointing at this map: every candidate that was considered, and
/// exactly what it scored, so the choice can be checked rather than trusted.
class NextBestAction {
  const NextBestAction({
    required this.chosen,
    required this.candidates,
    required this.scores,
    required this.evaluatedAt,
    required this.policy,
  });

  /// Null when no rule applied — a loop with nothing wrong with it gets no
  /// suggestion, not a manufactured one.
  final ActionSuggestion? chosen;

  final List<ActionSuggestion> candidates;
  final Map<ActionSuggestionId, double> scores;
  final DateTime evaluatedAt;
  final PolicyRef policy;

  @override
  String toString() =>
      'NextBestAction(${chosen?.rationale.rule.name ?? 'none'} among '
      '${candidates.length} candidates)';
}

/// Generates candidate [ActionSuggestion]s from [LoopSignals] and selects the
/// best one, all without a model call anywhere in the path.
///
/// Every rule here is a direct, checkable answer to "given exactly this
/// signal, what would a person sensibly do next" — not a guess dressed as one.
/// A signal 2A does not give us (how many steps remain, whether a dependency
/// blocks the loop) produces no rule, on the same principle `FrictionPolicy`
/// is deferred rather than faked.
class NextActionPolicy {
  const NextActionPolicy(
    this.version, {
    this.weights = const NextActionWeights(),
  });

  static const NextActionPolicy v1 = NextActionPolicy(
    PolicyVersion('next-action-v1'),
  );

  final PolicyVersion version;
  final NextActionWeights weights;

  PolicyRef get _ref => PolicyRef(id: 'next-action', version: version);

  /// Every rule that honestly applies to this loop right now. More than one
  /// can fire — a loop can be both long-waiting and close to its deadline —
  /// which is exactly the case [selectBest] exists to resolve.
  List<ActionSuggestion> candidatesFor({
    required LoopId loop,
    required LoopSignals signals,
  }) {
    final List<ActionSuggestion> out = <ActionSuggestion>[];

    if (signals.state == LoopState.detected) {
      out.add(
        _suggest(
          loop: loop,
          kind: ActionKind.open,
          sideEffectClass: SideEffectClass.none,
          rule: SuggestionRuleId.confirmDetectedProposal,
          attentionReasons: const <LoopAttentionReason>[
            LoopAttentionReason.awaitingConfirmation,
          ],
          now: signals.now,
        ),
      );
    }

    if (signals.state == LoopState.verifying) {
      out.add(
        _suggest(
          loop: loop,
          kind: ActionKind.compare,
          sideEffectClass: SideEffectClass.none,
          rule: SuggestionRuleId.verifyClosure,
          now: signals.now,
        ),
      );
    }

    final Duration? waiting = signals.waitingFor;
    if (signals.state == LoopState.waiting &&
        waiting != null &&
        waiting >= weights.longWait) {
      out.add(
        _suggest(
          loop: loop,
          kind: ActionKind.reply,
          sideEffectClass: SideEffectClass.outbound,
          rule: SuggestionRuleId.escalateStaleWait,
          riskReasons: const <LoopRiskReason>[LoopRiskReason.waitingTooLong],
          now: signals.now,
        ),
      );
    }

    final Duration? left = signals.timeUntilDeadline;
    if (left != null &&
        !left.isNegative &&
        left <= weights.approachingWindow &&
        signals.state.isActive) {
      out.add(
        _suggest(
          loop: loop,
          kind: ActionKind.remind,
          sideEffectClass: SideEffectClass.local,
          rule: SuggestionRuleId.nudgeApproachingDeadline,
          riskReasons: const <LoopRiskReason>[
            LoopRiskReason.deadlineApproaching,
          ],
          attentionReasons: const <LoopAttentionReason>[
            LoopAttentionReason.deadlineImminent,
          ],
          now: signals.now,
        ),
      );
    }

    if (signals.state == LoopState.open && signals.failedVerifications > 0) {
      out.add(
        _suggest(
          loop: loop,
          kind: ActionKind.prepare,
          sideEffectClass: SideEffectClass.local,
          rule: SuggestionRuleId.retryAfterFailedVerification,
          riskReasons: const <LoopRiskReason>[
            LoopRiskReason.repeatedVerificationFailure,
          ],
          attentionReasons: const <LoopAttentionReason>[
            LoopAttentionReason.actionFailed,
          ],
          now: signals.now,
        ),
      );
    }

    return out;
  }

  /// Scores every candidate against the risk and attention assessments
  /// already computed for the same loop, and picks the highest.
  ///
  /// The score is the sum of the weights of whichever risk and attention
  /// reasons the candidate's own rationale cites — never a number invented for
  /// the purpose of ranking. A rule with no matching weighted reason (closure
  /// verification has none of its own; it is structural to `verifying`) is
  /// deliberately not zero: [NextActionWeights.structuralRuleBase] gives it a
  /// floor so a purely structural suggestion is not silently outranked by
  /// every rule that happens to touch a risk reason. Ties fall back to
  /// [SuggestionRuleId]'s own declaration order, which is fixed and
  /// documented rather than arbitrary.
  NextBestAction selectBest({
    required List<ActionSuggestion> candidates,
    required RiskAssessment risk,
    required AttentionAssessment attention,
    required DateTime now,
  }) {
    final Map<ActionSuggestionId, double> scores = <ActionSuggestionId, double>{
      for (final ActionSuggestion c in candidates)
        c.id: _score(c, risk, attention),
    };

    ActionSuggestion? best;
    for (final ActionSuggestion c in candidates) {
      if (best == null) {
        best = c;
        continue;
      }
      final double cScore = scores[c.id]!;
      final double bestScore = scores[best.id]!;
      final bool better = cScore > bestScore ||
          (cScore == bestScore && _priority(c) < _priority(best));
      if (better) best = c;
    }

    return NextBestAction(
      chosen: best,
      candidates: candidates,
      scores: scores,
      evaluatedAt: now,
      policy: _ref,
    );
  }

  double _score(
    ActionSuggestion candidate,
    RiskAssessment risk,
    AttentionAssessment attention,
  ) {
    double score = weights.structuralRuleBase;
    for (final RiskReasonEntry r in risk.reasons) {
      if (candidate.rationale.riskReasons.contains(r.reason)) {
        score += r.weight;
      }
    }
    for (final AttentionReasonEntry a in attention.reasons) {
      if (candidate.rationale.attentionReasons.contains(a.reason)) {
        score += a.weight;
      }
    }
    return score;
  }

  int _priority(ActionSuggestion s) =>
      SuggestionRuleId.values.indexOf(s.rationale.rule);

  ActionSuggestion _suggest({
    required LoopId loop,
    required ActionKind kind,
    required SideEffectClass sideEffectClass,
    required SuggestionRuleId rule,
    required DateTime now,
    List<LoopRiskReason> riskReasons = const <LoopRiskReason>[],
    List<LoopAttentionReason> attentionReasons = const <LoopAttentionReason>[],
  }) =>
      ActionSuggestion.identifiedBy(
        loop: loop,
        kind: kind,
        sideEffectClass: sideEffectClass,
        rationale: SuggestionRationale(
          rule: rule,
          riskReasons: riskReasons,
          attentionReasons: attentionReasons,
        ),
        confidence: RecommendationConfidence(
          value: weights.confidenceFor(rule),
          basis: RecommendationBasis.exactRuleMatch,
        ),
        producedBy: _ref,
        evaluatedAt: now,
      );
}

class NextActionWeights {
  const NextActionWeights({
    this.longWait = const Duration(days: 3),
    this.approachingWindow = const Duration(hours: 24),
    this.structuralRuleBase = 0.05,
    this.ruleConfidence = const <SuggestionRuleId, double>{
      SuggestionRuleId.confirmDetectedProposal: 0.90,
      SuggestionRuleId.verifyClosure: 0.85,
      SuggestionRuleId.escalateStaleWait: 0.70,
      SuggestionRuleId.nudgeApproachingDeadline: 0.75,
      SuggestionRuleId.retryAfterFailedVerification: 0.60,
    },
  });

  final Duration longWait;
  final Duration approachingWindow;
  final double structuralRuleBase;
  final Map<SuggestionRuleId, double> ruleConfidence;

  double confidenceFor(SuggestionRuleId rule) => ruleConfidence[rule] ?? 0.5;
}
