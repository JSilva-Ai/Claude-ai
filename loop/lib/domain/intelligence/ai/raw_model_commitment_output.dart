/// What a model literally returns, before anything here trusts it.
///
/// Every field is deliberately weak-typed the way real structured output
/// actually arrives — a claim kind is a string token, not a [ClaimKind],
/// because a provider returns text, not a Dart enum — and that is exactly
/// why `ModelOutputValidator` exists: nothing downstream reads this class
/// directly as domain truth. There is no field here for an email to send, a
/// calendar entry to write, or any tool call at all — not because a rule
/// forbids it, but because the schema itself has nowhere to put one, which
/// is what makes "the model tried to request an action" structurally
/// impossible to honour rather than a policy this phase has to remember to
/// enforce.
class RawModelCommitmentOutput {
  const RawModelCommitmentOutput({
    required this.hasCandidate,
    this.claimKind,
    this.evidenceIds = const <String>[],
    this.reasonCodes = const <String>[],
    this.confidence,
    this.deadlineIso,
    this.sourceQuote,
  });

  /// The model's own answer to "is there a commitment here at all". False
  /// is a legitimate, complete answer — every other field is ignored when
  /// this is false.
  final bool hasCandidate;

  /// Expected to name a `ClaimKind` value by its Dart name — anything else
  /// is rejected, never guessed at.
  final String? claimKind;

  /// The evidence ids the model claims support this candidate. Validated as
  /// a subset of the ids the request actually offered — an id outside that
  /// set is treated as a hallucination and rejects the whole output; see
  /// `ModelOutputValidator`.
  final List<String> evidenceIds;

  /// Expected to name `CommitmentSignalReason` values by their Dart names —
  /// the same closed set the deterministic detector produces, so a
  /// candidate from either source is explainable the same way.
  final List<String> reasonCodes;

  final double? confidence;

  /// ISO-8601 or null. A model that is unsure of a date is expected to omit
  /// this rather than invent one; the validator parses defensively and
  /// rejects anything that does not parse rather than guessing at intent.
  final String? deadlineIso;

  /// The evidence text the model is quoting as its basis — never generated
  /// prose about what the evidence means, the same discipline
  /// `Claim.sourceQuote` already holds deterministic detection to.
  final String? sourceQuote;
}
