import '../../evidence/data_sensitivity.dart';

/// What an AI port is allowed to see: redacted text plus its classification,
/// never a live handle back to the mailbox or calendar it came from.
///
/// This is the boundary privacy-first draws for 2B's ports. An adapter
/// implementing [EntityExtractor] or [CommitmentDetector] later receives one of
/// these, not an `Evidence`, not a `SourceRef` with a real locator, and
/// certainly not credentials — those stay in the data layer that produced the
/// signal, which decides what is safe to redact into `text` in the first
/// place.
class SourceSignal {
  const SourceSignal({required this.text, required this.sensitivity});

  final String text;
  final DataSensitivity sensitivity;
}
