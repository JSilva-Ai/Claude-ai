import '../evidence/claim.dart';
import '../failures.dart';
import '../ids.dart';
import '../result.dart';
import 'commitment_status.dart';

/// A promise or an expectation, given identity and duration.
///
/// [Claim] already carries what is being asserted — kind, counterparty, a
/// deadline candidate, the source's own words. What it cannot carry is a
/// *lifetime*: embedded inside a single piece of evidence, two emails about
/// the same promise produce two disconnected claims with nothing to say they
/// are the same obligation. Commitment is that identity — a [Claim] given an
/// id, an evidence trail that can grow, and a status that outlives any one
/// piece of evidence. `Loop.commitment` has pointed at [CommitmentId] since
/// the domain's earliest phase specifically so this type would not have to
/// reshape [Loop] on arrival; this is what finally sits on the other end of
/// that reference.
///
/// This is not [Loop]. Loop is the operational thing the user tracks toward
/// closure; Commitment is the semantic thing that was promised, independent
/// of whether or how anyone is tracking it. A Loop may exist with no
/// Commitment behind it (nothing was promised to anyone — "buy milk"), and a
/// Commitment may exist with no Loop pointing at it yet.
///
/// Deliberately small, by the same rule that keeps [Loop] small: what is
/// derivable is not a field, what belongs to another node is a reference.
/// No confidence field — confidence belongs to the evidence and the
/// inference behind a Commitment, never to the durable claim itself, which
/// is either recorded or it is not. No party entity — [Claim.counterparty]
/// stays exactly the opaque id it already is. No reverse link to whichever
/// Loops may reference this Commitment — conceptually more than one Loop may
/// point here, but nothing on this side needs to know which, and no list is
/// carried for it.
///
/// Direction — who owes whom — is not a field of its own. [Claim.kind]
/// already distinguishes [ClaimKind.oweDeliverable] (the user owes the
/// counterparty) from [ClaimKind.awaitingResponse] (the counterparty owes
/// the user); reusing it is the whole answer, and a second, parallel role
/// field would only be able to disagree with the one Claim already carries.
///
/// Invariants are checked in the constructor and throw — a malformed
/// Commitment is a bug, the same discipline [Loop] applies to itself. A
/// refused *transition* is different: [fulfil], [cancel] and [supersede]
/// return a [Result] instead, because attempting one from a terminal status
/// is a legitimate race a future caller may hit, not a defect.
class Commitment {
  Commitment({
    required this.id,
    required this.claim,
    required this.basis,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
    this.status = CommitmentStatus.active,
    this.supersededBy,
    this.resolvedAt,
  }) {
    _check();
  }

  final CommitmentId id;

  /// What is being asserted: kind, counterparty, a deadline candidate, the
  /// source's own words. Reused wholesale rather than flattened into this
  /// class's own fields — [Claim] already says exactly this, and a second
  /// field carrying the same meaning would be the duplication the domain
  /// elsewhere refuses to keep.
  final Claim claim;

  /// The evidence this Commitment exists because of. Same discipline as
  /// [Loop.basis]: required, and always a member of [evidence].
  final EvidenceId basis;

  /// Everything known to bear on this Commitment, including [basis]. Grows
  /// over time as more evidence arrives — a revision or a contradiction is a
  /// new entry here, never an edit to an old one, and nothing in this type
  /// validates that later entries agree with earlier ones: a Commitment
  /// referencing two contradictory pieces of evidence is a legitimate,
  /// representable state, not one this constructor rejects.
  final List<EvidenceId> evidence;

  final CommitmentStatus status;

  /// Which Commitment replaced this one. Required exactly when [status] is
  /// [CommitmentStatus.superseded] — a superseded Commitment with nothing
  /// named as its replacement is a terminal state with no explanation, and
  /// this type refuses to represent one.
  final CommitmentId? supersededBy;

  /// When [status] left [CommitmentStatus.active]. Required for every
  /// terminal status, forbidden for the active one — the same shape
  /// [Loop.resolvedAt] already uses for its own, smaller terminal set, here
  /// covering all three terminal statuses rather than one each: a separate
  /// `fulfilledAt`/`cancelledAt`/`supersededAt` would be three copies of the
  /// same fact, and only one of them is ever set on any given Commitment.
  final DateTime? resolvedAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isTerminal => status.isTerminal;

  /// active → fulfilled. Delivered.
  Result<Commitment> fulfil({required DateTime now}) =>
      _transition(CommitmentStatus.fulfilled, now: now);

  /// active → cancelled. Will not happen.
  Result<Commitment> cancel({required DateTime now}) =>
      _transition(CommitmentStatus.cancelled, now: now);

  /// active → superseded, naming [by] as the replacement. [by] must be a
  /// different Commitment — nothing may supersede itself.
  Result<Commitment> supersede({
    required CommitmentId by,
    required DateTime now,
  }) {
    if (by == id) {
      return const Err<Commitment>(
        OperationRefused('a commitment may not supersede itself'),
      );
    }
    return _transition(CommitmentStatus.superseded, now: now, by: by);
  }

  Result<Commitment> _transition(
    CommitmentStatus to, {
    required DateTime now,
    CommitmentId? by,
  }) {
    if (status != CommitmentStatus.active) {
      return Err<Commitment>(
        IllegalCommitmentTransition(from: status, to: to),
      );
    }
    return Ok<Commitment>(
      Commitment(
        id: id,
        claim: claim,
        basis: basis,
        evidence: evidence,
        status: to,
        supersededBy: by,
        resolvedAt: now,
        createdAt: createdAt,
        updatedAt: now,
      ),
    );
  }

  void _check() {
    if (!evidence.contains(basis)) {
      throw LoopInvariantViolation(
        'The basis $basis must be among the commitment evidence',
      );
    }

    final bool superseded = status == CommitmentStatus.superseded;
    if (superseded && supersededBy == null) {
      throw LoopInvariantViolation(
        'A superseded commitment must name its replacement',
      );
    }
    if (!superseded && supersededBy != null) {
      throw LoopInvariantViolation(
        'Only a superseded commitment may carry supersededBy',
      );
    }
    if (supersededBy == id) {
      throw LoopInvariantViolation('A commitment may not supersede itself');
    }

    final bool terminal = status.isTerminal;
    if (terminal && resolvedAt == null) {
      throw LoopInvariantViolation('A terminal commitment must record when');
    }
    if (!terminal && resolvedAt != null) {
      throw LoopInvariantViolation(
        'Only a terminal commitment may carry resolvedAt',
      );
    }
  }

  @override
  String toString() => 'Commitment($id, ${status.name})';
}
