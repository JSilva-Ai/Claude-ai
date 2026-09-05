import '../../evidence/source_ref.dart';
import '../../ids.dart';

/// What kind of inference is being asked for. One value today —
/// [commitmentDetection] — because that is the only task this phase builds;
/// the enum exists so a future inference kind does not require redesigning
/// the request shape around it.
enum ModelInferenceKind { commitmentDetection }

/// One piece of Evidence, reduced to exactly what an external inference call
/// may see.
///
/// Deliberately narrower than `Evidence`/`ObservedFact` itself: [text] is
/// already redacted — the same discipline `SourceSignal` already applies at
/// the deterministic-detector boundary — and [sourceKind] is the one other
/// fact validation needs (see `ModelOutputValidator`'s authorship check).
/// Nothing else about the source crosses this boundary: no locator, no
/// account reference, no capture integrity, no sensitivity flag a model has
/// no way to act on correctly.
class ModelEvidenceView {
  const ModelEvidenceView({
    required this.id,
    required this.text,
    required this.sourceKind,
  });

  final EvidenceId id;
  final String text;
  final EvidenceSource sourceKind;
}

/// The one typed boundary a model inference request crosses through.
///
/// No service in this codebase builds a prompt string by hand and sends it
/// somewhere; every request is one of these, and every field on it is here
/// because `ModelOutputValidator` or a future adapter genuinely needs it —
/// not because a richer payload seemed convenient. In particular this is not
/// a mailbox, a conversation, or a database handle: [evidence] is the
/// already-minimized, request-specific projection `sanitize` below builds,
/// never the caller's full Evidence store.
///
/// [referenceTime] is required, and nothing in this file or its adapters
/// reads a clock — the same discipline every deterministic policy in this
/// layer already holds to, extended here to the one place a network call
/// could otherwise have quietly reintroduced one.
class ModelInferenceRequest {
  const ModelInferenceRequest({
    required this.kind,
    required this.evidence,
    required this.locale,
    required this.referenceTime,
  }) : assert(evidence.length > 0, 'a request must carry at least one item');

  final ModelInferenceKind kind;

  /// Never empty — see the constructor assertion. An empty request has
  /// nothing for a model to reason about and nothing for
  /// [ModelOutputValidator] to check a candidate's evidence references
  /// against.
  final List<ModelEvidenceView> evidence;

  /// An explicit locale, e.g. `'en'`. 3C's deterministic rules are
  /// English-only; carrying this on every request is what lets an adapter
  /// — and a future evaluation run — know which language it was actually
  /// asked about, rather than assuming.
  final String locale;

  final DateTime referenceTime;

  /// A deterministic identity for this request's *content* — evidence ids,
  /// locale and reference time — independent of which model or prompt
  /// version eventually answers it. Two requests built from the same
  /// evidence set, locale and reference time always produce the same key,
  /// which is what makes a future inference cache or a reproducibility
  /// check possible without a random request id standing in for identity.
  /// Full reproducibility of a specific *answer* additionally needs the
  /// model id and prompt version recorded on the response's own
  /// [ModelInferenceMetadata] — this key is the request half of that pair,
  /// not the whole of it.
  String get requestKey {
    final String ids = evidence.map((ModelEvidenceView e) => e.id.value).join(
          '+',
        );
    return '$ids|$locale|${referenceTime.toIso8601String()}';
  }
}
