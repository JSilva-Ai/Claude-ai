import 'package:drift/drift.dart';

import '../tables/evidence_entries_table.dart';
import '../tables/inference_derivations_table.dart';
import '../tables/loop_evidence_links_table.dart';
import '../tables/loop_event_records_table.dart';
import '../tables/loop_records_table.dart';

part 'loop_database.g.dart';

/// The persistence foundation. Schema and generated access only.
///
/// Deliberately not wired to a real file location: 2C-A is schema, not
/// application integration. A test opens this with `NativeDatabase.memory()`
/// or a temporary file; where the real app's database file lives on iOS and
/// Android is a composition-root decision that belongs to 2C-B, the phase
/// that is also allowed to add `path_provider`.
@DriftDatabase(
  tables: <Type>[
    LoopRecords,
    EvidenceEntries,
    LoopEventRecords,
    LoopEvidenceLinks,
    InferenceDerivations,
  ],
)
class LoopDatabase extends _$LoopDatabase {
  LoopDatabase(super.executor);

  /// The first schema. There is no historical production schema to migrate
  /// from, so there is no v0→v1 step to write — inventing one would be a
  /// migration that verifies nothing, run against a version that never
  /// shipped.
  @override
  int get schemaVersion => 1;

  /// Explicit on purpose, even though schema v1 has nothing to upgrade from.
  ///
  /// [onCreate] is the only strategy defined: it always runs `createAll()`,
  /// never a conditional "drop and recreate" — that behaviour was never
  /// written, so there is nothing here that could silently destroy a
  /// database on a future version bump. [onUpgrade] is deliberately left at
  /// drift's own default, which does not run at schema v1 and does not drop
  /// anything if it ever did: a real v1→v2 step is written by whichever phase
  /// introduces v2, against a schema snapshot frozen by
  /// `dart run drift_dev schema dump` — see `drift_schemas/`.
  ///
  /// [beforeOpen] turns on `PRAGMA foreign_keys`, which SQLite does not
  /// enable by default per connection. Every foreign key declared across
  /// `lib/data/local/tables/` is unenforced without this — a column that
  /// merely *looks* like a reference until this line runs.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
