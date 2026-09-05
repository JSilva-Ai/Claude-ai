/// How faithfully the record reflects its source.
///
/// This is *not* confidence about meaning, and keeping the two apart is the
/// point. "Did we transcribe it correctly?" and "did we understand it
/// correctly?" are different questions with different failure modes, and a
/// single number for both hides the worse one: a model can be very sure about
/// a sentence we read wrong.
///
/// Not a probability — an enum with a ceiling. Each level caps how confident
/// any inference drawn from such a fact is permitted to become.
enum CaptureIntegrity {
  /// Read from the source's own structured field. Nothing was interpreted.
  verbatim(1.0),

  /// Extracted from a known structure — a parsed header, a calendar field.
  parsed(0.95),

  /// Recovered from something lossy: OCR, speech, loose HTML.
  transcribed(0.80),

  /// The person told us. Honest, and not independently checkable.
  userReported(0.90);

  const CaptureIntegrity(this.confidenceCeiling);

  /// The highest semantic confidence an inference derived from this fact may
  /// carry, however certain its producer claims to be.
  final double confidenceCeiling;
}
