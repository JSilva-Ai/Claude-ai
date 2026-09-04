import '../../evidence/claim.dart';
import '../../ids.dart';
import '../action_suggestion.dart';
import '../commitment_signal_rules.dart';
import '../commitment_temporal_signals.dart';
import '../loop_signals.dart';
import '../next_action_policy.dart';
import '../risk_assessment.dart';
import '../risk_policy.dart';
import 'intelligence_ports.dart';
import 'source_signal.dart';

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

/// The zero-model baseline for [CommitmentDetector].
///
/// A thin adapter over [CommitmentSignalRules] — the same pattern matching
/// `CommitmentCandidateDetector` uses for 3C's own, richer pipeline, so
/// nothing here duplicates it. What this adapter cannot do that the richer
/// pipeline can: [CommitmentDetector.detect] takes only a [SourceSignal],
/// with no evidence source kind and no reference time, so there is nothing
/// here to judge authorship from or to resolve a deadline against. Every
/// match this returns is therefore `ClaimKind.other` with no `by` — a
/// deliberately coarser answer than `CommitmentCandidateDetector` gives,
/// consistent with this being the narrower, 2B-era contract rather than
/// 3C's actual deliverable.
class RuleBasedCommitmentDetector implements CommitmentDetector {
  const RuleBasedCommitmentDetector([
    this.rules = const CommitmentSignalRules(),
  ]);

  final CommitmentSignalRules rules;

  @override
  CommitmentDetection detect(SourceSignal signal) {
    final CommitmentSignalMatch? match = rules.match(signal.text);
    if (match == null) {
      return const CommitmentDetection(looksLikeCommitment: false);
    }
    return CommitmentDetection(
      looksLikeCommitment: true,
      claim: Claim(kind: ClaimKind.other, sourceQuote: match.sourceQuote),
    );
  }
}

/// The zero-model baseline for [EntityExtractor].
///
/// Mention-level clues only, per the architecture's own separation of
/// extraction from identity resolution: "I" and "you" are reported as
/// [EntityKind.person] mentions verbatim, never resolved to a `PartyId" —
/// there is no canonical party behind either. Proper-noun name detection
/// ("Sarah") is deliberately not attempted: capitalisation alone is not a
/// reliable enough signal, and a false person mention is exactly the
/// fabricated-identity risk 2B's own port doc warns against. Date mentions
/// reuse [CommitmentTemporalSignals.findMentions] — the same recognition
/// `CommitmentCandidateDetector` builds on, so a date cue is described
/// identically wherever either sees it.
class RuleBasedEntityExtractor implements EntityExtractor {
  const RuleBasedEntityExtractor([
    this.temporal = const CommitmentTemporalSignals(),
  ]);

  final CommitmentTemporalSignals temporal;

  static final RegExp _firstPerson = RegExp(r'\bI\b');
  static final RegExp _secondPerson = RegExp(r'\byou\b', caseSensitive: false);

  @override
  List<ExtractedEntity> extractFrom(SourceSignal signal) {
    final String text = signal.text;
    final List<ExtractedEntity> found = <ExtractedEntity>[];

    final RegExpMatch? self = _firstPerson.firstMatch(text);
    if (self != null) {
      found.add(ExtractedEntity(kind: EntityKind.person, text: self.group(0)!));
    }
    final RegExpMatch? addressee = _secondPerson.firstMatch(text);
    if (addressee != null) {
      found.add(
        ExtractedEntity(kind: EntityKind.person, text: addressee.group(0)!),
      );
    }
    for (final String mention in temporal.findMentions(text)) {
      found.add(ExtractedEntity(kind: EntityKind.date, text: mention));
    }

    return found;
  }
}
