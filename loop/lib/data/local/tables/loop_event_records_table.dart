import 'package:drift/drift.dart';

import 'evidence_entries_table.dart';
import 'loop_records_table.dart';

/// The append-only log of what happened to each loop, in order.
///
/// Not event sourcing: [LoopRecords] holds current state on its own, and this
/// table exists so the product can answer "why is this here" and "what has
/// already been tried" — the same split the domain's own `LoopEvent` doc
/// draws. Nothing in this phase reconstructs a loop by replaying its events.
///
/// Identity is `(loopId, sequence)`, matching `LoopEvent`'s own identity
/// rather than a generated row id — `sequence` already equals the loop's
/// `revision` after the event, so a gap is detectable by arithmetic on data
/// this table already holds, with no separate id to keep in step.
///
/// Named `LoopEventRecords` so the generated row type is `LoopEventRecord`,
/// not `LoopEvent` — the domain already owns that name.
@DataClassName('LoopEventRecord')
class LoopEventRecords extends Table {
  TextColumn get loopId => text().references(LoopRecords, #id)();

  /// Equals the loop's `revision` after this event. Monotonic per loop; see
  /// [primaryKey] for how uniqueness of the pair is enforced.
  IntColumn get sequence => integer()();

  /// `LoopEventKind`, by name.
  TextColumn get kind => text()();

  /// `TransitionActor`, by name.
  TextColumn get actor => text()();

  IntColumn get atMillis => integer()();

  /// `LoopState`, by name. Null unless [kind] is `stateChanged`.
  TextColumn get fromState => text().nullable()();
  TextColumn get toState => text().nullable()();

  /// `AbandonReason`, by name. Set only when this event abandoned the loop.
  TextColumn get abandonReason => text().nullable()();

  /// Set when this event is about a specific piece of evidence.
  TextColumn get evidenceId =>
      text().nullable().references(EvidenceEntries, #id)();

  @override
  Set<Column> get primaryKey => <Column>{loopId, sequence};
}
