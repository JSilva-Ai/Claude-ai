import '../evidence/evidence.dart';
import '../ids.dart';

/// What ingesting one `SourceObservation` produced.
///
/// Four shapes, sealed, so a caller cannot mistake "nothing new happened"
/// for a boolean and lose the reason why. Every variant that carries
/// evidence at all types it as [ObservedFact] specifically, not the broader
/// [Evidence] — that is not a convention, it is the type system's own proof
/// that ingestion cannot produce an [Inference], a [UserAssertion], a
/// Commitment, or a Loop: nothing in this file, or in `SourceIngestion`,
/// can construct one and still type-check.
sealed class IngestionResult {
  const IngestionResult();
}

/// A source item nothing had seen before became a new [ObservedFact].
final class IngestionAccepted extends IngestionResult {
  const IngestionAccepted(this.evidence);

  final ObservedFact evidence;

  @override
  String toString() => 'IngestionAccepted(${evidence.id})';
}

/// The same source item, with unchanged content, was already recorded as
/// [existing] — no new Evidence was created.
final class IngestionDuplicate extends IngestionResult {
  const IngestionDuplicate(this.existing);

  final EvidenceId existing;

  @override
  String toString() => 'IngestionDuplicate($existing)';
}

/// The same source item was already recorded as [previous], but this
/// observation's content differs from what [previous] captured — a new
/// [ObservedFact] records the revision. [previous] is untouched: Evidence is
/// append-only, so an update is a new fact beside the old one, never an edit
/// to it.
final class IngestionUpdated extends IngestionResult {
  const IngestionUpdated({required this.evidence, required this.previous});

  final ObservedFact evidence;
  final EvidenceId previous;

  @override
  String toString() => 'IngestionUpdated(${evidence.id}, was $previous)';
}

/// The observation could not become Evidence at all.
final class IngestionRejected extends IngestionResult {
  const IngestionRejected(this.reason);

  final String reason;

  @override
  String toString() => 'IngestionRejected($reason)';
}
