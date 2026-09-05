import '../ids.dart';

/// What is being claimed, as structure rather than as a sentence.
///
/// A claim written as text would be a claim written in one language, and the
/// domain has to mean the same thing in three. The kind is an enum the
/// presentation layer renders; the only free text permitted is [sourceQuote],
/// which is not our words but the world's — the fragment that was actually
/// observed, kept so the explanation can show it.
enum ClaimKind {
  /// Someone owes the user a reply or a thing.
  awaitingResponse,

  /// The user owes someone a reply or a thing.
  oweDeliverable,

  /// Something is due by a date.
  deadlineExists,

  /// A meeting or appointment exists.
  meetingScheduled,

  /// Recognised as a commitment, of a shape not yet modelled.
  other,
}

class Claim {
  const Claim({
    required this.kind,
    this.counterparty,
    this.by,
    this.sourceQuote,
  });

  final ClaimKind kind;

  /// The other side of the commitment, when it has one.
  final PartyId? counterparty;

  /// The moment the claim points at, when it has one.
  final DateTime? by;

  /// Observed text, quoted. Never interface copy, never generated prose.
  final String? sourceQuote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Claim &&
          other.kind == kind &&
          other.counterparty == counterparty &&
          other.by == by &&
          other.sourceQuote == sourceQuote;

  @override
  int get hashCode => Object.hash(kind, counterparty, by, sourceQuote);

  @override
  String toString() => 'Claim(${kind.name})';
}
