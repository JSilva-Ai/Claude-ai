import '../evidence/claim.dart';
import '../evidence/source_ref.dart';
import '../ids.dart';
import 'commitment_candidate.dart';
import 'commitment_signal_rules.dart';
import 'commitment_temporal_signals.dart';
import 'policy_ref.dart';
import 'ports/source_signal.dart';

/// How much each reason contributes to a candidate's confidence.
///
/// A flat class of named doubles, the same discipline `RiskWeights` and
/// `AttentionWeights` already apply: every weight is visible at the
/// definition site, and a typo in a string key cannot silently produce a
/// weight of zero. [ambiguousActor] is negative on purpose — it is the one
/// reason that should pull confidence down rather than up.
class CommitmentConfidenceWeights {
  const CommitmentConfidenceWeights({
    this.firstPersonPromise = 0.55,
    this.explicitPromisePhrase = 0.50,
    this.explicitRequestVerb = 0.45,
    this.waitingLanguage = 0.35,
    this.directRecipient = 0.10,
    this.explicitDeadline = 0.15,
    this.weakTemporalSignal = 0.05,
    this.actionVerbPresent = 0.05,
    this.ambiguousActor = -0.20,
  });

  final double firstPersonPromise;
  final double explicitPromisePhrase;
  final double explicitRequestVerb;
  final double waitingLanguage;
  final double directRecipient;
  final double explicitDeadline;
  final double weakTemporalSignal;
  final double actionVerbPresent;
  final double ambiguousActor;

  double weightOf(CommitmentSignalReason reason) => switch (reason) {
        CommitmentSignalReason.firstPersonPromise => firstPersonPromise,
        CommitmentSignalReason.explicitPromisePhrase => explicitPromisePhrase,
        CommitmentSignalReason.explicitRequestVerb => explicitRequestVerb,
        CommitmentSignalReason.directRecipient => directRecipient,
        CommitmentSignalReason.waitingLanguage => waitingLanguage,
        CommitmentSignalReason.actionVerbPresent => actionVerbPresent,
        CommitmentSignalReason.explicitDeadline => explicitDeadline,
        CommitmentSignalReason.weakTemporalSignal => weakTemporalSignal,
        CommitmentSignalReason.ambiguousActor => ambiguousActor,
      };
}

/// Turns one piece of Evidence's redacted text into a [CommitmentCandidate],
/// or decides there isn't one.
///
/// Pure and synchronous, the same discipline every deterministic policy in
/// this layer already holds to: no repository, no randomness, and no clock
/// read internally — [referenceTime] is supplied by the caller, the same way
/// [LoopStateMachine] takes `now` rather than reading one.
///
/// [sourceKind] exists for exactly one judgement this class cannot make from
/// text alone: whether "I" in a first-person promise, or "you" in a direct
/// request, refers to the user or to a counterparty. Evidence sourced from
/// [EvidenceSource.manual] is unambiguously the user's own words, so
/// `ClaimKind.oweDeliverable`/`awaitingResponse` can be assigned with
/// confidence. For every other source kind — email, message, calendar,
/// document, note — the current domain model has no field recording
/// whether a captured item was sent or received, so authorship of the "I"
/// or "you" in its text cannot be determined here at all. Rather than
/// guess, every such candidate is assigned `ClaimKind.other` and carries
/// [CommitmentSignalReason.ambiguousActor], which correspondingly lowers its
/// confidence. This is a real, documented limitation of what 3B's Evidence
/// captures today, not an oversight — closing it would mean adding a
/// sent/received distinction to [EvidenceSource] or `SourceRef`, which this
/// phase is not authorised to do.
///
/// [Claim.counterparty] is never set: naming a specific party would require
/// identity resolution this phase deliberately does not build.
class CommitmentCandidateDetector {
  const CommitmentCandidateDetector({
    this.rules = const CommitmentSignalRules(),
    this.temporal = const CommitmentTemporalSignals(),
    this.weights = const CommitmentConfidenceWeights(),
  });

  final CommitmentSignalRules rules;
  final CommitmentTemporalSignals temporal;
  final CommitmentConfidenceWeights weights;

  static const PolicyRef _ref = PolicyRef(
    id: 'commitment-detection',
    version: PolicyVersion('commitment-detection-v1'),
  );

  CommitmentCandidate? detect({
    required SourceSignal signal,
    required EvidenceSource sourceKind,
    required List<EvidenceId> evidence,
    required DateTime referenceTime,
  }) {
    final CommitmentSignalMatch? match = rules.match(signal.text);
    if (match == null) return null;

    final List<CommitmentSignalReason> reasons =
        List<CommitmentSignalReason>.of(
      match.reasons,
    );
    if (_authorshipIsAmbiguous(match, sourceKind) &&
        !reasons.contains(CommitmentSignalReason.ambiguousActor)) {
      reasons.add(CommitmentSignalReason.ambiguousActor);
    }

    final TemporalMatch? deadline = temporal.resolveDeadline(
      signal.text,
      referenceTime,
    );
    if (deadline != null) reasons.add(deadline.reason);

    final Claim claim = Claim(
      kind: _kindFor(match, sourceKind),
      by: deadline?.resolved,
      sourceQuote: match.sourceQuote,
    );

    double score = 0;
    for (final CommitmentSignalReason reason in reasons) {
      score += weights.weightOf(reason);
    }

    return CommitmentCandidate.identifiedBy(
      evidence: evidence,
      claim: claim,
      confidence: CandidateConfidence(score.clamp(0.0, 1.0)),
      reasons: reasons,
      producedBy: _ref,
      evaluatedAt: referenceTime,
    );
  }

  ClaimKind _kindFor(CommitmentSignalMatch match, EvidenceSource sourceKind) {
    if (sourceKind != EvidenceSource.manual) return ClaimKind.other;

    if (match.reasons.contains(CommitmentSignalReason.firstPersonPromise) ||
        match.reasons.contains(CommitmentSignalReason.explicitPromisePhrase)) {
      return ClaimKind.oweDeliverable;
    }
    if (match.reasons.contains(CommitmentSignalReason.waitingLanguage)) {
      return ClaimKind.awaitingResponse;
    }
    return ClaimKind.other;
  }

  bool _authorshipIsAmbiguous(
    CommitmentSignalMatch match,
    EvidenceSource sourceKind,
  ) {
    if (sourceKind == EvidenceSource.manual) return false;
    return match.reasons.contains(CommitmentSignalReason.firstPersonPromise) ||
        match.reasons.contains(CommitmentSignalReason.explicitPromisePhrase) ||
        match.reasons.contains(CommitmentSignalReason.explicitRequestVerb) ||
        match.reasons.contains(CommitmentSignalReason.waitingLanguage);
  }
}
