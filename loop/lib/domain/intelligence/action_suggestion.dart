import '../ids.dart';
import 'action_kind.dart';
import 'attention_assessment.dart';
import 'policy_ref.dart';
import 'risk_assessment.dart';

/// How sure the *recommendation* is — never to be confused with the other two
/// numbers this codebase calls confidence.
///
/// Three distinct meanings live in this system and the brief is explicit that
/// mixing any two of them is the mistake to avoid:
///
/// * `CaptureIntegrity` (2A) — is the record faithful to its source?
/// * `Confidence` (2A, on an [Inference]) — is the *reading* right?
/// * [RecommendationConfidence] (2B, here) — is *this suggestion* the right
///   thing to propose?
///
/// A loop can rest on a rock-solid inference (integrity `verbatim`, confidence
/// `0.95`) while the suggestion drawn from it is a poor one — the rule that
/// fired was a weak match for the situation. The three are independent, so
/// this is its own type rather than a relabelled `Confidence`: reusing that
/// class here would let a caller pass an inference's confidence into a
/// suggestion by accident and have the type system say nothing about it.
class RecommendationConfidence {
  RecommendationConfidence({required this.value, required this.basis}) {
    if (value.isNaN || value < 0 || value > 1) {
      throw ArgumentError.value(
        value,
        'value',
        'RecommendationConfidence must be in 0..1',
      );
    }
  }

  final double value;
  final RecommendationBasis basis;

  @override
  String toString() =>
      'RecommendationConfidence(${value.toStringAsFixed(2)}, ${basis.name})';
}

/// What the recommendation confidence is grounded in.
enum RecommendationBasis {
  /// A single deterministic rule matched with nothing ambiguous about it.
  exactRuleMatch,

  /// Chosen among more than one applicable rule, by score.
  selectedAmongCandidates,
}

/// Which deterministic rule produced a suggestion.
///
/// A closed set rather than a free-text label: "why this suggestion" has to
/// resolve to one of these, checkable by a test, not to a sentence a reviewer
/// has to trust. Declaration order is also the tie-break order used by
/// [NextActionPolicy.selectBest] — see its doc.
enum SuggestionRuleId {
  /// A `detected` proposal has not been confirmed.
  confirmDetectedProposal,

  /// A closure needs to be checked against what actually happened.
  verifyClosure,

  /// The wait has gone on long enough to be worth a nudge.
  escalateStaleWait,

  /// A deadline is close enough to be worth a reminder.
  nudgeApproachingDeadline,

  /// The last verification did not hold; something needs to be tried again.
  retryAfterFailedVerification,
}

/// The structured "why", in the form the brief asks for: reason codes and
/// references back to the assessments that produced them — never a sentence.
///
/// Rendering this as a sentence, in whichever of the three languages, is
/// presentation's job, later. The domain hands over exactly what it knows.
class SuggestionRationale {
  const SuggestionRationale({
    required this.rule,
    this.riskReasons = const <LoopRiskReason>[],
    this.attentionReasons = const <LoopAttentionReason>[],
  });

  final SuggestionRuleId rule;

  /// Which of the risk assessment's own reasons this suggestion answers.
  /// Every entry here is expected to also appear in the [RiskAssessment] that
  /// was evaluated alongside this suggestion — see the invariant test.
  final List<LoopRiskReason> riskReasons;
  final List<LoopAttentionReason> attentionReasons;

  bool get isGrounded => riskReasons.isNotEmpty || attentionReasons.isNotEmpty;

  @override
  String toString() => 'SuggestionRationale(${rule.name}, risk:$riskReasons, '
      'attention:$attentionReasons)';
}

/// A recommendation — never an instruction.
///
/// This is the entire distance the brief draws between "you need to do X" and
/// "can I do X for you": [ActionSuggestion] is inert data with a reason
/// attached. There is no method on it that does anything, no reference to an
/// executor, and nothing downstream in this codebase that can turn one into an
/// effect. `ExecutableAction` and `ApprovalRecord` are the types that would
/// change that, and neither exists yet.
class ActionSuggestion {
  ActionSuggestion({
    required this.id,
    required this.loop,
    required this.kind,
    required this.sideEffectClass,
    required this.rationale,
    required this.confidence,
    required this.producedBy,
    required this.evaluatedAt,
  });

  /// Composed, not generated: `loop:rule`. Two evaluations of the same rule
  /// against the same loop always produce the same id, which is what makes a
  /// re-run comparable to the one before it — the same discipline 2A applies
  /// to `LoopEvent`, whose identity is `(loop, sequence)` rather than a
  /// generated value.
  factory ActionSuggestion.identifiedBy({
    required LoopId loop,
    required ActionKind kind,
    required SideEffectClass sideEffectClass,
    required SuggestionRationale rationale,
    required RecommendationConfidence confidence,
    required PolicyRef producedBy,
    required DateTime evaluatedAt,
  }) =>
      ActionSuggestion(
        id: ActionSuggestionId('${loop.value}:${rationale.rule.name}'),
        loop: loop,
        kind: kind,
        sideEffectClass: sideEffectClass,
        rationale: rationale,
        confidence: confidence,
        producedBy: producedBy,
        evaluatedAt: evaluatedAt,
      );

  final ActionSuggestionId id;
  final LoopId loop;
  final ActionKind kind;
  final SideEffectClass sideEffectClass;
  final SuggestionRationale rationale;
  final RecommendationConfidence confidence;

  /// Which policy, and which version, produced this. Never a model name: no
  /// AI port has an implementation yet, so every suggestion in 2B is produced
  /// by a rule and says so.
  final PolicyRef producedBy;

  final DateTime evaluatedAt;

  @override
  String toString() =>
      'ActionSuggestion($id, ${kind.name}, ${sideEffectClass.name}, '
      '${rationale.rule.name})';
}
