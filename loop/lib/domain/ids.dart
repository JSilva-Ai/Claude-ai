/// Identity.
///
/// Extension types rather than bare `String`s: they cost nothing at runtime —
/// the compiler erases them back to the string — and they make it impossible to
/// pass a [PartyId] where a [LoopId] is expected. In a system whose whole job is
/// relating one thing to another by reference, that is the mistake most likely
/// to happen and the hardest to see in a debugger.
///
/// They implement `Object`, so each inherits the underlying string's equality
/// and hash — exactly what a key needs — and deliberately do not override
/// `toString`, which an extension type implementing `Object` may not do.
///
/// The constructor is `const` and does not validate. Validation lives in
/// [parse], for the boundary where ids arrive as untrusted strings: that is
/// deserialisation, which belongs to 2C. Inside the domain an id is only ever
/// written as a literal or copied from another id, and a check there would cost
/// every call site the ability to be a constant to catch a typo the compiler
/// already catches.
///
/// Ids arrive from outside the domain. Generating them means randomness or a
/// clock, and neither belongs in a layer that must stay deterministic; the
/// composition root supplies them when persistence exists.
library;

extension type const LoopId(String value) implements Object {
  static LoopId parse(String raw) => LoopId(_checked(raw, 'LoopId'));
}

extension type const EvidenceId(String value) implements Object {
  static EvidenceId parse(String raw) =>
      EvidenceId(_checked(raw, 'EvidenceId'));
}

extension type const PartyId(String value) implements Object {
  static PartyId parse(String raw) => PartyId(_checked(raw, 'PartyId'));
}

/// Referenced, never dereferenced in this phase.
///
/// The loop can already point at a commitment and at a suggestion; the entities
/// behind these ids belong to 2B and later. Carrying the reference now is what
/// lets those phases arrive without reshaping the aggregate — and carrying only
/// the reference is what stops this phase from building them.
extension type const CommitmentId(String value) implements Object {
  static CommitmentId parse(String raw) =>
      CommitmentId(_checked(raw, 'CommitmentId'));
}

extension type const ActionSuggestionId(String value) implements Object {
  static ActionSuggestionId parse(String raw) =>
      ActionSuggestionId(_checked(raw, 'ActionSuggestionId'));
}

String _checked(String raw, String type) {
  if (raw.trim().isEmpty) {
    throw ArgumentError.value(raw, type, 'An id may not be empty');
  }
  return raw;
}
