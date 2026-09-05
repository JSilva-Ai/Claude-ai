import 'commitment/commitment_status.dart';
import 'ids.dart';
import 'loop/loop_state.dart';
import 'loop/loop_transition.dart';

/// What the domain answers when an operation is refused.
///
/// Refusals are values, not exceptions: a transition arriving from an external
/// event may legitimately be impossible, and that is an outcome to record, not
/// a crash. The one thing that does throw is [LoopInvariantViolation] —
/// constructing a loop that cannot exist is a programming error, and an error
/// that returns a value can be ignored.
sealed class LoopFailure {
  const LoopFailure();

  /// A sentence for a log or a test, never for a screen. The domain has no
  /// user-facing text; the presentation layer turns a failure into words in
  /// the reader's language.
  String get debugMessage;
}

final class IllegalTransition extends LoopFailure {
  const IllegalTransition({required this.from, required this.transition});

  final LoopState from;
  final LoopTransition transition;

  @override
  String get debugMessage =>
      'Transition ${transition.name} is not legal from ${from.name}';

  @override
  String toString() => 'IllegalTransition($debugMessage)';
}

/// The transition is legal for the state but its own precondition is not met —
/// delegating without naming who is being waited on, for instance.
final class TransitionPreconditionUnmet extends LoopFailure {
  const TransitionPreconditionUnmet({
    required this.transition,
    required this.reason,
  });

  final LoopTransition transition;
  final String reason;

  @override
  String get debugMessage => '${transition.name} refused: $reason';

  @override
  String toString() => 'TransitionPreconditionUnmet($debugMessage)';
}

/// An operation that is not a lifecycle transition was refused — attaching
/// evidence that is already attached, for instance. Kept apart from
/// [TransitionPreconditionUnmet] so a failure never has to name a transition
/// that was never attempted.
final class OperationRefused extends LoopFailure {
  const OperationRefused(this.reason);

  final String reason;

  @override
  String get debugMessage => reason;

  @override
  String toString() => 'OperationRefused($reason)';
}

/// A Commitment's own status transition was refused — attempting a move
/// that is not legal from its current status. Kept apart from
/// [IllegalTransition], which is typed to [LoopState]/[LoopTransition] and
/// cannot represent a [CommitmentStatus] move without a mismatch, and apart
/// from [OperationRefused], whose own doc reserves it for refusals that are
/// not lifecycle transitions — a Commitment status change is exactly that.
final class IllegalCommitmentTransition extends LoopFailure {
  const IllegalCommitmentTransition({required this.from, required this.to});

  final CommitmentStatus from;
  final CommitmentStatus to;

  @override
  String get debugMessage =>
      'A commitment cannot move from ${from.name} to ${to.name}';

  @override
  String toString() => 'IllegalCommitmentTransition($debugMessage)';
}

final class UnknownEvidence extends LoopFailure {
  const UnknownEvidence(this.id);

  final EvidenceId id;

  @override
  String get debugMessage => 'No evidence resolves for $id';

  @override
  String toString() => 'UnknownEvidence($debugMessage)';
}

/// Thrown, not returned. A [Loop] that violates its own invariants is a bug in
/// the code that built it, and the only safe thing to do with a bug is stop.
final class LoopInvariantViolation extends Error {
  LoopInvariantViolation(this.message);

  final String message;

  @override
  String toString() => 'LoopInvariantViolation: $message';
}
