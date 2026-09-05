import '../evidence/claim.dart';
import '../ids.dart';
import 'policy_ref.dart';

/// How confident the deterministic detector is that this evidence expresses
/// this particular interpretation — never to be confused with the other
/// three numbers this codebase calls confidence.
///
/// Four distinct meanings now live in this system:
///
/// * `CaptureIntegrity` — is the record faithful to its source?
/// * `Confidence` (on an `Inference`) — is the *reading* right?
/// * `RecommendationConfidence` (on an `ActionSuggestion`) — is *this
///   suggestion* the right thing to propose?
/// * [CandidateConfidence] (here) — is *this candidate interpretation* what
///   the evidence actually expresses?
///
/// A candidate can be built from a rock-solid `ObservedFact` (verbatim
/// integrity) while the interpretation drawn from it is a weak guess — the
/// pattern matched, but only barely. The four are independent, so this is
/// its own type rather than a relabelled one: reusing `Confidence` here
/// would let a caller pass an inference's semantic confidence into a
/// candidate by accident and have the type system say nothing about it.
class CandidateConfidence {
  CandidateConfidence(this.value) {
    if (value.isNaN || value < 0 || value > 1) {
      throw ArgumentError.value(
        value,
        'value',
        'CandidateConfidence must be in 0..1',
      );
    }
  }

  final double value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateConfidence && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'CandidateConfidence(${value.toStringAsFixed(2)})';
}

/// The structured "why", in the form the brief asks for: reason codes, never
/// generated prose. Restricted to what the implemented rules can actually
/// produce — a reason with no rule behind it would be a claim the detector
/// cannot back up.
enum CommitmentSignalReason {
  /// "I'll ..." / "I will ..." — a first-person future-tense promise.
  firstPersonPromise,

  /// An explicit promise phrase not covered by [firstPersonPromise] — "I
  /// promise to ...".
  explicitPromisePhrase,

  /// "please `<verb>`" or "can/could/would you `<verb>`" — a direct request.
  explicitRequestVerb,

  /// The text names "you" as the apparent addressee of the action.
  directRecipient,

  /// "waiting for ..." — the speaker names something still outstanding.
  waitingLanguage,

  /// A recognised action verb is present. On its own too weak to imply a
  /// commitment; a supporting signal alongside a stronger one.
  actionVerbPresent,

  /// A confident, explicit deadline was resolved.
  explicitDeadline,

  /// A vaguer temporal cue was found ("soon", a bare weekday with no "by")
  /// but not confidently resolved, or resolved with lower certainty.
  weakTemporalSignal,

  /// Neither a clear first-person promise nor a clear direct request was
  /// found, even though action-oriented language is present — direction is
  /// genuinely unclear. Lowers confidence rather than blocking detection.
  ambiguousActor,
}

/// A detector's interpretation of some Evidence — not durable Commitment
/// truth.
///
/// This is the type the brief asks for directly: an interpretation that
/// *can* be uncertain, *can* be rejected, and *can* conflict with another
/// candidate over the same or different evidence, produced by a versioned
/// policy rather than asserted by a person. Nothing in this codebase
/// converts a [CommitmentCandidate] into a `Commitment` automatically —
/// that promotion is authority/reconciliation work belonging to a later
/// phase, and requires an explicit, separate act this type cannot itself
/// perform (it has no method that constructs a `Commitment`).
///
/// Deliberately close to [Claim] rather than duplicating it: what appears
/// committed, its counterparty and its deadline candidate all live on the
/// reused [claim] — a second, parallel "description" field would only be
/// able to disagree with the one already carried there. Direction (who
/// appears to owe whom) is likewise read from [Claim.kind]
/// (`oweDeliverable` vs `awaitingResponse`) rather than a separate role
/// field, with genuine ambiguity expressed through
/// [CommitmentSignalReason.ambiguousActor] in [reasons] instead of a third
/// enum value meaning "unknown".
class CommitmentCandidate {
  CommitmentCandidate({
    required this.id,
    required this.claim,
    required this.evidence,
    required this.confidence,
    required this.reasons,
    required this.producedBy,
    required this.evaluatedAt,
  }) {
    if (evidence.isEmpty) {
      throw ArgumentError.value(
        evidence,
        'evidence',
        'A candidate must be supported by at least one piece of evidence',
      );
    }
  }

  /// Composed, not generated — see [identifiedBy].
  factory CommitmentCandidate.identifiedBy({
    required List<EvidenceId> evidence,
    required Claim claim,
    required CandidateConfidence confidence,
    required List<CommitmentSignalReason> reasons,
    required PolicyRef producedBy,
    required DateTime evaluatedAt,
  }) =>
      CommitmentCandidate(
        id: CommitmentCandidateId(
          '${evidence.map((EvidenceId e) => e.value).join('+')}'
          ':${claim.kind.name}:$producedBy',
        ),
        claim: claim,
        evidence: evidence,
        confidence: confidence,
        reasons: reasons,
        producedBy: producedBy,
        evaluatedAt: evaluatedAt,
      );

  final CommitmentCandidateId id;

  /// What appears to be committed, reused wholesale from the evidence this
  /// candidate was drawn from.
  final Claim claim;

  /// The evidence supporting this interpretation. Never empty, and never a
  /// copy of its content — resolving these ids is how the explainability
  /// chain (candidate → reasons → evidence → source) is walked, the same
  /// `Provenance.of` machinery evidence already supports elsewhere.
  final List<EvidenceId> evidence;

  final CandidateConfidence confidence;

  final List<CommitmentSignalReason> reasons;

  /// Which detector, and which version, produced this. Never a model name:
  /// no AI port has an implementation yet, so every candidate in 3C is
  /// produced by a rule and says so.
  final PolicyRef producedBy;

  final DateTime evaluatedAt;

  @override
  String toString() => 'CommitmentCandidate($id, ${claim.kind.name}, '
      '$confidence, ${reasons.length} reasons)';
}
