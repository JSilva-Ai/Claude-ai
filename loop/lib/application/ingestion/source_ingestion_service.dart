import '../../domain/evidence/evidence.dart';
import '../../domain/evidence/source_ref.dart';
import '../../domain/ids.dart';
import '../../domain/source/ingestion_result.dart';
import '../../domain/source/source_ingestion.dart';
import '../../domain/source/source_observation.dart';

/// Looks up the most recently known [ObservedFact] for [source], if any —
/// the one piece of state [SourceIngestion] needs but cannot fetch itself.
///
/// A real, persisted implementation would query `EvidenceEntries` by
/// `sourceKind`/`sourceLocator`/`sourceAccountRef` — schema v1 already
/// stores exactly those columns (see `evidence_entries_table.dart`), so no
/// schema change is needed to write one; the query itself is later wiring
/// work, not 3B's. A test supplies an in-memory fake instead — the same
/// relationship `InMemoryLoopRepository` already has to `DriftLoopRepository`.
typedef SourceLookup = Future<ObservedFact?> Function(SourceRef source);

/// The async seam between a future source adapter and the pure domain
/// decision in [SourceIngestion].
///
/// Single responsibility, deliberately: this awaits [lookup], then hands the
/// plain result to [SourceIngestion.ingest] — it does not detect
/// commitments, extract entities, assess risk, choose a next action, or
/// touch Home. Those stay exactly where 3B's own gate leaves them: in ports
/// and projections this service never imports. It does not persist the
/// result either — [ingest] returns the decision, and saving an accepted or
/// updated [ObservedFact] is left to whichever future caller actually has a
/// write path to storage, the same way 3A left every `Commitment` unsaved.
class SourceIngestionService {
  const SourceIngestionService({required this.lookup});

  final SourceLookup lookup;

  Future<IngestionResult> ingest({
    required SourceObservation observation,
    required EvidenceId assignId,
  }) async {
    final ObservedFact? existing = await lookup(observation.source);
    return const SourceIngestion().ingest(
      observation: observation,
      assignId: assignId,
      existingForSource: existing,
    );
  }
}
