import 'package:drift/drift.dart';

import 'evidence_entries_table.dart';

/// The current state of one [Loop] aggregate — not its history.
///
/// One row per loop, mirroring the 19 fields the approved domain constructor
/// takes, no more and no fewer: this table is required by current domain
/// state, not designed for anything the domain does not yet ask for.
///
/// Named `LoopRecords` rather than `Loops` so the generated row type is
/// `LoopRecord`, not `Loop` — the domain already owns that name.
///
/// [commitmentId], [suggestionId] and [waitingOn] are stored as opaque text,
/// with no foreign key: `CommitmentId`, `ActionSuggestionId` and `PartyId`
/// are, per the domain's own `ids.dart`, "referenced, never dereferenced in
/// this phase" — there is no `commitments`, `action_suggestions` or
/// `parties` table for them to reference. Losslessly stored, not resolved.
@DataClassName('LoopRecord')
class LoopRecords extends Table {
  /// The `LoopId.value`.
  TextColumn get id => text()();

  TextColumn get title => text()();

  /// `LoopState`, by name.
  TextColumn get state => text()();

  /// The evidence this loop exists because of. The domain's own invariant
  /// requires it to also appear in [LoopEvidenceLinks] for this loop; that is
  /// enforced by the aggregate's constructor, not restated as a database
  /// constraint SQLite has no direct way to express.
  TextColumn get basisEvidenceId => text().references(EvidenceEntries, #id)();

  TextColumn get commitmentId => text().nullable()();
  TextColumn get suggestionId => text().nullable()();

  TextColumn get waitingOn => text().nullable()();
  IntColumn get waitingSinceMillis => integer().nullable()();

  IntColumn get resolvedAtMillis => integer().nullable()();

  /// `AbandonReason`, by name.
  TextColumn get abandonReason => text().nullable()();

  IntColumn get suppressedUntilMillis => integer().nullable()();

  BoolColumn get pinned => boolean().withDefault(const Constant<bool>(false))();

  /// `DataSensitivity`, by name.
  TextColumn get sensitivity => text()();

  IntColumn get createdAtMillis => integer()();
  IntColumn get updatedAtMillis => integer()();
  IntColumn get stateChangedAtMillis => integer()();

  IntColumn get schemaVersion =>
      integer().withDefault(const Constant<int>(1))();
  IntColumn get revision => integer()();

  @override
  Set<Column> get primaryKey => <Column>{id};
}
