/// How hard it currently is for the user to move a loop forward.
///
/// **Deferred.** This file is the extension point, not an implementation —
/// per the brief, fabricating a friction score from data the domain does not
/// have would be worse than having none.
///
/// The architecture names the signals friction would need: an external
/// dependency, a step count, missing information, waiting on a third party, an
/// action available right now. [LoopSignals] (2B) can only honestly speak to
/// one of those — [LoopSignals.hasCounterparty] / [LoopSignals.waitingFor],
/// which [RiskAssessment.reasons] and [AttentionAssessment.reasons] already
/// cover as `waitingTooLong`. The rest require entities this phase does not
/// build:
///
/// * **step count / missing information** — needs [NextAction]'s shape to be
///   rich enough to say what is missing, which is closer to 2B's own
///   [ActionSuggestion] than to a loop-level signal. Once suggestions carry
///   preconditions, friction can read them.
/// * **external dependency** — needs the commitment graph (`dependsOn`
///   relations), out of scope until the graph exists.
/// * **action available immediately** — needs to know whether a suggestion's
///   [SideEffectClass] is `none`/`local` (no approval friction) versus
///   `outbound`/`financial` (approval friction) — meaningful once suggestion
///   generation is real, not before.
///
/// A single-value placeholder (`unknown`, always) was considered and rejected:
/// a type inhabited by one value teaches nothing and invites a caller to
/// pattern-match on it as though it might vary. The contract below is what a
/// future policy will have to satisfy; nothing implements it yet.
abstract interface class FrictionPolicy<TSignals, TAssessment> {
  TAssessment evaluate(TSignals signals);
}
