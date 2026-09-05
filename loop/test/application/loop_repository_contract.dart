import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/loop_repository.dart';
import 'package:loop/application/persistence_failure.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/domain/loop/loop_transition.dart';
import 'package:loop/domain/result.dart';

import '../domain/fixtures.dart';

/// The observable contract every [LoopRepository] must satisfy, run once per
/// implementation. Not a test of internal shape — [InMemoryLoopRepository]
/// and [DriftLoopRepository] store nothing alike — only of what a caller on
/// the other side of the interface can see.
///
/// [createRepository] must return a fresh, empty repository each call.
void runLoopRepositoryContractTests({
  required String label,
  required LoopRepository Function() createRepository,
}) {
  group('LoopRepository contract ($label)', () {
    late LoopRepository repo;
    const LoopStateMachine machine = LoopStateMachine();

    setUp(() {
      repo = createRepository();
    });

    test('a newly created loop can be stored and read back whole', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome outcome = machine.create(
        id: loopId,
        title: 'Send the signed lease',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(outcome, newEvidence: <Evidence>[basis]);

      final Loop? stored = await repo.getLoop(loopId);
      expect(stored, isNotNull);
      expect(stored!.title, 'Send the signed lease');
      expect(stored.state, LoopState.open);
      expect(stored.basis, basisId);
      expect(stored.evidence, <EvidenceId>[basisId]);
      expect(stored.revision, 1);
    });

    test('getLoop answers null for an id that was never stored', () async {
      expect(await repo.getLoop(const LoopId('never-created')), isNull);
    });

    test(
        'watchLoops emits the current loops to a new subscriber '
        'immediately', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome outcome = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(outcome, newEvidence: <Evidence>[basis]);

      final List<Loop> first = await repo.watchLoops().first;
      expect(first.map((Loop l) => l.id), contains(loopId));
    });

    test('watchLoops emits again after a write', () async {
      final List<int> emittedCounts = <int>[];
      final Stream<List<Loop>> stream = repo.watchLoops();
      final subscription = stream.listen(
        (List<Loop> loops) => emittedCounts.add(loops.length),
      );
      await Future<void>.delayed(Duration.zero);

      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome outcome = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(outcome, newEvidence: <Evidence>[basis]);
      await Future<void>.delayed(Duration.zero);

      expect(emittedCounts, contains(1));
      await subscription.cancel();
    });

    test('evidence attached to a loop reads back unchanged', () async {
      final ObservedFact basis = fact(
        id: basisId.value,
        excerpt: "I'll send it Friday",
      );
      final LoopOutcome outcome = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(outcome, newEvidence: <Evidence>[basis]);

      final List<Evidence> evidence = await repo.readEvidence(loopId);
      expect(evidence, hasLength(1));
      expect(evidence.single, isA<ObservedFact>());
      expect((evidence.single as ObservedFact).excerpt, "I'll send it Friday");
    });

    test('Inference provenance is reconstructable after storage', () async {
      final ObservedFact source = fact(id: 'ev-source');
      final Inference derivedInference = inference(
        id: 'ev-inf',
        from: <String>['ev-source'],
      );
      final LoopOutcome outcome = machine.create(
        id: loopId,
        title: 'x',
        basis: derivedInference.id,
        now: t0,
      );
      await repo.saveOutcome(
        outcome,
        newEvidence: <Evidence>[source, derivedInference],
      );

      final Evidence? resolved = await repo.getEvidenceById(
        derivedInference.id,
      );
      expect(resolved, isA<Inference>());
      expect(
        (resolved as Inference).derivedFrom,
        <EvidenceId>[const EvidenceId('ev-source')],
      );
    });

    test(
        'a UserAssertion confirming an inference persists alongside it, '
        'and the inference is not rewritten', () async {
      final ObservedFact source = fact(id: 'ev-fact');
      final Inference judged =
          inference(id: 'ev-inf', from: <String>['ev-fact']);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: judged.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[source, judged]);

      final UserAssertion confirmation = assertion(
        id: 'ev-confirm',
        kind: AssertionKind.confirms,
        about: 'ev-inf',
      );
      final Result<LoopOutcome> attached = machine.attachEvidence(
        created.loop,
        confirmation.id,
        now: t0.add(const Duration(minutes: 1)),
      );
      expect(attached.isOk, isTrue);
      await repo.saveOutcome(
        attached.unwrap,
        newEvidence: <Evidence>[confirmation],
      );

      final Evidence? judgedAfter = await repo.getEvidenceById(judged.id);
      expect(judgedAfter, isA<Inference>());
      expect((judgedAfter as Inference).confidence, judged.confidence);

      final Loop? loopAfter = await repo.getLoop(loopId);
      expect(
        loopAfter!.evidence,
        containsAll(<EvidenceId>[judged.id, confirmation.id]),
      );
    });

    test('event history is returned in sequence order', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final Result<LoopOutcome> started = machine.apply(
        created.loop,
        const Start(),
        now: t0.add(const Duration(minutes: 1)),
      );
      await repo.saveOutcome(started.unwrap);

      final List<LoopEvent> events = await repo.readEvents(loopId);
      expect(events.map((LoopEvent e) => e.sequence), <int>[1, 2]);
      expect(
        events.map((LoopEvent e) => e.kind),
        <LoopEventKind>[LoopEventKind.created, LoopEventKind.stateChanged],
      );
    });

    test(
        'a transition persists the loop\'s new state and its event '
        'together', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final Result<LoopOutcome> started = machine.apply(
        created.loop,
        const Start(),
        now: t0.add(const Duration(minutes: 1)),
      );
      await repo.saveOutcome(started.unwrap);

      final Loop? loop = await repo.getLoop(loopId);
      expect(loop!.state, LoopState.inProgress);
      expect(await repo.readEvents(loopId), hasLength(2));
    });

    test(
        'a write that collides on (loop, sequence) is refused and leaves '
        'neither the state nor the event count changed', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      // A colliding write: reuses sequence 1, but carries a loop mutation
      // that would be visible if the state write were not rolled back with
      // it — this is what proves atomicity rather than merely proving the
      // event insert alone was refused.
      final LoopOutcome colliding = LoopOutcome(
        loop: created.loop.copyWith(title: 'SHOULD NOT PERSIST'),
        event: LoopEvent(
          loop: loopId,
          sequence: 1,
          kind: LoopEventKind.created,
          actor: TransitionActor.user,
          at: t0,
        ),
      );

      await expectLater(
        () => repo.saveOutcome(colliding),
        throwsA(isA<PersistenceConstraintViolation>()),
      );

      final Loop? loop = await repo.getLoop(loopId);
      expect(loop!.title, isNot('SHOULD NOT PERSIST'));
      expect(await repo.readEvents(loopId), hasLength(1));
    });

    test(
        'saveOutcome refuses newEvidence whose id already exists in '
        'storage', () async {
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final Result<LoopOutcome> attached = machine.attachEvidence(
        created.loop,
        const EvidenceId('ev-new'),
        now: t0.add(const Duration(minutes: 1)),
      );
      // A caller bug, deliberately: claims to attach a new evidence id but
      // hands over an Evidence object that reuses one already in storage.
      final Evidence duplicateReuse = fact(
        id: basisId.value,
        excerpt: 'different content entirely',
      );

      await expectLater(
        () => repo.saveOutcome(
          attached.unwrap,
          newEvidence: <Evidence>[duplicateReuse],
        ),
        throwsA(isA<PersistenceConstraintViolation>()),
      );
    });
  });
}
