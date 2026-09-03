import '../evidence/capture_integrity.dart';
import '../evidence/confidence.dart';
import '../evidence/evidence.dart';
import '../evidence/provenance.dart';
import '../loop/loop.dart';
import '../loop/loop_event.dart';
import '../loop/loop_state.dart';

/// Everything the deterministic policies are allowed to look at, derived once.
///
/// Two reasons this exists rather than each policy reaching into the loop
/// itself. It is the honest inventory of what this product can actually observe
/// today — every field here comes from something 2A records, and a reason code
/// with no field behind it is a signal we invented. And it is computed once, so
/// risk, attention and the suggestions all judge the same picture: three
/// policies each re-deriving "is this overdue" is three chances to disagree.
class LoopSignals {
  const LoopSignals({
    required this.state,
    required this.now,
    required this.isPinned,
    required this.isSuppressed,
    this.deadline,
    this.timeUntilDeadline,
    this.waitingFor,
    this.proposalAge,
    this.basisConfidence,
    this.weakestIntegrity,
    this.contradictedByUser = false,
    this.evidenceUngrounded = false,
    this.failedVerifications = 0,
    this.hasCounterparty = false,
  });

  final LoopState state;

  /// The moment every judgement was made against. Supplied, never read from a
  /// clock — the whole layer stays deterministic and replayable.
  final DateTime now;

  final bool isPinned;
  final bool isSuppressed;

  /// From the claims on the loop's evidence. There is no commitment entity yet;
  /// the date lives where 2A actually puts it.
  final DateTime? deadline;
  final Duration? timeUntilDeadline;

  /// How long the loop has been waiting on someone else.
  final Duration? waitingFor;

  /// How long an unconfirmed proposal has been sitting there.
  final Duration? proposalAge;

  /// The semantic confidence of the inference the loop stands on, when it
  /// stands on one. A loop the person typed has none, and that is not a defect.
  final Confidence? basisConfidence;

  /// The weakest capture integrity anywhere in the loop's lineage.
  final CaptureIntegrity? weakestIntegrity;

  /// The person rejected the reading this loop is based on.
  final bool contradictedByUser;

  /// The provenance chain could not be completed — a link is missing.
  final bool evidenceUngrounded;

  /// How many times a closure was checked and did not hold.
  final int failedVerifications;

  /// Whether the loop names another party. Not who — that belongs to the
  /// commitment graph, which is not built.
  final bool hasCounterparty;

  bool get isOverdue {
    final Duration? left = timeUntilDeadline;
    return left != null && left.isNegative && state.isActive;
  }

  @override
  String toString() =>
      'LoopSignals(${state.name}, deadline $deadline, waiting $waitingFor)';
}

/// Reads the domain and produces [LoopSignals].
///
/// The one place that knows how a signal is extracted. Everything downstream
/// works from the result, so a policy cannot quietly invent an input.
class SignalExtractor {
  const SignalExtractor({this.staleProposalAfter = const Duration(days: 14)});

  /// Only used to expose a proposal's age; the decision about what to do with
  /// that age belongs to the policies, and the decision to *mutate* anything
  /// belongs to a reconciliation pass, as 2A established.
  final Duration staleProposalAfter;

  LoopSignals extract(
    Loop loop, {
    required EvidenceResolver evidence,
    required DateTime now,
    List<LoopEvent> history = const <LoopEvent>[],
  }) {
    final ProvenanceChain chain = Provenance.of(loop.basis, evidence);

    DateTime? deadline;
    CaptureIntegrity? weakest;
    Confidence? basisConfidence;
    bool hasCounterparty = false;

    for (final ProvenanceNode node in chain.nodes) {
      final Evidence e = node.evidence;
      switch (e) {
        case ObservedFact(:final CaptureIntegrity integrity):
          if (weakest == null ||
              integrity.confidenceCeiling < weakest.confidenceCeiling) {
            weakest = integrity;
          }
        case Inference(:final Confidence confidence):
          if (e.id == loop.basis) basisConfidence = confidence;
          deadline = _earlier(deadline, e.claim.by);
          hasCounterparty |= e.claim.counterparty != null;
        case UserAssertion():
          deadline = _earlier(deadline, e.claim.by);
          hasCounterparty |= e.claim.counterparty != null;
      }
    }

    // A rejection recorded against the loop's basis. The inference itself is
    // untouched — 2A guarantees that — so the contradiction has to be read from
    // the assertion beside it rather than from a mutated confidence.
    final bool contradicted = _rejects(loop, evidence);

    return LoopSignals(
      state: loop.state,
      now: now,
      isPinned: loop.pinned,
      isSuppressed: loop.isSuppressedAt(now),
      deadline: deadline,
      timeUntilDeadline: deadline?.difference(now),
      waitingFor:
          loop.waitingSince == null ? null : now.difference(loop.waitingSince!),
      proposalAge: loop.state == LoopState.detected
          ? now.difference(loop.stateChangedAt)
          : null,
      basisConfidence: basisConfidence,
      weakestIntegrity: weakest,
      contradictedByUser: contradicted,
      evidenceUngrounded: !chain.isGrounded,
      failedVerifications: history
          .where(
            (LoopEvent e) =>
                e.from == LoopState.verifying && e.to == LoopState.open,
          )
          .length,
      hasCounterparty: hasCounterparty || loop.waitingOn != null,
    );
  }

  bool _rejects(Loop loop, EvidenceResolver resolve) {
    for (final id in loop.evidence) {
      final Evidence? e = resolve(id);
      if (e is UserAssertion &&
          e.kind == AssertionKind.rejects &&
          e.about == loop.basis) {
        return true;
      }
    }
    return false;
  }

  DateTime? _earlier(DateTime? current, DateTime? candidate) {
    if (candidate == null) return current;
    if (current == null) return candidate;
    return candidate.isBefore(current) ? candidate : current;
  }
}
