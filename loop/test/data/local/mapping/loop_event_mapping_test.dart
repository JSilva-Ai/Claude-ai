import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/database/loop_database.dart';
import 'package:loop/data/local/mapping/evidence_mapping.dart';
import 'package:loop/data/local/mapping/loop_event_mapping.dart';
import 'package:loop/data/local/mapping/loop_mapping.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state.dart';

import '../../../domain/fixtures.dart';

void main() {
  late LoopDatabase db;

  setUp(() {
    db = LoopDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('LoopEvent round trip', () {
    test('a stateChanged event round-trips every field', () async {
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));

      final LoopEvent original = LoopEvent(
        loop: loopId,
        sequence: 2,
        kind: LoopEventKind.stateChanged,
        actor: TransitionActor.user,
        at: t0.add(const Duration(minutes: 5)),
        from: LoopState.detected,
        to: LoopState.open,
      );
      await db.into(db.loopEventRecords).insert(loopEventToCompanion(original));

      final LoopEventRecord row =
          await db.select(db.loopEventRecords).getSingle();
      final LoopEvent restored = loopEventFromRecord(row);

      expect(restored.loop, original.loop);
      expect(restored.sequence, original.sequence);
      expect(restored.kind, original.kind);
      expect(restored.actor, original.actor);
      expect(restored.at, original.at);
      expect(restored.from, original.from);
      expect(restored.to, original.to);
      expect(restored.reason, isNull);
      expect(restored.evidence, isNull);
    });

    test('an evidenceAttached event round-trips its evidence reference',
        () async {
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db.into(db.evidenceEntries).insert(
            evidenceToCompanion(fact(id: 'ev-second')),
          );
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));

      final LoopEvent original = LoopEvent(
        loop: loopId,
        sequence: 2,
        kind: LoopEventKind.evidenceAttached,
        actor: TransitionActor.externalEvent,
        at: t0.add(const Duration(minutes: 1)),
        evidence: const EvidenceId('ev-second'),
      );
      await db.into(db.loopEventRecords).insert(loopEventToCompanion(original));

      final LoopEventRecord row =
          await db.select(db.loopEventRecords).getSingle();
      expect(loopEventFromRecord(row).evidence, original.evidence);
    });

    test('an abandonment event round-trips its AbandonReason', () async {
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));

      final LoopEvent original = LoopEvent(
        loop: loopId,
        sequence: 2,
        kind: LoopEventKind.stateChanged,
        actor: TransitionActor.user,
        at: t0,
        from: LoopState.open,
        to: LoopState.abandoned,
        reason: AbandonReason.decidedNotTo,
      );
      await db.into(db.loopEventRecords).insert(loopEventToCompanion(original));

      final LoopEventRecord row =
          await db.select(db.loopEventRecords).getSingle();
      expect(loopEventFromRecord(row).reason, AbandonReason.decidedNotTo);
    });
  });

  group('LoopEvent ordering and uniqueness', () {
    Future<void> seedLoop() async {
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));
    }

    test('events for a loop are queryable in sequence order', () async {
      await seedLoop();
      for (final int seq in <int>[3, 1, 2]) {
        await db.into(db.loopEventRecords).insert(
              LoopEventRecordsCompanion.insert(
                loopId: loopId.value,
                sequence: seq,
                kind: 'stateChanged',
                actor: 'user',
                atMillis: t0.millisecondsSinceEpoch + seq,
              ),
            );
      }

      final List<LoopEventRecord> rows = await (db.select(db.loopEventRecords)
            ..orderBy(<OrderClauseGenerator<$LoopEventRecordsTable>>[
              (t) => OrderingTerm.asc(t.sequence),
            ]))
          .get();

      expect(rows.map((LoopEventRecord r) => r.sequence).toList(), [1, 2, 3]);
    });

    test('a duplicate (loop, sequence) pair is refused by the schema',
        () async {
      await seedLoop();
      await db.into(db.loopEventRecords).insert(
            LoopEventRecordsCompanion.insert(
              loopId: loopId.value,
              sequence: 1,
              kind: 'created',
              actor: 'user',
              atMillis: t0.millisecondsSinceEpoch,
            ),
          );

      // Mirrors the refusal `LoopStateMachine` itself would produce for a
      // gap or a repeat in the log — here enforced by the primary key rather
      // than by application code, so it holds even for a write that never
      // went through the state machine.
      expect(
        () => db.into(db.loopEventRecords).insert(
              LoopEventRecordsCompanion.insert(
                loopId: loopId.value,
                sequence: 1,
                kind: 'stateChanged',
                actor: 'user',
                atMillis: t0.millisecondsSinceEpoch + 1,
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('the same sequence number is fine for two different loops', () async {
      await seedLoop();

      // A second loop needs its own basis evidence — the foreign key on
      // loop_records.basis_evidence_id has nothing to point at otherwise.
      const EvidenceId secondBasis = EvidenceId('ev-second-loop');
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: secondBasis.value)));
      final Loop secondLoop = Loop(
        id: const LoopId('loop-2'),
        title: 'A second, unrelated loop',
        state: LoopState.open,
        basis: secondBasis,
        evidence: const <EvidenceId>[secondBasis],
        createdAt: t0,
        updatedAt: t0,
        stateChangedAt: t0,
      );
      await db.into(db.loopRecords).insert(loopToCompanion(secondLoop));

      await db.into(db.loopEventRecords).insert(
            LoopEventRecordsCompanion.insert(
              loopId: loopId.value,
              sequence: 1,
              kind: 'created',
              actor: 'user',
              atMillis: t0.millisecondsSinceEpoch,
            ),
          );
      await db.into(db.loopEventRecords).insert(
            LoopEventRecordsCompanion.insert(
              loopId: 'loop-2',
              sequence: 1,
              kind: 'created',
              actor: 'user',
              atMillis: t0.millisecondsSinceEpoch,
            ),
          );

      final List<LoopEventRecord> rows =
          await db.select(db.loopEventRecords).get();
      expect(rows, hasLength(2));
    });
  });
}
