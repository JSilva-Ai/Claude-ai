import '../evidence/capture_integrity.dart';
import '../evidence/data_sensitivity.dart';
import '../evidence/source_ref.dart';

/// A provider-neutral capture of something a source said, before it has
/// become Evidence.
///
/// This is the boundary a future adapter (`GmailSourceAdapter`,
/// `CalendarSourceAdapter`, `ManualSourceAdapter`, and so on — none of which
/// exist yet) is expected to construct: whatever provider shape it started
/// from has already been reduced to exactly what `SourceIngestion` needs to
/// decide whether this is new, a duplicate, or a revision, and to build an
/// `ObservedFact` if it is. Nothing here is provider-specific; [source]
/// already carries the one distinction that matters (`EvidenceSource`) and
/// an opaque, adapter-owned locator — see [SourceRef]'s own doc for why that
/// is enough to de-duplicate on, with no separate conversation/thread
/// concept needed: two different locators are always two different items,
/// whatever conversation either belongs to.
///
/// Deliberately five fields, each one already a field `ObservedFact` itself
/// needs — this type exists only because `ObservedFact` cannot yet be
/// constructed: it needs an `EvidenceId`, and nothing before ingestion has
/// decided what id this observation should have, or whether it should have
/// a new one at all. What this phase's own brief asked to evaluate and this
/// type does not carry — participants, a subject line, a thread reference,
/// a separate "when did the source event happen" field — was considered and
/// left out: none of it is needed to produce an `ObservedFact`, which is the
/// only thing 3B builds. [capturedAt] maps directly onto
/// `ObservedFact.capturedAt`; for a real adapter that is the source's own
/// timestamp (an email's send time, a calendar event's own moment), and 3B
/// has no second use for a separate one.
class SourceObservation {
  const SourceObservation({
    required this.source,
    required this.capturedAt,
    required this.integrity,
    this.excerpt,
    this.sensitivity = DataSensitivity.ordinary,
  });

  /// Where this was observed, and the opaque, adapter-owned locator that
  /// makes de-duplication possible — see [SourceRef]'s own doc.
  final SourceRef source;

  /// The moment being recorded.
  final DateTime capturedAt;

  final CaptureIntegrity integrity;

  /// A short, redactable fragment — never the whole body. Same discipline as
  /// `ObservedFact.excerpt`, because that is exactly what this becomes.
  final String? excerpt;

  final DataSensitivity sensitivity;

  @override
  String toString() =>
      'SourceObservation(${source.source.name}:${source.locator})';
}
