import '../domain/evidence/evidence.dart';
import '../domain/evidence/provenance.dart';
import '../domain/ids.dart';
import '../domain/loop/loop.dart';
import '../domain/loop/loop_event.dart';
import '../domain/loop/loop_state_machine.dart';

/// A loop together with everything a deterministic policy needs to judge it.
///
/// Not a domain type — the domain has no reason to bundle a loop with its own
/// evidence and history, since [Provenance] and [SignalExtractor] already
/// take those as separate arguments. It exists here because the Home
/// projection needs exactly this shape for *every* loop at once, and asking
/// for it as one bounded read is what keeps that projection from becoming one
/// query per loop; see [LoopRepository.readAllLoopContexts].
class LoopContext {
  const LoopContext({
    required this.loop,
    required this.evidence,
    required this.events,
  });

  final Loop loop;

  /// Directly attached to [loop] — the membership `loop_evidence_links`
  /// records, not the transitive provenance chain. Evidence reachable only
  /// through another loop's [Evidence.id] (an `Inference.derivedFrom` that
  /// points outside this loop) is not repeated here; a resolver built across
  /// every [LoopContext] at once is how that chain still resolves — see
  /// `application/home/home_projector.dart`.
  final List<Evidence> evidence;

  final List<LoopEvent> events;
}

/// The one seam between the approved domain and where a [Loop] actually
/// lives. Every method here is justified by a use case this phase already
/// has — reading a loop, watching the list, persisting what the state
/// machine produced — not by "a database exists, so CRUD exists". There is
/// no `update(Loop)`, no `delete(anything)`, no raw query and no database
/// handle: a caller can only do what the domain's own state machine already
/// allows it to construct.
abstract interface class LoopRepository {
  /// The current loops, reactively. The one stream this contract exposes —
  /// evidence and event history are read on demand instead, because a
  /// separate stream for every nested list is exactly the excess the brief
  /// warns against.
  Stream<List<Loop>> watchLoops();

  Future<Loop?> getLoop(LoopId id);

  /// In the order they happened. See [LoopEvent] for why identity is
  /// `(loop, sequence)` rather than a generated id — the ordering this
  /// returns is that same sequence, not insertion order.
  Future<List<LoopEvent>> readEvents(LoopId loopId);

  /// Evidence directly attached to [loopId] — see [LoopContext.evidence] for
  /// why this is not the full provenance chain.
  Future<List<Evidence>> readEvidence(LoopId loopId);

  /// Resolves one piece of evidence by id, wherever it is attached. This is
  /// the read [Provenance.of] needs its [EvidenceResolver] built from when a
  /// chain reaches outside a single loop's own attached evidence.
  Future<Evidence?> getEvidenceById(EvidenceId id);

  /// Every loop, each with its own attached evidence and event history, in
  /// as few queries as the store can manage. Built for the Home projection —
  /// see [LoopContext] — and for anything later that needs the same "judge
  /// everything at once" shape; not a substitute for [watchLoops] or the
  /// single-loop reads above, which stay cheap for call sites that only need
  /// one loop.
  Future<List<LoopContext>> readAllLoopContexts();

  /// Persists what [LoopStateMachine] produced — a [LoopOutcome] is always
  /// exactly a mutated [Loop] plus the one [LoopEvent] that explains it,
  /// whether it came from `detect`, `create`, `apply` or `attachEvidence` —
  /// together with any evidence that operation newly introduced.
  ///
  /// Atomic: the loop's current state and its event log cannot be allowed to
  /// diverge, so [outcome.loop], [outcome.event] and every item in
  /// [newEvidence] (with its provenance links, if it is an [Inference]) are
  /// written in one transaction. A failure anywhere leaves every one of them
  /// unwritten — never the new state with a missing event, or the reverse.
  ///
  /// [newEvidence] is empty for an ordinary transition, which introduces no
  /// evidence of its own.
  Future<void> saveOutcome(
    LoopOutcome outcome, {
    List<Evidence> newEvidence = const <Evidence>[],
  });
}
