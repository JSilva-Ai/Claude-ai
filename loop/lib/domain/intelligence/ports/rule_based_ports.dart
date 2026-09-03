import '../../ids.dart';
import '../action_suggestion.dart';
import '../loop_signals.dart';
import '../next_action_policy.dart';
import '../risk_assessment.dart';
import '../risk_policy.dart';
import 'intelligence_ports.dart';

/// The zero-model baseline, wired to the ports it satisfies.
///
/// This is what `zero_model_baseline_test.dart` exercises: the same
/// [RiskPredictor] and [NextActionRecommender] contracts a future model-backed
/// adapter will satisfy, answered here by nothing but [RiskPolicy] and
/// [NextActionPolicy] — table lookups and arithmetic over [LoopSignals]. A
/// caller holding an `RiskPredictor` cannot tell, from the type, whether it
/// holds this or a model; that is deliberate, and it is what makes "does a
/// model actually improve on this" a question with a real answer later.
class RuleBasedRiskPredictor implements RiskPredictor {
  const RuleBasedRiskPredictor([this.policy = RiskPolicy.v1]);

  final RiskPolicy policy;

  @override
  RiskAssessment assess(LoopSignals signals) => policy.evaluate(signals);
}

class RuleBasedNextActionRecommender implements NextActionRecommender {
  const RuleBasedNextActionRecommender([this.policy = NextActionPolicy.v1]);

  final NextActionPolicy policy;

  @override
  List<ActionSuggestion> recommend(LoopId loop, LoopSignals signals) =>
      policy.candidatesFor(loop: loop, signals: signals);
}
