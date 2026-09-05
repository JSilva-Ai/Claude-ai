import '../evidence/data_sensitivity.dart';
import '../failures.dart';
import '../ids.dart';
import 'loop_state.dart';

/// One thing that was started and is not finished.
///
/// The aggregate root, and deliberately small. The rule that keeps it that way:
/// **what is derivable is not a field, what has a history is its own entity,
/// and what belongs to another node is a reference.** Risk, priority, staleness
/// and "is it overdue" are all absent because all four are read, not stored;
/// evidence and events are absent because both are their own append-only
/// records; the commitment and the suggestion are ids because they are other
/// things.
///
/// Every loop points at [basis]. A loop the person typed points at their own
/// [UserAssertion], so the rule holds with no exception for manual entry — and
/// with it holds the product's first promise: nothing is here that cannot be
/// explained.
///
/// Invariants are checked in the constructor and throw. A refused transition is
/// an outcome and returns a failure; a malformed loop is a bug, and a bug that
/// returns a value is a bug that gets ignored.
class Loop {
  Loop({
    required this.id,
    required this.title,
    required this.state,
    required this.basis,
    required this.evidence,
    required this.createdAt,
    required this.updatedAt,
    required this.stateChangedAt,
    this.commitment,
    this.suggestion,
    this.waitingOn,
    this.waitingSince,
    this.resolvedAt,
    this.abandonReason,
    this.suppressedUntil,
    this.pinned = false,
    this.sensitivity = DataSensitivity.ordinary,
    this.schemaVersion = 1,
    this.revision = 1,
  }) {
    _check();
  }

  final LoopId id;

  /// What the person would call it. Not interface copy — their words, or the
  /// source's.
  final String title;

  final LoopState state;

  /// The evidence this loop exists because of.
  final EvidenceId basis;

  /// Everything known to bear on it, including [basis].
  final List<EvidenceId> evidence;

  /// What was promised and by whom. The entity arrives in a later phase; the
  /// reference exists now so that phase does not reshape this one.
  final CommitmentId? commitment;

  /// The current proposal, when there is one. Same reasoning as [commitment].
  final ActionSuggestionId? suggestion;

  /// Who the loop is waiting on, and since when. Required in `waiting`,
  /// forbidden everywhere else: a loop that is waiting on nobody is a loop
  /// whose state is a lie.
  final PartyId? waitingOn;
  final DateTime? waitingSince;

  /// Set on resolution, cleared on reopening.
  final DateTime? resolvedAt;

  /// Required on abandonment. `notARealLoop` is the detector being wrong and is
  /// training signal; `decidedNotTo` is a person changing their mind and is
  /// not. Collapsing them would throw away the only correction detection gets.
  final AbandonReason? abandonReason;

  /// A window during which the person does not want to see this. Data, not
  /// state: "is it suppressed" is a question about now.
  final DateTime? suppressedUntil;

  final bool pinned;
  final DataSensitivity sensitivity;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime stateChangedAt;

  final int schemaVersion;

  /// Increments once per recorded change, and equals the sequence of the event
  /// that produced it. A gap between the two is detectable by arithmetic.
  final int revision;

  bool get isTerminal => state.isTerminal;

  /// Whether the person has asked not to see this at [now]. Derived, never
  /// stored — the same reasoning that keeps risk out of the state machine.
  bool isSuppressedAt(DateTime now) {
    final DateTime? until = suppressedUntil;
    return until != null && now.isBefore(until);
  }

  Loop copyWith({
    String? title,
    LoopState? state,
    List<EvidenceId>? evidence,
    CommitmentId? commitment,
    ActionSuggestionId? suggestion,
    PartyId? waitingOn,
    DateTime? waitingSince,
    DateTime? resolvedAt,
    AbandonReason? abandonReason,
    DateTime? suppressedUntil,
    bool? pinned,
    DateTime? updatedAt,
    DateTime? stateChangedAt,
    int? revision,
    bool clearWaiting = false,
    bool clearResolved = false,
    bool clearAbandonReason = false,
    bool clearSuppression = false,
  }) {
    return Loop(
      id: id,
      title: title ?? this.title,
      state: state ?? this.state,
      basis: basis,
      evidence: evidence ?? this.evidence,
      commitment: commitment ?? this.commitment,
      suggestion: suggestion ?? this.suggestion,
      waitingOn: clearWaiting ? null : (waitingOn ?? this.waitingOn),
      waitingSince: clearWaiting ? null : (waitingSince ?? this.waitingSince),
      resolvedAt: clearResolved ? null : (resolvedAt ?? this.resolvedAt),
      abandonReason:
          clearAbandonReason ? null : (abandonReason ?? this.abandonReason),
      suppressedUntil:
          clearSuppression ? null : (suppressedUntil ?? this.suppressedUntil),
      pinned: pinned ?? this.pinned,
      sensitivity: sensitivity,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stateChangedAt: stateChangedAt ?? this.stateChangedAt,
      schemaVersion: schemaVersion,
      revision: revision ?? this.revision,
    );
  }

  void _check() {
    if (title.trim().isEmpty) {
      throw LoopInvariantViolation('A loop must have a title');
    }
    if (!evidence.contains(basis)) {
      throw LoopInvariantViolation(
        'The basis $basis must be among the loop evidence',
      );
    }
    if (revision < 1 || schemaVersion < 1) {
      throw LoopInvariantViolation('revision and schemaVersion start at 1');
    }

    final bool waiting = state == LoopState.waiting;
    if (waiting && (waitingOn == null || waitingSince == null)) {
      throw LoopInvariantViolation(
        'A waiting loop must name who it waits on and since when',
      );
    }
    if (!waiting && (waitingOn != null || waitingSince != null)) {
      throw LoopInvariantViolation(
        'Only a waiting loop may carry waitingOn/waitingSince',
      );
    }

    final bool resolved = state == LoopState.resolved;
    if (resolved && resolvedAt == null) {
      throw LoopInvariantViolation('A resolved loop must record when');
    }
    if (!resolved && resolvedAt != null) {
      throw LoopInvariantViolation('Only a resolved loop may carry resolvedAt');
    }

    final bool abandoned = state == LoopState.abandoned;
    if (abandoned && abandonReason == null) {
      throw LoopInvariantViolation('An abandoned loop must record why');
    }
    if (!abandoned && abandonReason != null) {
      throw LoopInvariantViolation(
        'Only an abandoned loop may carry abandonReason',
      );
    }
  }

  @override
  String toString() => 'Loop($id, ${state.name}, rev $revision)';
}
