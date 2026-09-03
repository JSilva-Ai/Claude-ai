import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../../../application/loop_repository.dart';
import '../../../application/persistence_failure.dart';
import '../../../domain/evidence/evidence.dart';
import '../../../domain/failures.dart' show LoopInvariantViolation;
import '../../../domain/ids.dart';
import '../../../domain/loop/loop.dart';
import '../../../domain/loop/loop_event.dart';
import '../../../domain/loop/loop_state_machine.dart';
import '../database/loop_database.dart';
import '../mapping/evidence_mapping.dart';
import '../mapping/loop_event_mapping.dart';
import '../mapping/loop_mapping.dart';

/// [LoopRepository], over the schema v1 foundation approved in 2C-A.
///
/// Generated Drift rows never leave this file: every public method returns
/// or accepts only domain types, through the mapping helpers 2C-A already
/// proved round-trip correctly. Nothing here changes what those helpers do —
/// this class only sequences reads and writes around them.
class DriftLoopRepository implements LoopRepository {
  DriftLoopRepository(this._db);

  final LoopDatabase _db;

  @override
  Stream<List<Loop>> watchLoops() {
    return _db.select(_db.loopRecords).watch().asyncMap((rows) async {
      final Map<String, List<String>> evidenceIdsByLoop =
          await _evidenceIdsByLoop(rows.map((r) => r.id));
      return _guardSync(
        () => rows
            .map(
              (row) => loopFromRecord(
                row,
                evidence: (evidenceIdsByLoop[row.id] ?? const <String>[])
                    .map(EvidenceId.parse)
                    .toList(),
              ),
            )
            .toList(),
      );
    });
  }

  @override
  Future<Loop?> getLoop(LoopId id) => _guard(() async {
        final LoopRecord? row = await (_db.select(
          _db.loopRecords,
        )..where((t) => t.id.equals(id.value)))
            .getSingleOrNull();
        if (row == null) return null;
        final Map<String, List<String>> evidenceIds = await _evidenceIdsByLoop(
          <String>[row.id],
        );
        return loopFromRecord(
          row,
          evidence: (evidenceIds[row.id] ?? const <String>[])
              .map(EvidenceId.parse)
              .toList(),
        );
      });

  @override
  Future<List<LoopEvent>> readEvents(LoopId loopId) => _guard(() async {
        final List<LoopEventRecord> rows = await (_db.select(
          _db.loopEventRecords,
        )..where((t) => t.loopId.equals(loopId.value)))
            .get();
        rows.sort((a, b) => a.sequence.compareTo(b.sequence));
        return rows.map(loopEventFromRecord).toList();
      });

  @override
  Future<List<Evidence>> readEvidence(LoopId loopId) => _guard(() async {
        final List<LoopEvidenceLink> links = await (_db.select(
          _db.loopEvidenceLinks,
        )..where((t) => t.loopId.equals(loopId.value)))
            .get();
        final List<EvidenceEntry> rows = await (_db.select(
          _db.evidenceEntries,
        )..where((t) => t.id.isIn(links.map((l) => l.evidenceId))))
            .get();
        return _hydrateEvidence(rows);
      });

  @override
  Future<Evidence?> getEvidenceById(EvidenceId id) => _guard(() async {
        final EvidenceEntry? row = await (_db.select(
          _db.evidenceEntries,
        )..where((t) => t.id.equals(id.value)))
            .getSingleOrNull();
        if (row == null) return null;
        return (await _hydrateEvidence(<EvidenceEntry>[row])).single;
      });

  /// One bounded pass over every table, regardless of how many loops exist —
  /// five queries whether there are three loops or three hundred, never one
  /// per loop. See [LoopContext] and `application/home/home_projector.dart`,
  /// the caller this exists for.
  @override
  Future<List<LoopContext>> readAllLoopContexts() => _guard(() async {
        final List<LoopRecord> loopRows =
            await _db.select(_db.loopRecords).get();
        final List<LoopEvidenceLink> linkRows =
            await _db.select(_db.loopEvidenceLinks).get();
        final List<EvidenceEntry> evidenceRows =
            await _db.select(_db.evidenceEntries).get();
        final List<InferenceDerivation> derivationRows =
            await _db.select(_db.inferenceDerivations).get();
        final List<LoopEventRecord> eventRows =
            await _db.select(_db.loopEventRecords).get();

        final List<Evidence> allEvidence = _hydrateWithDerivations(
          evidenceRows,
          derivationRows,
        );
        final Map<String, Evidence> evidenceById = <String, Evidence>{
          for (final Evidence e in allEvidence) e.id.value: e,
        };

        final Map<String, List<String>> evidenceIdsByLoop =
            <String, List<String>>{};
        for (final LoopEvidenceLink link in linkRows) {
          (evidenceIdsByLoop[link.loopId] ??= <String>[]).add(link.evidenceId);
        }

        final Map<String, List<LoopEventRecord>> eventsByLoop =
            <String, List<LoopEventRecord>>{};
        for (final LoopEventRecord event in eventRows) {
          (eventsByLoop[event.loopId] ??= <LoopEventRecord>[]).add(event);
        }

        return loopRows.map((LoopRecord row) {
          final List<String> evidenceIds =
              evidenceIdsByLoop[row.id] ?? const <String>[];
          final List<LoopEventRecord> events =
              List<LoopEventRecord>.of(eventsByLoop[row.id] ?? const [])
                ..sort((a, b) => a.sequence.compareTo(b.sequence));

          return LoopContext(
            loop: loopFromRecord(
              row,
              evidence: evidenceIds.map(EvidenceId.parse).toList(),
            ),
            evidence: evidenceIds
                .map((id) => evidenceById[id])
                .whereType<Evidence>()
                .toList(),
            events: events.map(loopEventFromRecord).toList(),
          );
        }).toList();
      });

  @override
  Future<void> saveOutcome(
    LoopOutcome outcome, {
    List<Evidence> newEvidence = const <Evidence>[],
  }) =>
      _guard(() => _saveOutcomeInTransaction(outcome, newEvidence));

  Future<void> _saveOutcomeInTransaction(
    LoopOutcome outcome,
    List<Evidence> newEvidence,
  ) =>
      _db.transaction(() async {
        // The two foreign keys on loop_records/loop_evidence_links point
        // in opposite directions, so this cannot be one pass over
        // newEvidence: loop_records.basis_evidence_id needs the basis
        // evidence to exist first (on genesis, that basis is itself one
        // of newEvidence), while loop_evidence_links.loop_id needs the
        // loop row to exist first. Evidence, then the loop, then the
        // links, then the event is the only order that satisfies both.
        for (final Evidence evidence in newEvidence) {
          await _db.into(_db.evidenceEntries).insert(
                evidenceToCompanion(evidence),
              );
          if (evidence is Inference) {
            for (final (int position, EvidenceId source)
                in evidence.derivedFrom.indexed) {
              await _db.into(_db.inferenceDerivations).insert(
                    InferenceDerivationsCompanion.insert(
                      inferenceId: evidence.id.value,
                      sourceEvidenceId: source.value,
                      position: position,
                    ),
                  );
            }
          }
        }

        // insertOrReplace: current state is meant to be overwritten by
        // its own next revision. The event below is never replaced —
        // the append-only log has no "current row" to overwrite.
        await _db.into(_db.loopRecords).insert(
              loopToCompanion(outcome.loop),
              mode: InsertMode.insertOrReplace,
            );

        for (final Evidence evidence in newEvidence) {
          await _db.into(_db.loopEvidenceLinks).insert(
                LoopEvidenceLinksCompanion.insert(
                  loopId: outcome.loop.id.value,
                  evidenceId: evidence.id.value,
                ),
              );
        }

        await _db.into(_db.loopEventRecords).insert(
              loopEventToCompanion(outcome.event),
            );
      });

  Future<Map<String, List<String>>> _evidenceIdsByLoop(
    Iterable<String> loopIds,
  ) async {
    final List<LoopEvidenceLink> links = await (_db.select(
      _db.loopEvidenceLinks,
    )..where((t) => t.loopId.isIn(loopIds)))
        .get();
    final Map<String, List<String>> byLoop = <String, List<String>>{};
    for (final LoopEvidenceLink link in links) {
      (byLoop[link.loopId] ??= <String>[]).add(link.evidenceId);
    }
    return byLoop;
  }

  /// Hydrates rows into [Evidence], resolving each [Inference]'s
  /// `derivedFrom` via one bulk read of [InferenceDerivations] rather than
  /// one query per inference row.
  Future<List<Evidence>> _hydrateEvidence(List<EvidenceEntry> rows) async {
    final List<String> inferenceIds =
        rows.where((r) => r.type == 'inference').map((r) => r.id).toList();
    final List<InferenceDerivation> derivations = inferenceIds.isEmpty
        ? const <InferenceDerivation>[]
        : await (_db.select(
            _db.inferenceDerivations,
          )..where((t) => t.inferenceId.isIn(inferenceIds)))
            .get();
    return _hydrateWithDerivations(rows, derivations);
  }

  List<Evidence> _hydrateWithDerivations(
    List<EvidenceEntry> rows,
    List<InferenceDerivation> derivations,
  ) {
    final Map<String, List<InferenceDerivation>> byInference =
        <String, List<InferenceDerivation>>{};
    for (final InferenceDerivation d in derivations) {
      (byInference[d.inferenceId] ??= <InferenceDerivation>[]).add(d);
    }
    return rows.map((EvidenceEntry row) {
      final List<InferenceDerivation>? links = byInference[row.id];
      if (links == null) return evidenceFromEntry(row);
      links.sort((a, b) => a.position.compareTo(b.position));
      return evidenceFromEntry(
        row,
        derivedFrom: links.map((l) => EvidenceId(l.sourceEvidenceId)).toList(),
      );
    }).toList();
  }

  T _guardSync<T>(T Function() body) {
    try {
      return body();
    } on ArgumentError catch (e) {
      throw PersistenceCorruptData(e.toString());
    } on LoopInvariantViolation catch (e) {
      throw PersistenceCorruptData(e.toString());
    }
  }

  Future<T> _guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on SqliteException catch (e) {
      throw PersistenceConstraintViolation(e.toString());
    } on ArgumentError catch (e) {
      throw PersistenceCorruptData(e.toString());
    } on LoopInvariantViolation catch (e) {
      throw PersistenceCorruptData(e.toString());
    }
  }
}
