/// The shape of what a suggestion proposes doing.
///
/// Nine verbs, all information — none of them anything the domain can *do*.
/// There is no executor anywhere in this layer; producing a suggestion of any
/// kind here is exactly as inert as producing one of any other.
enum ActionKind {
  /// Bring a proposal into the open — review and confirm it.
  open,

  /// Look at something without acting on it.
  navigate,

  /// Prepare a reply or a document without sending it.
  draft,

  /// Respond to the counterparty.
  reply,

  /// Put a time on the calendar.
  schedule,

  /// A nudge with no outward effect — a notification to the user themselves.
  remind,

  /// Check two things against each other — used for closure verification.
  compare,

  /// Get something ready for a step that has not started yet.
  prepare,

  /// Carry out a concrete step. Still only ever a *suggestion* of this kind in
  /// 2B: there is no `ExecutableAction`, no executor, and no code path that
  /// turns this value into a running effect. See [SideEffectClass] for why a
  /// suggestion of this kind is not, by itself, dangerous.
  execute,
}

/// How far a suggestion's effect would reach if it were ever carried out.
///
/// This is the classification the architecture requires every suggestion to
/// carry, and the reason a suggestion is safe to *produce* regardless of its
/// [ActionKind]: nothing in 2B — or anywhere in this codebase yet — can act on
/// one. The class only becomes load-bearing once an executor exists to read it
/// and refuse the last two values without approval, which is 2B's boundary,
/// not its job.
enum SideEffectClass {
  /// Nothing leaves the device: looking, comparing, opening.
  none,

  /// Stays on the device but changes something local: a draft, a reminder.
  local,

  /// Another person would see it. Not reversible once real.
  outbound,

  /// Moves money. Not reversible once real, and the highest bar for approval
  /// when execution eventually exists.
  financial,
}
