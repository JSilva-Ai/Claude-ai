import 'dart:async';

import 'package:loop/application/loop_repository.dart';
import 'package:loop/application/persistence_failure.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';

/// A hand-written double, in the spirit the domain's own test suites already
/// use — not a mock framework, and not a second copy of the Drift
/// implementation with the SQL filed off. It exists so
/// `loop_repository_contract.dart` can prove the *contract* — what a caller
/// is allowed to observe — independently of how `DriftLoopRepository`
/// happens to store it.
///
/// Enforces the same two invariants the schema enforces by constraint: no
/// duplicate evidence id, no duplicate `(loop, sequence)` event, and every
/// write in [saveOutcome] is validated before anything is mutated, so a
/// refused write leaves nothing partially applied — the in-memory analogue
/// of a transaction rolling back.
class InMemoryLoopRepository implements LoopRepository {
  final Map<String, Loop> _loops = <String, Loop>{};
  final Map<String, Evidence> _evidence = <String, Evidence>{};
  final Map<String, List<String>> _evidenceIdsByLoop = <String, List<String>>{};
  final Map<String, List<LoopEvent>> _eventsByLoop =
      <String, List<LoopEvent>>{};
  final Set<String> _eventKeys = <String>{};

  final StreamController<List<Loop>> _controller =
      StreamController<List<Loop>>.broadcast();

  @override
  Stream<List<Loop>> watchLoops() async* {
    yield List<Loop>.unmodifiable(_loops.values);
    yield* _controller.stream;
  }

  @override
  Future<Loop?> getLoop(LoopId id) async => _loops[id.value];

  @override
  Future<List<LoopEvent>> readEvents(LoopId loopId) async =>
      List<LoopEvent>.unmodifiable(_eventsByLoop[loopId.value] ?? const []);

  @override
  Future<List<Evidence>> readEvidence(LoopId loopId) async {
    final List<String> ids = _evidenceIdsByLoop[loopId.value] ?? const [];
    return ids.map((id) => _evidence[id]).whereType<Evidence>().toList();
  }

  @override
  Future<Evidence?> getEvidenceById(EvidenceId id) async => _evidence[id.value];

  @override
  Future<List<LoopContext>> readAllLoopContexts() async {
    return _loops.values
        .map(
          (loop) => LoopContext(
            loop: loop,
            evidence: (_evidenceIdsByLoop[loop.id.value] ?? const [])
                .map((id) => _evidence[id])
                .whereType<Evidence>()
                .toList(),
            events: List<LoopEvent>.unmodifiable(
              _eventsByLoop[loop.id.value] ?? const [],
            ),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveOutcome(
    LoopOutcome outcome, {
    List<Evidence> newEvidence = const <Evidence>[],
  }) async {
    // Validate first — nothing below this point may throw.
    for (final Evidence evidence in newEvidence) {
      if (_evidence.containsKey(evidence.id.value)) {
        throw PersistenceConstraintViolation(
          'evidence ${evidence.id.value} already exists',
        );
      }
      if (evidence is Inference) {
        for (final EvidenceId source in evidence.derivedFrom) {
          final bool existsAlready = _evidence.containsKey(source.value);
          final bool existsInThisBatch = newEvidence.any((e) => e.id == source);
          if (!existsAlready && !existsInThisBatch) {
            throw PersistenceConstraintViolation(
              'derivedFrom evidence $source does not exist',
            );
          }
        }
      }
    }
    final String eventKey =
        '${outcome.event.loop.value}#${outcome.event.sequence}';
    if (_eventKeys.contains(eventKey)) {
      throw PersistenceConstraintViolation('duplicate event $eventKey');
    }

    for (final Evidence evidence in newEvidence) {
      _evidence[evidence.id.value] = evidence;
      (_evidenceIdsByLoop[outcome.loop.id.value] ??= <String>[])
          .add(evidence.id.value);
    }
    _loops[outcome.loop.id.value] = outcome.loop;
    (_eventsByLoop[outcome.loop.id.value] ??= <LoopEvent>[]).add(outcome.event);
    _eventKeys.add(eventKey);

    _controller.add(List<Loop>.unmodifiable(_loops.values));
  }

  Future<void> close() => _controller.close();
}
