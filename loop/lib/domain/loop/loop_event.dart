import '../ids.dart';
import 'loop_state.dart';

/// What happened, in the order it happened.
///
/// Append-only, and deliberately not event sourcing: the current state is
/// stored, and this log exists so the product can answer "why is this here",
/// "what have I already tried" and, later, "was that inference right". None of
/// those can be reconstructed after the fact, which is why the log starts now
/// and not when something needs it.
///
/// Identity is `(loop, sequence)` rather than a generated id. That removes the
/// need for randomness inside a layer that must stay deterministic, and it
/// makes a gap in the log detectable by arithmetic.
class LoopEvent {
  const LoopEvent({
    required this.loop,
    required this.sequence,
    required this.kind,
    required this.actor,
    required this.at,
    this.from,
    this.to,
    this.reason,
    this.evidence,
  });

  final LoopId loop;

  /// Equals the loop's `revision` after this event. Monotonic, gapless.
  final int sequence;

  final LoopEventKind kind;
  final TransitionActor actor;

  /// Supplied by the caller. The domain never reads a clock.
  final DateTime at;

  final LoopState? from;
  final LoopState? to;
  final AbandonReason? reason;

  /// Set when the event is about a specific piece of evidence.
  final EvidenceId? evidence;

  @override
  String toString() =>
      'LoopEvent(${kind.name} #$sequence ${from?.name} → ${to?.name})';
}

/// The kinds 2A can produce.
///
/// The architecture names more — commitment attached, deadline detected,
/// action suggested, approved, executed — and they are deliberately absent:
/// an event kind that nothing can emit is a promise the log cannot keep.
enum LoopEventKind {
  /// A loop the person created themselves.
  created,

  /// A loop proposed by detection, awaiting confirmation.
  detected,

  /// Any lifecycle move. Carries [LoopEvent.from] and [LoopEvent.to].
  stateChanged,

  /// New evidence attached to an existing loop. Not a transition: what a loop
  /// is *known by* can grow without its state moving at all.
  evidenceAttached,
}
