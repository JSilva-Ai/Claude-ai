/// Where a loop sits in its lifecycle.
///
/// Seven values, and the count is a decision rather than an accident. A value
/// earns a place here only if it changes by an *event* rather than by the
/// clock, changes *which transitions are legal*, and cannot be recomputed from
/// other data. Risk, priority, suppression and staleness fail that test — they
/// are read, not stored, and they live in the policies.
enum LoopState {
  /// The engine believes there is a commitment; the person has not confirmed.
  /// The gate that stops a detector from filling someone's list with noise.
  detected,

  /// Acknowledged, and the ball is with the user.
  open,

  /// The ball is with someone else. Requires a party and a since-when.
  waiting,

  /// An attempt is under way. Exists for a mechanical reason as much as a
  /// visual one: it is the lock that stops the same outbound act happening
  /// twice when execution arrives in a later phase.
  inProgress,

  /// Something was done and it is not yet known whether it closed the loop.
  /// This is the state that separates a completion engine from a checkbox.
  verifying,

  /// Closed, with a moment attached.
  resolved,

  /// Will not happen, with a reason attached.
  abandoned;

  /// Terminal states can only be left by reopening.
  bool get isTerminal => this == resolved || this == abandoned;

  /// Still counts as work in the world.
  bool get isActive =>
      this == open ||
      this == waiting ||
      this == inProgress ||
      this == verifying;
}

/// Why a loop will not happen.
///
/// Required on every abandonment, and not decoration: `notARealLoop` is the
/// engine being wrong and is training signal, while `decidedNotTo` is a person
/// changing their mind and teaches nothing about detection. Collapsing them
/// would throw away the only correction the detector ever gets.
enum AbandonReason {
  /// The detection was wrong — there was never a commitment here.
  notARealLoop,

  /// It was real and no longer matters.
  noLongerRelevant,

  /// It is real, it matters, and the person chose not to.
  decidedNotTo,

  /// A proposal nobody ever acted on, closed by reconciliation. Never written
  /// by a timer; see `StalenessPolicy` and `LoopTransition.expireProposal`.
  expired,
}

/// Who caused a transition.
///
/// Recorded on every event because "why did this change?" is a question the
/// product must be able to answer, and "the system did it" is only an
/// acceptable answer when the system can say which act of its own it was.
enum TransitionActor {
  user,

  /// An explicit reconciliation pass — app open, manual refresh. Never a timer
  /// firing in the background.
  systemReconciliation,

  /// Something observed outside the app: a reply arriving, for instance.
  externalEvent,
}
