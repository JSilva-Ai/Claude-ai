import '../evidence/data_sensitivity.dart';
import '../failures.dart';
import '../ids.dart';
import '../result.dart';
import 'loop.dart';
import 'loop_event.dart';
import 'loop_state.dart';
import 'loop_transition.dart';

/// A loop after a change, and the single event that records it.
///
/// The two travel together so they cannot be separated by accident: whoever
/// persists the loop has the event in hand, and the store's only mutation path
/// writes both or neither. That is what keeps the log from drifting away from
/// the state it is supposed to explain.
class LoopOutcome {
  const LoopOutcome({required this.loop, required this.event});

  final Loop loop;
  final LoopEvent event;

  @override
  String toString() => 'LoopOutcome($loop, $event)';
}

/// The lifecycle, as a table.
///
/// Two properties this file is built to guarantee:
///
/// * **Nothing here reads a clock.** Every operation takes `now`. The passage of
///   time therefore cannot move a loop by itself — only an act with an author
///   can, and every act leaves an event saying who.
/// * **A refusal changes nothing.** An illegal transition returns a failure and
///   the caller still holds the original loop; there is no partially applied
///   state, because a new loop is only constructed once every check has passed.
class LoopStateMachine {
  const LoopStateMachine();

  /// A loop the engine proposes. Born in `detected`: nothing may act on it
  /// until a person says it is real.
  LoopOutcome detect({
    required LoopId id,
    required String title,
    required EvidenceId basis,
    required DateTime now,
    DataSensitivity sensitivity = DataSensitivity.ordinary,
    CommitmentId? commitment,
  }) =>
      _genesis(
        id: id,
        title: title,
        basis: basis,
        state: LoopState.detected,
        kind: LoopEventKind.detected,
        actor: TransitionActor.systemReconciliation,
        now: now,
        sensitivity: sensitivity,
        commitment: commitment,
      );

  /// A loop the person entered. Born `open` — they have already confirmed it by
  /// typing it — and its basis is their own assertion, so the rule that every
  /// loop points at evidence holds here too.
  LoopOutcome create({
    required LoopId id,
    required String title,
    required EvidenceId basis,
    required DateTime now,
    DataSensitivity sensitivity = DataSensitivity.ordinary,
    CommitmentId? commitment,
  }) =>
      _genesis(
        id: id,
        title: title,
        basis: basis,
        state: LoopState.open,
        kind: LoopEventKind.created,
        actor: TransitionActor.user,
        now: now,
        sensitivity: sensitivity,
        commitment: commitment,
      );

  /// Applies a transition, or refuses it.
  Result<LoopOutcome> apply(
    Loop loop,
    LoopTransition transition, {
    required DateTime now,
  }) {
    final LoopState from = loop.state;
    final LoopState? to = target(from, transition);
    if (to == null) {
      return Err<LoopOutcome>(
        IllegalTransition(from: from, transition: transition),
      );
    }

    final LoopFailure? precondition = _precondition(loop, transition, now: now);
    if (precondition != null) return Err<LoopOutcome>(precondition);

    final Loop next = loop.copyWith(
      state: to,
      updatedAt: now,
      stateChangedAt: now,
      revision: loop.revision + 1,
      waitingOn: to == LoopState.waiting ? _waitingOn(transition) : null,
      waitingSince: to == LoopState.waiting ? now : null,
      clearWaiting: to != LoopState.waiting,
      resolvedAt: to == LoopState.resolved ? now : null,
      clearResolved: to != LoopState.resolved,
      abandonReason: to == LoopState.abandoned ? _reason(transition) : null,
      clearAbandonReason: to != LoopState.abandoned,
    );

    return Ok<LoopOutcome>(
      LoopOutcome(
        loop: next,
        event: LoopEvent(
          loop: loop.id,
          sequence: next.revision,
          kind: LoopEventKind.stateChanged,
          actor: transition.actor,
          at: now,
          from: from,
          to: to,
          reason: next.abandonReason,
        ),
      ),
    );
  }

  /// Records that something new bears on this loop.
  ///
  /// Not a transition: what a loop is *known by* can grow without its place in
  /// the lifecycle moving at all. It still produces exactly one event, because
  /// the reason for knowing more is itself part of the explanation.
  Result<LoopOutcome> attachEvidence(
    Loop loop,
    EvidenceId evidence, {
    required DateTime now,
    TransitionActor actor = TransitionActor.externalEvent,
  }) {
    if (loop.evidence.contains(evidence)) {
      return Err<LoopOutcome>(
        OperationRefused('evidence $evidence is already attached'),
      );
    }
    if (now.isBefore(loop.updatedAt)) {
      return const Err<LoopOutcome>(
        OperationRefused('now precedes the loop it is applied to'),
      );
    }

    final Loop next = loop.copyWith(
      evidence: <EvidenceId>[...loop.evidence, evidence],
      updatedAt: now,
      revision: loop.revision + 1,
    );

    return Ok<LoopOutcome>(
      LoopOutcome(
        loop: next,
        event: LoopEvent(
          loop: loop.id,
          sequence: next.revision,
          kind: LoopEventKind.evidenceAttached,
          actor: actor,
          at: now,
          evidence: evidence,
        ),
      ),
    );
  }

  /// The whole table, in one place.
  ///
  /// Public because the test suite generates the full (state × transition)
  /// matrix from it: every pair must have a declared expectation, so adding a
  /// state or a verb breaks the tests until it has been thought about.
  static LoopState? target(LoopState from, LoopTransition transition) =>
      switch ((from, transition)) {
        (LoopState.detected, Confirm()) => LoopState.open,
        (LoopState.detected, Reject()) => LoopState.abandoned,
        (LoopState.detected, ExpireProposal()) => LoopState.abandoned,
        (LoopState.open, Start()) => LoopState.inProgress,
        (LoopState.open, Delegate()) => LoopState.waiting,
        (LoopState.open, Complete()) => LoopState.resolved,
        (LoopState.open, Abandon()) => LoopState.abandoned,
        (LoopState.waiting, ReplyDetected()) => LoopState.verifying,
        (LoopState.waiting, Escalate()) => LoopState.open,
        (LoopState.waiting, Complete()) => LoopState.resolved,
        (LoopState.waiting, Abandon()) => LoopState.abandoned,
        (LoopState.inProgress, Execute()) => LoopState.verifying,
        (LoopState.inProgress, AbandonAttempt()) => LoopState.open,
        (LoopState.inProgress, Complete()) => LoopState.resolved,

        // Acting is not closing. A loop leaves verifying for resolved only when
        // something says it actually closed; the other two exits are "it did
        // not" and "it started a new wait".
        (LoopState.verifying, ConfirmClosure()) => LoopState.resolved,
        (LoopState.verifying, RejectClosure()) => LoopState.open,
        (LoopState.verifying, Delegate()) => LoopState.waiting,
        (LoopState.resolved, Reopen()) => LoopState.open,
        (LoopState.abandoned, Reopen()) => LoopState.open,
        _ => null,
      };

  LoopFailure? _precondition(
    Loop loop,
    LoopTransition transition, {
    required DateTime now,
  }) {
    // Time may not run backwards over a loop's own history: an event dated
    // before the state it changes would make the log unreadable in order.
    if (now.isBefore(loop.updatedAt)) {
      return TransitionPreconditionUnmet(
        transition: transition,
        reason: 'now precedes the loop it is applied to',
      );
    }

    // Expiry is a decision the system makes in a named pass, never a person's
    // verb and never a timer's. Anything else claiming to expire a proposal is
    // refused rather than quietly accepted.
    if (transition is ExpireProposal &&
        transition.actor != TransitionActor.systemReconciliation) {
      return TransitionPreconditionUnmet(
        transition: transition,
        reason: 'a proposal expires only in a reconciliation pass',
      );
    }

    return null;
  }

  PartyId? _waitingOn(LoopTransition transition) =>
      transition is Delegate ? transition.waitingOn : null;

  AbandonReason? _reason(LoopTransition transition) => switch (transition) {
        Reject() => AbandonReason.notARealLoop,
        ExpireProposal() => AbandonReason.expired,
        Abandon(:final AbandonReason reason) => reason,
        _ => null,
      };

  LoopOutcome _genesis({
    required LoopId id,
    required String title,
    required EvidenceId basis,
    required LoopState state,
    required LoopEventKind kind,
    required TransitionActor actor,
    required DateTime now,
    required DataSensitivity sensitivity,
    CommitmentId? commitment,
  }) {
    final Loop loop = Loop(
      id: id,
      title: title,
      state: state,
      basis: basis,
      evidence: <EvidenceId>[basis],
      commitment: commitment,
      sensitivity: sensitivity,
      createdAt: now,
      updatedAt: now,
      stateChangedAt: now,
    );

    return LoopOutcome(
      loop: loop,
      event: LoopEvent(
        loop: id,
        sequence: loop.revision,
        kind: kind,
        actor: actor,
        at: now,
        to: state,
        evidence: basis,
      ),
    );
  }
}
