import 'package:flutter_test/flutter_test.dart';
import 'package:loop/domain/failures.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/domain/loop/loop_transition.dart';
import 'package:loop/domain/result.dart';

import 'fixtures.dart';

/// One instance of every verb, so the matrix can be generated rather than
/// listed. The names are frozen below; adding a verb without adding it here
/// fails the completeness test, which is the point.
final List<LoopTransition> allTransitions = <LoopTransition>[
  const Confirm(),
  const Reject(),
  const ExpireProposal(),
  const Start(),
  const Delegate(waitingOn: marina),
  const Execute(),
  const AbandonAttempt(),
  const ReplyDetected(),
  const Escalate(),
  const ConfirmClosure(),
  const RejectClosure(),
  const Complete(),
  const Abandon(reason: AbandonReason.decidedNotTo),
  const Reopen(),
];

/// Every legal pair, and nothing else. Anything absent from this map is
/// expected to be refused — so the table is a specification, not a summary.
const Map<String, LoopState> legal = <String, LoopState>{
  'detected/confirm': LoopState.open,
  'detected/reject': LoopState.abandoned,
  'detected/expireProposal': LoopState.abandoned,
  'open/start': LoopState.inProgress,
  'open/delegate': LoopState.waiting,
  'open/complete': LoopState.resolved,
  'open/abandon': LoopState.abandoned,
  'waiting/replyDetected': LoopState.verifying,
  'waiting/escalate': LoopState.open,
  'waiting/complete': LoopState.resolved,
  'waiting/abandon': LoopState.abandoned,
  'inProgress/execute': LoopState.verifying,
  'inProgress/abandonAttempt': LoopState.open,
  'inProgress/complete': LoopState.resolved,
  'verifying/confirmClosure': LoopState.resolved,
  'verifying/rejectClosure': LoopState.open,
  'verifying/delegate': LoopState.waiting,
  'resolved/reopen': LoopState.open,
  'abandoned/reopen': LoopState.open,
};

void main() {
  const LoopStateMachine machine = LoopStateMachine();

  group('the matrix is complete', () {
    test('every state and every verb is accounted for', () {
      // If someone adds an eighth state or a fifteenth verb, this fails until
      // they have decided what it does from everywhere — which is the whole
      // reason the matrix is generated instead of hand-written.
      expect(
        LoopState.values.length,
        7,
        reason: 'a state was added or removed',
      );
      expect(allTransitions.length, 14, reason: 'a verb was added or removed');
      expect(
        allTransitions.map((LoopTransition t) => t.name).toSet().length,
        allTransitions.length,
        reason: 'two verbs share a name',
      );
      for (final String key in legal.keys) {
        final List<String> parts = key.split('/');
        expect(
          LoopState.values.map((LoopState s) => s.name),
          contains(parts.first),
        );
        expect(
          allTransitions.map((LoopTransition t) => t.name),
          contains(parts.last),
        );
      }
    });
  });

  group('every (state × transition) pair behaves as declared', () {
    for (final LoopState from in LoopState.values) {
      for (final LoopTransition transition in allTransitions) {
        final String key = '${from.name}/${transition.name}';
        final LoopState? expected = legal[key];

        test('$key → ${expected?.name ?? 'refused'}', () {
          final Loop before = loopIn(from);
          final Result<LoopOutcome> result = machine.apply(
            before,
            transition,
            now: t0.add(const Duration(minutes: 5)),
          );

          if (expected == null) {
            expect(result.isErr, isTrue, reason: '$key should be illegal');
            expect(result.failureOrNull, isA<IllegalTransition>());
            return;
          }

          expect(
            result.isOk,
            isTrue,
            reason: '$key should be legal, got ${result.failureOrNull}',
          );
          expect(result.unwrap.loop.state, expected);
        });
      }
    }
  });

  group('a valid transition', () {
    test('produces exactly one event, numbered by the new revision', () {
      final Loop before = loopIn(LoopState.open);
      final DateTime now = t0.add(const Duration(hours: 1));

      final LoopOutcome out =
          machine.apply(before, const Start(), now: now).unwrap;

      expect(out.loop.revision, before.revision + 1);
      expect(out.event.sequence, out.loop.revision);
      expect(out.event.kind, LoopEventKind.stateChanged);
      expect(out.event.from, LoopState.open);
      expect(out.event.to, LoopState.inProgress);
      expect(out.event.at, now);
      expect(out.event.actor, TransitionActor.user);
      expect(out.event.loop, before.id);
    });

    test('records the actor it was given, not a default', () {
      final LoopOutcome out = machine
          .apply(
            loopIn(LoopState.waiting),
            const ReplyDetected(),
            now: t0.add(const Duration(days: 1)),
          )
          .unwrap;

      expect(out.event.actor, TransitionActor.externalEvent);
    });
  });

  group('a refused transition', () {
    test('changes nothing at all', () {
      final Loop before = loopIn(LoopState.detected);
      final Result<LoopOutcome> result = machine.apply(
        before,
        const Execute(),
        now: t0.add(const Duration(minutes: 1)),
      );

      expect(result.isErr, isTrue);
      // The caller still holds exactly what it had: no partially applied
      // state, because the new loop is only built once every check passes.
      expect(before.state, LoopState.detected);
      expect(before.revision, 1);
      expect(before.updatedAt, t0);
      expect(before.resolvedAt, isNull);
    });

    test('names the state and the verb it refused', () {
      final IllegalTransition failure = machine
          .apply(
            loopIn(LoopState.resolved),
            const Start(),
            now: t0.add(const Duration(minutes: 1)),
          )
          .failureOrNull! as IllegalTransition;

      expect(failure.from, LoopState.resolved);
      expect(failure.transition, isA<Start>());
      expect(failure.debugMessage, contains('start'));
    });
  });

  group('genesis', () {
    test('a detected loop starts in detected, with its basis as evidence', () {
      final LoopOutcome out = machine.detect(
        id: loopId,
        title: 'Send the signed lease',
        basis: basisId,
        now: t0,
      );

      expect(out.loop.state, LoopState.detected);
      expect(out.loop.basis, basisId);
      expect(out.loop.evidence, <EvidenceId>[basisId]);
      expect(out.loop.revision, 1);
      expect(out.event.kind, LoopEventKind.detected);
      expect(out.event.sequence, 1);
      expect(out.event.evidence, basisId);
    });

    test('a loop the person created starts open, and still cites evidence', () {
      final LoopOutcome out = machine.create(
        id: loopId,
        title: 'Call the dentist',
        basis: const EvidenceId('ev-assertion'),
        now: t0,
      );

      expect(out.loop.state, LoopState.open);
      expect(out.event.kind, LoopEventKind.created);
      expect(out.event.actor, TransitionActor.user);
      // The rule holds with no exception for manual entry: what grounds it is
      // the person's own assertion.
      expect(out.loop.evidence, contains(out.loop.basis));
    });
  });
}
