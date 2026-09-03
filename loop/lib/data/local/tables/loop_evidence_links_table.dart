import 'package:drift/drift.dart';

import 'evidence_entries_table.dart';
import 'loop_records_table.dart';

/// `Loop.evidence`, one row per attached piece of evidence.
///
/// This is current aggregate state — "what is this loop known by, right
/// now" — not history. When evidence was attached is already answered by
/// `LoopEventRecords` (an `evidenceAttached` event carries its own `at`), so
/// this table does not repeat it: a second, unsynchronised copy of the same
/// fact is exactly the kind of speculative column schema v1 was told not to
/// carry.
///
/// The composite primary key is also the domain's own refusal rule made
/// physical: `LoopStateMachine.attachEvidence` refuses evidence already
/// attached, and a duplicate `(loopId, evidenceId)` row is a uniqueness
/// violation here for the same reason.
@DataClassName('LoopEvidenceLink')
class LoopEvidenceLinks extends Table {
  TextColumn get loopId => text().references(LoopRecords, #id)();
  TextColumn get evidenceId => text().references(EvidenceEntries, #id)();

  @override
  Set<Column> get primaryKey => <Column>{loopId, evidenceId};
}
