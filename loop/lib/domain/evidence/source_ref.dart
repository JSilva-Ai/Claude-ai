/// Where a fact came from.
enum EvidenceSource { manual, email, calendar, message, document, note }

/// A pointer back to the origin, not a copy of it.
///
/// Data minimisation as a type: [locator] identifies the message or event at
/// its source, and that is enough to explain and to re-read. Mirroring the
/// whole body onto the device would be a liability with no matching benefit —
/// the excerpt on the fact is what the explanation actually shows.
class SourceRef {
  const SourceRef({
    required this.source,
    required this.locator,
    this.accountRef,
  });

  final EvidenceSource source;

  /// Opaque to the domain: `gmail:thread/9f2`, `calendar:event/abc`. Its shape
  /// is the adapter's business; its stability is what makes de-duplication
  /// possible later.
  final String locator;

  /// Which connected account, when there is more than one. Never a credential.
  final String? accountRef;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceRef &&
          other.source == source &&
          other.locator == locator &&
          other.accountRef == accountRef;

  @override
  int get hashCode => Object.hash(source, locator, accountRef);

  @override
  String toString() => 'SourceRef(${source.name}:$locator)';
}
