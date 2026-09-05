/// Where a Commitment sits in its own, much smaller lifecycle.
///
/// Four values, not seven: a Commitment is durable semantic truth about an
/// obligation, not the operational tracking [Loop] already owns, and it does
/// not need [Loop]'s reasons to move — no waiting-on-a-party state, no
/// in-progress, no verification. The states an uncertain detector would
/// produce — a candidate not yet confirmed, one already rejected — never
/// reach this type at all: `CommitmentCandidate` is deliberately deferred,
/// so every value here describes a Commitment that is already real.
enum CommitmentStatus {
  /// Confirmed and still owed. The only non-terminal value, and the only one
  /// a [Commitment] may be constructed with — there is no factory for
  /// starting anywhere else, the same way there is no public path to a
  /// [Loop] that skips [LoopStateMachine].
  active,

  /// Delivered.
  fulfilled,

  /// Will not happen.
  cancelled,

  /// Replaced by a later Commitment — see [Commitment.supersededBy].
  superseded;

  /// Once left, only by constructing a new Commitment — never by returning
  /// to [active]. Terminal semantic history is not rewritten backwards; a
  /// Commitment that needs to become live again is future revision work,
  /// not a transition this type offers.
  bool get isTerminal => this != CommitmentStatus.active;
}
