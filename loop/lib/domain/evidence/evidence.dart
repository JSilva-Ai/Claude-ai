import '../ids.dart';
import 'capture_integrity.dart';
import 'claim.dart';
import 'confidence.dart';
import 'data_sensitivity.dart';
import 'source_ref.dart';

/// Why the system believes anything.
///
/// Three kinds, sealed, so the difference between *observed*, *concluded* and
/// *asserted by the person* lives in the type system rather than in a
/// convention that survives until the first hurried afternoon. This is the
/// distinction the whole product rests on: an engine that can quietly promote
/// an inference to a fact is an engine that will eventually tell someone they
/// promised something they never promised.
///
/// Immutable and append-only. Nothing here is ever edited — a later opinion is
/// a new piece of evidence, which is what makes it possible to find out, months
/// from now, that a producer was wrong.
sealed class Evidence {
  const Evidence({
    required this.id,
    required this.capturedAt,
    this.sensitivity = DataSensitivity.ordinary,
  });

  final EvidenceId id;

  /// Supplied by the caller. The domain reads no clock.
  final DateTime capturedAt;

  final DataSensitivity sensitivity;
}

/// Something the world actually said, with a pointer back to where it said it.
///
/// A fact carries no semantic confidence: what is uncertain about "he wrote
/// 'I'll send it Friday'" is never the text, it is what the text *means*. What
/// a fact does carry is [integrity] — how faithfully this record reflects the
/// source — which is a different axis entirely, and which caps how sure any
/// reading of it may become.
final class ObservedFact extends Evidence {
  const ObservedFact({
    required super.id,
    required super.capturedAt,
    required this.source,
    required this.integrity,
    this.excerpt,
    super.sensitivity,
  });

  final SourceRef source;
  final CaptureIntegrity integrity;

  /// A short, redactable fragment. Enough to explain; never the whole body.
  final String? excerpt;

  @override
  String toString() => 'ObservedFact($id, ${integrity.name})';
}

/// A conclusion drawn from other evidence.
///
/// [derivedFrom] may not be empty, and that is enforced in the constructor
/// rather than documented: an orphan conclusion is exactly the thing the
/// product must never be able to show, because it is the one that cannot be
/// explained. Provenance is therefore guaranteed by construction, not by care.
final class Inference extends Evidence {
  Inference({
    required super.id,
    required super.capturedAt,
    required this.derivedFrom,
    required this.claim,
    required this.confidence,
    required this.producedBy,
    super.sensitivity,
  }) : assert(true) {
    if (derivedFrom.isEmpty) {
      throw ArgumentError.value(
        derivedFrom,
        'derivedFrom',
        'An inference must derive from at least one piece of evidence',
      );
    }
  }

  final List<EvidenceId> derivedFrom;
  final Claim claim;
  final Confidence confidence;
  final ProducerRef producedBy;

  /// A new inference, same lineage, different number.
  ///
  /// Returns a *new* object on purpose: raising or lowering confidence never
  /// mutates what was recorded, so the original reading — and the fact that it
  /// was wrong — survives.
  Inference withConfidence(Confidence next) => Inference(
        id: id,
        capturedAt: capturedAt,
        derivedFrom: derivedFrom,
        claim: claim,
        confidence: next,
        producedBy: producedBy,
        sensitivity: sensitivity,
      );

  @override
  String toString() => 'Inference($id, ${claim.kind.name}, $confidence)';
}

/// What the person said.
enum AssertionKind {
  /// "Yes, track this." Raises confidence in the inference it is about.
  confirms,

  /// "No, that is not a commitment." Drops it to zero, without erasing it.
  rejects,

  /// A commitment the person entered themselves. Its own ground.
  states,
}

/// The person's own word, recorded as evidence like any other.
///
/// A loop someone typed is not a loop without provenance — its provenance is
/// this. That is what lets the rule "every loop points at evidence" hold with
/// no exception for manual entry, and it is why confirmation is *added*
/// alongside an inference rather than written over it.
final class UserAssertion extends Evidence {
  UserAssertion({
    required super.id,
    required super.capturedAt,
    required this.kind,
    required this.claim,
    this.about,
    super.sensitivity,
  }) {
    final bool needsSubject =
        kind == AssertionKind.confirms || kind == AssertionKind.rejects;
    if (needsSubject && about == null) {
      throw ArgumentError.value(
        about,
        'about',
        'A ${kind.name} assertion must name the evidence it judges',
      );
    }
  }

  final AssertionKind kind;
  final Claim claim;

  /// The inference being judged. Null only for [AssertionKind.states].
  final EvidenceId? about;

  @override
  String toString() => 'UserAssertion($id, ${kind.name})';
}
