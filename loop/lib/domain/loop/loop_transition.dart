import '../ids.dart';
import 'loop_state.dart';

/// The verbs.
///
/// Sealed, so the state machine's `switch` is exhaustive and a new verb cannot
/// be added without every table that handles verbs failing to compile. Each
/// carries the data its own precondition needs — [Delegate] cannot be
/// constructed without naming who is being waited on — which removes a whole
/// class of invalid transition before the machine is even asked.
sealed class LoopTransition {
  const LoopTransition({required this.actor});

  /// Who is doing this. Defaulted nowhere: an unattributed change to someone's
  /// commitments is not something this system should be able to express.
  final TransitionActor actor;

  /// A stable identifier for logs and tests. Not user-facing copy.
  String get name;
}

/// detected → open. The person says "yes, this is real".
final class Confirm extends LoopTransition {
  const Confirm({super.actor = TransitionActor.user});

  @override
  String get name => 'confirm';
}

/// detected → abandoned(notARealLoop). The detector was wrong.
final class Reject extends LoopTransition {
  const Reject({super.actor = TransitionActor.user});

  @override
  String get name => 'reject';
}

/// detected → abandoned(expired), and only from a reconciliation pass.
///
/// This is how a proposal nobody answered goes away *without the clock mutating
/// anything*: staleness is a predicate the reader evaluates, and the mutation
/// happens once, in a named pass, with an actor and an event.
final class ExpireProposal extends LoopTransition {
  const ExpireProposal({super.actor = TransitionActor.systemReconciliation});

  @override
  String get name => 'expireProposal';
}

/// open → inProgress. An attempt begins.
final class Start extends LoopTransition {
  const Start({super.actor = TransitionActor.user});

  @override
  String get name => 'start';
}

/// open → waiting, or verifying → waiting when the attempt produced a new wait.
final class Delegate extends LoopTransition {
  const Delegate({required this.waitingOn, super.actor = TransitionActor.user});

  final PartyId waitingOn;

  @override
  String get name => 'delegate';
}

/// inProgress → verifying. Something was done; whether it closed the loop is
/// not yet known.
final class Execute extends LoopTransition {
  const Execute({super.actor = TransitionActor.user});

  @override
  String get name => 'execute';
}

/// inProgress → open. The attempt was dropped.
final class AbandonAttempt extends LoopTransition {
  const AbandonAttempt({super.actor = TransitionActor.user});

  @override
  String get name => 'abandonAttempt';
}

/// waiting → verifying. A reply was observed.
final class ReplyDetected extends LoopTransition {
  const ReplyDetected({super.actor = TransitionActor.externalEvent});

  @override
  String get name => 'replyDetected';
}

/// waiting → open. The wait has gone on long enough; the ball comes back.
///
/// Raised by a person or by a reconciliation pass — never by a timer.
final class Escalate extends LoopTransition {
  const Escalate({super.actor = TransitionActor.user});

  @override
  String get name => 'escalate';
}

/// verifying → resolved. There is evidence the loop actually closed.
final class ConfirmClosure extends LoopTransition {
  const ConfirmClosure({super.actor = TransitionActor.user});

  @override
  String get name => 'confirmClosure';
}

/// verifying → open. It did not close; something else is needed.
final class RejectClosure extends LoopTransition {
  const RejectClosure({super.actor = TransitionActor.user});

  @override
  String get name => 'rejectClosure';
}

/// open · waiting · inProgress → resolved. The person says it is done.
final class Complete extends LoopTransition {
  const Complete({super.actor = TransitionActor.user});

  @override
  String get name => 'complete';
}

/// open · waiting → abandoned, with a reason that is never inferred.
final class Abandon extends LoopTransition {
  const Abandon({required this.reason, super.actor = TransitionActor.user});

  final AbandonReason reason;

  @override
  String get name => 'abandon';
}

/// resolved · abandoned → open.
final class Reopen extends LoopTransition {
  const Reopen({super.actor = TransitionActor.user});

  @override
  String get name => 'reopen';
}
