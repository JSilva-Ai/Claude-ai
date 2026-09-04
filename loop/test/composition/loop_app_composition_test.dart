import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/composition/loop_app_composition.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/features/home/models/home_snapshot.dart';

import '../domain/fixtures.dart';

void main() {
  const LoopStateMachine machine = LoopStateMachine();

  group('LoopAppComposition, the wiring itself', () {
    test('open → write → observe → close, entirely through the composed '
        'objects, no widget involved', () async {
      final LoopAppComposition composition = LoopAppComposition.withExecutor(
        NativeDatabase.memory(),
      );
      addTearDown(composition.dispose);

      final HomeSnapshot before = await composition.homeRepository.fetchHome();
      expect(before.activeLoops, 0);

      final List<void> changeEvents = <void>[];
      final subscription = composition.homeRepository.changes.listen(
        changeEvents.add,
      );
      await Future<void>.delayed(Duration.zero);

      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'Send the signed lease',
        basis: basis.id,
        now: t0,
      );
      await composition.repository.saveOutcome(
        created,
        newEvidence: <Evidence>[basis],
      );
      await Future<void>.delayed(Duration.zero);

      expect(changeEvents, isNotEmpty);
      final HomeSnapshot after = await composition.homeRepository.fetchHome();
      expect(after.activeLoops, 1);

      await subscription.cancel();
    });

    test('dispose closes the database — a query against it afterward '
        'fails loudly rather than silently returning empty/stale data',
        () async {
      // A real, file-backed executor, deliberately: NativeDatabase.memory()
      // reconnecting after close silently opens a *new*, empty in-memory
      // database — SQLite's own ":memory:" semantics, not anything drift or
      // this composition does — which would make this test pass for the
      // wrong reason. Production always opens a file (see
      // LoopAppComposition.open), where closing actually refuses reuse.
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'loop_app_composition_dispose_test_',
      );
      addTearDown(() => tempDir.delete(recursive: true));
      final LoopAppComposition composition = LoopAppComposition.withExecutor(
        NativeDatabase(File('${tempDir.path}/loop.sqlite')),
      );
      // The connection has to actually be open for closing it to mean
      // anything: closing a Drift database that never ran a query is a
      // no-op, and the next query silently opens a fresh connection instead
      // of failing — a real, if narrow, finding from testing this directly
      // rather than assuming. One read is enough to establish the
      // connection, matching what every real startup already does before
      // this composition would ever be disposed.
      await composition.repository.readAllLoopContexts();
      await composition.dispose();

      expect(
        () => composition.repository.readAllLoopContexts(),
        throwsA(anything),
      );
    });

    test('data written before closing is there after reopening the same '
        'file — the same guarantee 2C-A proved at the Drift level, now '
        'through the full composition', () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'loop_app_composition_test_',
      );
      final File dbFile = File('${tempDir.path}/loop.sqlite');
      addTearDown(() => tempDir.delete(recursive: true));

      final LoopAppComposition first = LoopAppComposition.withExecutor(
        NativeDatabase(dbFile),
      );
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'Reopen me',
        basis: basis.id,
        now: t0,
      );
      await first.repository.saveOutcome(created, newEvidence: <Evidence>[basis]);
      await first.dispose();

      final LoopAppComposition reopened = LoopAppComposition.withExecutor(
        NativeDatabase(dbFile),
      );
      addTearDown(reopened.dispose);

      final HomeSnapshot snapshot = await reopened.homeRepository.fetchHome();
      expect(snapshot.activeLoops, 1);
    });
  });
}
