import 'package:drift/drift.dart';

import '../../../domain/evidence/data_sensitivity.dart';
import '../../../domain/ids.dart';
import '../../../domain/loop/loop.dart';
import '../../../domain/loop/loop_state.dart';
import '../database/loop_database.dart';
import 'enum_codec.dart';
import 'persisted_time.dart';

/// Domain → storage. Covers all 19 fields of the approved `Loop` constructor
/// — nothing added, nothing dropped.
///
/// Does not touch [LoopEvidenceLinks]: `Loop.evidence` is a list of
/// references, not a column, and writing the join rows is a multi-statement
/// operation a pure mapping function has no business doing. That is a
/// repository's job, in 2C-B.
LoopRecordsCompanion loopToCompanion(Loop loop) {
  return LoopRecordsCompanion.insert(
    id: loop.id.value,
    title: loop.title,
    state: encodeEnum(loop.state),
    basisEvidenceId: loop.basis.value,
    commitmentId: Value<String?>(loop.commitment?.value),
    suggestionId: Value<String?>(loop.suggestion?.value),
    waitingOn: Value<String?>(loop.waitingOn?.value),
    waitingSinceMillis: Value<int?>(
      loop.waitingSince == null ? null : toPersistedMillis(loop.waitingSince!),
    ),
    resolvedAtMillis: Value<int?>(
      loop.resolvedAt == null ? null : toPersistedMillis(loop.resolvedAt!),
    ),
    abandonReason: Value<String?>(
      loop.abandonReason == null ? null : encodeEnum(loop.abandonReason!),
    ),
    suppressedUntilMillis: Value<int?>(
      loop.suppressedUntil == null
          ? null
          : toPersistedMillis(loop.suppressedUntil!),
    ),
    pinned: Value<bool>(loop.pinned),
    sensitivity: encodeEnum(loop.sensitivity),
    createdAtMillis: toPersistedMillis(loop.createdAt),
    updatedAtMillis: toPersistedMillis(loop.updatedAt),
    stateChangedAtMillis: toPersistedMillis(loop.stateChangedAt),
    schemaVersion: Value<int>(loop.schemaVersion),
    revision: loop.revision,
  );
}

/// Storage → domain.
///
/// [evidence] is supplied by the caller rather than queried here, for the
/// same reason [loopToCompanion] does not write it: assembling the evidence
/// list for a loop is a join across [LoopEvidenceLinks], which is a
/// repository concern. The domain's own constructor still enforces that
/// [Loop.basis] is a member of [evidence] — this function does not repeat
/// that check, only supplies the data for it to run against.
Loop loopFromRecord(LoopRecord row, {required List<EvidenceId> evidence}) {
  return Loop(
    id: LoopId.parse(row.id),
    title: row.title,
    state: decodeEnum(LoopState.values, row.state),
    basis: EvidenceId.parse(row.basisEvidenceId),
    evidence: evidence,
    commitment:
        row.commitmentId == null ? null : CommitmentId.parse(row.commitmentId!),
    suggestion: row.suggestionId == null
        ? null
        : ActionSuggestionId.parse(row.suggestionId!),
    waitingOn: row.waitingOn == null ? null : PartyId.parse(row.waitingOn!),
    waitingSince: row.waitingSinceMillis == null
        ? null
        : fromPersistedMillis(row.waitingSinceMillis!),
    resolvedAt: row.resolvedAtMillis == null
        ? null
        : fromPersistedMillis(row.resolvedAtMillis!),
    abandonReason: row.abandonReason == null
        ? null
        : decodeEnum(AbandonReason.values, row.abandonReason!),
    suppressedUntil: row.suppressedUntilMillis == null
        ? null
        : fromPersistedMillis(row.suppressedUntilMillis!),
    pinned: row.pinned,
    sensitivity: decodeEnum(DataSensitivity.values, row.sensitivity),
    createdAt: fromPersistedMillis(row.createdAtMillis),
    updatedAt: fromPersistedMillis(row.updatedAtMillis),
    stateChangedAt: fromPersistedMillis(row.stateChangedAtMillis),
    schemaVersion: row.schemaVersion,
    revision: row.revision,
  );
}
