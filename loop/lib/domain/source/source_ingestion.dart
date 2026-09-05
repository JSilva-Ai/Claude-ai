import '../evidence/evidence.dart';
import '../ids.dart';
import 'ingestion_result.dart';
import 'source_observation.dart';

/// The one place that knows how a [SourceObservation] becomes Evidence, or
/// doesn't.
///
/// Pure and synchronous, the same discipline `SignalExtractor` and
/// `Provenance` already hold to: no repository, no clock, no randomness.
/// [existingForSource] is the one piece of external state this needs — the
/// most recently known [ObservedFact] for this observation's own
/// [SourceObservation.source], if any — and it arrives as a plain value
/// because looking it up is I/O, which does not belong here; see
/// `SourceIngestionService` in `application/ingestion` for the async
/// wrapper that performs the lookup and calls this.
///
/// This class never constructs an [Inference], a [UserAssertion], a
/// Commitment, or a Loop — [IngestionResult]'s own success variants are
/// typed [ObservedFact], which is what makes that a guarantee rather than a
/// convention.
class SourceIngestion {
  const SourceIngestion();

  IngestionResult ingest({
    required SourceObservation observation,
    required EvidenceId assignId,
    ObservedFact? existingForSource,
  }) {
    if (observation.source.locator.trim().isEmpty) {
      return const IngestionRejected(
        'a source observation must carry a non-empty locator',
      );
    }

    final ObservedFact fact = ObservedFact(
      id: assignId,
      capturedAt: observation.capturedAt,
      source: observation.source,
      integrity: observation.integrity,
      excerpt: observation.excerpt,
      sensitivity: observation.sensitivity,
    );

    if (existingForSource == null) {
      return IngestionAccepted(fact);
    }

    if (_sameContent(existingForSource, observation)) {
      return IngestionDuplicate(existingForSource.id);
    }

    return IngestionUpdated(evidence: fact, previous: existingForSource.id);
  }

  /// Whether [existing] already captured exactly what [observation] would.
  /// Compares only what an observation actually carries — not `source`,
  /// which is the lookup key that found [existing] in the first place and is
  /// therefore already known to match.
  bool _sameContent(ObservedFact existing, SourceObservation observation) =>
      existing.capturedAt == observation.capturedAt &&
      existing.integrity == observation.integrity &&
      existing.excerpt == observation.excerpt &&
      existing.sensitivity == observation.sensitivity;
}
