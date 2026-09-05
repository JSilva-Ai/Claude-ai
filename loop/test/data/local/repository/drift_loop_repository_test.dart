import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/loop_repository.dart';
import 'package:loop/application/persistence_failure.dart';
import 'package:loop/data/local/database/loop_database.dart';
import 'package:loop/data/local/repository/drift_loop_repository.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_state.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/domain/loop/loop_transition.dart';

import '../../../domain/fixtures.dart';
import '../../../application/loop_repository_contract.dart';

void main() {
  runLoopRepositoryContractTests(
    label: 'drift',
    createRepository: () =>
        DriftLoopRepository(LoopDatabase(NativeDatabase.memory())),
  );

  const LoopStateMachine machine = LoopStateMachine();

  group('DriftLoopRepository, behaviour specific to a real store', () {
    test(
        'data written before closing the database is still there after '
        'reopening the same file', () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'drift_loop_repository_test_',
      );
      final File dbFile = File('${tempDir.path}/loop.sqlite');
      addTearDown(() => tempDir.delete(recursive: true));

      final DriftLoopRepository first = DriftLoopRepository(
        LoopDatabase(NativeDatabase(dbFile)),
      );
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'Reopen me',
        basis: basis.id,
        now: t0,
      );
      await first.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final DriftLoopRepository reopened = DriftLoopRepository(
        LoopDatabase(NativeDatabase(dbFile)),
      );
      final Loop? loop = await reopened.getLoop(loopId);
      expect(loop, isNotNull);
      expect(loop!.title, 'Reopen me');
      expect(await reopened.readEvidence(loopId), hasLength(1));
      expect(await reopened.readEvents(loopId), hasLength(1));
    });

    test(
        'an unrecognised persisted enum value fails as a typed '
        'PersistenceCorruptData, not silently', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final DriftLoopRepository repo = DriftLoopRepository(db);

      // Bypass the repository to write a row schema v1 accepts but no
      // version of the domain ever produced — simulating data left behind
      // by a future schema version this build does not know about.
      await db.into(db.evidenceEntries).insert(
            EvidenceEntriesCompanion.insert(
              id: 'ev-corrupt',
              type: 'someFutureType',
              capturedAtMillis: t0.millisecondsSinceEpoch,
              sensitivity: 'ordinary',
            ),
          );

      await expectLater(
        () => repo.getEvidenceById(const EvidenceId('ev-corrupt')),
        throwsA(isA<PersistenceCorruptData>()),
      );
    });

    test(
        'a foreign-key violation surfaces as a typed '
        'PersistenceConstraintViolation, not a raw SqliteException', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final DriftLoopRepository repo = DriftLoopRepository(db);

      final ObservedFact orphanBasis = fact(id: 'ev-orphan');
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: orphanBasis.id,
        now: t0,
      );
      // The basis evidence is never written, so loop_records' foreign key
      // has nothing to reference.
      await expectLater(
        () => repo.saveOutcome(created),
        throwsA(isA<PersistenceConstraintViolation>()),
      );
    });

    test(
        'readAllLoopContexts bundles the right evidence and events per '
        'loop across several loops at once', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final DriftLoopRepository repo = DriftLoopRepository(db);

      final ObservedFact basisA = fact(id: 'ev-a');
      final LoopOutcome loopA = machine.create(
        id: const LoopId('loop-a'),
        title: 'Loop A',
        basis: basisA.id,
        now: t0,
      );
      await repo.saveOutcome(loopA, newEvidence: <Evidence>[basisA]);

      final ObservedFact basisB = fact(id: 'ev-b');
      final LoopOutcome loopB = machine.create(
        id: const LoopId('loop-b'),
        title: 'Loop B',
        basis: basisB.id,
        now: t0,
      );
      await repo.saveOutcome(loopB, newEvidence: <Evidence>[basisB]);

      final List<LoopContext> contexts = await repo.readAllLoopContexts();
      expect(contexts, hasLength(2));

      final LoopContext contextA = contexts.firstWhere(
        (LoopContext c) => c.loop.id == const LoopId('loop-a'),
      );
      expect(contextA.evidence.map((Evidence e) => e.id), <EvidenceId>[
        const EvidenceId('ev-a'),
      ]);
      expect(contextA.events, hasLength(1));

      final LoopContext contextB = contexts.firstWhere(
        (LoopContext c) => c.loop.id == const LoopId('loop-b'),
      );
      expect(contextB.evidence.map((Evidence e) => e.id), <EvidenceId>[
        const EvidenceId('ev-b'),
      ]);
    });

    test('an abandoned loop round-trips through saveOutcome and getLoop',
        () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final DriftLoopRepository repo = DriftLoopRepository(db);

      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repo.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final LoopOutcome abandoned = machine
          .apply(
            created.loop,
            const Abandon(reason: AbandonReason.decidedNotTo),
            now: t0.add(const Duration(minutes: 1)),
          )
          .valueOrNull!;
      await repo.saveOutcome(abandoned);

      final Loop? stored = await repo.getLoop(loopId);
      expect(stored!.state, LoopState.abandoned);
      expect(stored.abandonReason, AbandonReason.decidedNotTo);
    });
  });
}
