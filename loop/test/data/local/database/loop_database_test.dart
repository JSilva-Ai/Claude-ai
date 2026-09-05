import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/database/loop_database.dart';
import 'package:loop/data/local/mapping/evidence_mapping.dart';
import 'package:loop/data/local/mapping/loop_mapping.dart';
import 'package:loop/domain/loop/loop_state.dart';

import '../../../domain/fixtures.dart';
import '../generated/schema.dart';

void main() {
  group('opening and schema creation', () {
    test('the database opens successfully against an empty store', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      // Any statement succeeding at all proves onCreate ran without error.
      final List<EvidenceEntry> rows =
          await db.select(db.evidenceEntries).get();
      expect(rows, isEmpty);
      await db.close();
    });

    test('schemaVersion is 1', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      expect(db.schemaVersion, 1);
      await db.close();
    });

    test('all five schema v1 tables exist', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      expect(
        db.allTables.map((TableInfo<Table, dynamic> t) => t.actualTableName),
        containsAll(<String>[
          'evidence_entries',
          'loop_records',
          'loop_event_records',
          'loop_evidence_links',
          'inference_derivations',
        ]),
      );
      await db.close();
    });
  });

  group('core row insert/read', () {
    test(
        'a basis fact and a loop referencing it can both be written and '
        'read back', () async {
      final LoopDatabase db = LoopDatabase(NativeDatabase.memory());
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));

      expect(await db.select(db.evidenceEntries).get(), hasLength(1));
      expect(await db.select(db.loopRecords).get(), hasLength(1));
      await db.close();
    });
  });

  group('foreign keys are enforced and restrictive, never cascading', () {
    late LoopDatabase db;

    setUp(() async {
      db = LoopDatabase(NativeDatabase.memory());
      await db
          .into(db.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await db
          .into(db.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));
      await db.into(db.loopEvidenceLinks).insert(
            LoopEvidenceLinksCompanion.insert(
              loopId: loopId.value,
              evidenceId: basisId.value,
            ),
          );
    });

    tearDown(() async => db.close());

    test('PRAGMA foreign_keys is actually on for this connection', () async {
      final List<QueryRow> result =
          await db.customSelect('PRAGMA foreign_keys').get();
      expect(result.single.data['foreign_keys'], 1);
    });

    test(
        'inserting a loop_evidence_links row for evidence that does not '
        'exist is refused', () async {
      expect(
        () => db.into(db.loopEvidenceLinks).insert(
              LoopEvidenceLinksCompanion.insert(
                loopId: loopId.value,
                evidenceId: 'ev-does-not-exist',
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });

    test(
        'deleting evidence that a loop still names as its basis is '
        'refused, not silently cascaded away', () async {
      // The amendment this test exists for: deletion must never depend only
      // on "delete the whole file", and today's restrictive default is what
      // keeps a future, deliberate deletion feature free to decide what
      // *should* happen here, instead of finding the decision already made
      // by an ON DELETE CASCADE nobody meant to write.
      expect(
        () => (db.delete(db.evidenceEntries)
              ..where((t) => t.id.equals(basisId.value)))
            .go(),
        throwsA(isA<SqliteException>()),
      );

      final List<EvidenceEntry> stillThere =
          await db.select(db.evidenceEntries).get();
      expect(stillThere, hasLength(1));
    });

    test('deleting a loop that still has events referencing it is refused',
        () async {
      await db.into(db.loopEventRecords).insert(
            LoopEventRecordsCompanion.insert(
              loopId: loopId.value,
              sequence: 1,
              kind: 'created',
              actor: 'user',
              atMillis: t0.millisecondsSinceEpoch,
            ),
          );

      expect(
        () => (db.delete(db.loopRecords)
              ..where((t) => t.id.equals(loopId.value)))
            .go(),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('reopen/persistence behaviour', () {
    test(
        'data written before closing is still there after reopening the '
        'same file', () async {
      final Directory tempDir = await Directory.systemTemp.createTemp(
        'loop_database_test_',
      );
      final File dbFile = File('${tempDir.path}/loop.sqlite');
      addTearDown(() => tempDir.delete(recursive: true));

      final LoopDatabase first = LoopDatabase(NativeDatabase(dbFile));
      await first
          .into(first.evidenceEntries)
          .insert(evidenceToCompanion(fact(id: basisId.value)));
      await first
          .into(first.loopRecords)
          .insert(loopToCompanion(loopIn(LoopState.open)));
      await first.close();

      final LoopDatabase reopened = LoopDatabase(NativeDatabase(dbFile));
      final List<LoopRecord> loops = await reopened
          .select(
            reopened.loopRecords,
          )
          .get();
      expect(loops, hasLength(1));
      expect(loops.single.id, loopId.value);
      await reopened.close();
    });
  });

  group('migration foundation', () {
    test(
        'schema v1, as frozen by drift_dev schema dump, verifies cleanly '
        'against the current LoopDatabase definition', () async {
      // Proves the supported path for future migration testing works today,
      // without inventing a v0→v1 step that never shipped: the exported
      // snapshot in drift_schemas/loop_database/drift_schema_v1.json opens
      // through the generated helper, and LoopDatabase's own migration
      // strategy validates against it.
      final SchemaVerifier verifier = SchemaVerifier(GeneratedHelper());
      final DatabaseConnection connection = await verifier.startAt(1);
      final LoopDatabase db = LoopDatabase(connection.executor);
      await verifier.migrateAndValidate(db, 1);
      await db.close();
    });
  });
}
