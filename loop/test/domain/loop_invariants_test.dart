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

void main() {
  const LoopStateMachine machine = LoopStateMachine();

  Loop build({
    LoopState state = LoopState.open,
    String title = 'Send the signed lease',
    EvidenceId basis = basisId,
    List<EvidenceId> evidence = const <EvidenceId>[basisId],
    PartyId? waitingOn,
    DateTime? waitingSince,
    DateTime? resolvedAt,
    AbandonReason? abandonReason,
  }) =>
      Loop(
        id: loopId,
        title: title,
        state: state,
        basis: basis,
        evidence: evidence,
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
        waitingOn: waitingOn,
        waitingSince: waitingSince,
        resolvedAt: resolvedAt,
        abandonReason: abandonReason,
      );

  group('a loop that cannot exist cannot be built', () {
    test('waiting without naming who it waits on', () {
      expect(
        () => build(state: LoopState.waiting),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('waiting on someone while not waiting', () {
      expect(
        () => build(waitingOn: marina, waitingSince: t0),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('resolved without recording when', () {
      expect(
        () => build(state: LoopState.resolved),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('carrying a resolution date while not resolved', () {
      expect(
        () => build(resolvedAt: t0),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('abandoned without recording why', () {
      expect(
        () => build(state: LoopState.abandoned),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('a basis that is not among its own evidence', () {
      expect(
        () => build(evidence: const <EvidenceId>[EvidenceId('ev-other')]),
        throwsA(isA<LoopInvariantViolation>()),
      );
    });

    test('no title', () {
      expect(() => build(title: '   '), throwsA(isA<LoopInvariantViolation>()));
    });
  });

  group('transitions maintain the invariants they are responsible for', () {
    test('delegating names the party and the moment; escalating clears both',
        () {
      final DateTime delegatedAt = t0.add(const Duration(minutes: 10));
      final Loop waiting = machine
          .apply(
            loopIn(LoopState.open),
            const Delegate(waitingOn: marina),
            now: delegatedAt,
          )
          .unwrap
          .loop;

      expect(waiting.state, LoopState.waiting);
      expect(waiting.waitingOn, marina);
      expect(waiting.waitingSince, delegatedAt);

      final Loop back = machine
          .apply(
            waiting,
            const Escalate(),
            now: delegatedAt.add(const Duration(days: 3)),
          )
          .unwrap
          .loop;

      expect(back.state, LoopState.open);
      expect(back.waitingOn, isNull);
      expect(back.waitingSince, isNull);
    });

    test('completing stamps the moment; reopening clears it', () {
      final DateTime closedAt = t0.add(const Duration(hours: 2));
      final Loop resolved = machine
          .apply(loopIn(LoopState.open), const Complete(), now: closedAt)
          .unwrap
          .loop;

      expect(resolved.resolvedAt, closedAt);

      final Loop reopened = machine
          .apply(
            resolved,
            const Reopen(),
            now: closedAt.add(const Duration(days: 1)),
          )
          .unwrap
          .loop;

      expect(reopened.state, LoopState.open);
      expect(reopened.resolvedAt, isNull);
    });

    test('abandoning records the reason the caller gave', () {
      final Loop abandoned = machine
          .apply(
            loopIn(LoopState.open),
            const Abandon(reason: AbandonReason.noLongerRelevant),
            now: t0.add(const Duration(minutes: 1)),
          )
          .unwrap
          .loop;

      expect(abandoned.abandonReason, AbandonReason.noLongerRelevant);

      // Reopening clears it: a loop that is open again has no reason for not
      // happening.
      final Loop reopened = machine
          .apply(
            abandoned,
            const Reopen(),
            now: t0.add(const Duration(hours: 1)),
          )
          .unwrap
          .loop;
      expect(reopened.abandonReason, isNull);
    });

    test('rejecting a proposal is always the detector being wrong', () {
      final Loop abandoned = machine
          .apply(
            loopIn(LoopState.detected),
            const Reject(),
            now: t0.add(const Duration(minutes: 1)),
          )
          .unwrap
          .loop;

      // Distinct from "I changed my mind" on purpose: only this one is a
      // correction the detector can learn from.
      expect(abandoned.abandonReason, AbandonReason.notARealLoop);
    });
  });

  group('attaching evidence', () {
    test('grows what is known without moving the lifecycle', () {
      final Loop before = loopIn(LoopState.waiting);
      final DateTime now = t0.add(const Duration(hours: 6));

      final LoopOutcome out = machine
          .attachEvidence(before, const EvidenceId('ev-reply'), now: now)
          .unwrap;

      expect(out.loop.state, before.state, reason: 'not a transition');
      expect(out.loop.evidence, contains(const EvidenceId('ev-reply')));
      expect(out.loop.revision, before.revision + 1);
      expect(out.event.kind, LoopEventKind.evidenceAttached);
      expect(out.event.sequence, out.loop.revision);
      expect(out.event.evidence, const EvidenceId('ev-reply'));
      expect(out.event.from, isNull);
    });

    test('refuses a duplicate, and changes nothing when it does', () {
      final Loop before = loopIn(LoopState.open);
      final Result<LoopOutcome> result = machine.attachEvidence(
        before,
        basisId,
        now: t0.add(const Duration(minutes: 1)),
      );

      expect(result.isErr, isTrue);
      expect(result.failureOrNull, isA<OperationRefused>());
      expect(before.evidence.length, 1);
      expect(before.revision, 1);
    });
  });
}
