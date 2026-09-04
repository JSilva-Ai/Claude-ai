import 'package:flutter_test/flutter_test.dart';
import 'package:loop/application/loop_repository.dart';
import 'package:loop/application/persistence_failure.dart';
import 'package:loop/core/utils/clock.dart';
import 'package:loop/domain/evidence/evidence.dart';
import 'package:loop/domain/ids.dart';
import 'package:loop/domain/loop/loop.dart';
import 'package:loop/domain/loop/loop_event.dart';
import 'package:loop/domain/loop/loop_state_machine.dart';
import 'package:loop/features/home/data/home_repository.dart';
import 'package:loop/features/home/data/loop_home_repository.dart';
import 'package:loop/features/home/models/home_snapshot.dart';
import 'package:loop/features/home/models/user_profile.dart';

import '../../../application/in_memory_loop_repository.dart';
import '../../../domain/fixtures.dart';

/// Throws whatever it is given from [readAllLoopContexts], so the mapping
/// in [LoopHomeRepository.fetchHome] can be tested without needing a real
/// Drift failure to occur.
class _ThrowingRepository implements LoopRepository {
  _ThrowingRepository(this._failure);

  final PersistenceFailure _failure;

  @override
  Stream<List<Loop>> watchLoops() => const Stream<List<Loop>>.empty();

  @override
  Future<Loop?> getLoop(LoopId id) async => null;

  @override
  Future<List<LoopEvent>> readEvents(LoopId loopId) async =>
      const <LoopEvent>[];

  @override
  Future<List<Evidence>> readEvidence(LoopId loopId) async =>
      const <Evidence>[];

  @override
  Future<Evidence?> getEvidenceById(EvidenceId id) async => null;

  @override
  Future<List<LoopContext>> readAllLoopContexts() async => throw _failure;

  @override
  Future<void> saveOutcome(
    LoopOutcome outcome, {
    List<Evidence> newEvidence = const <Evidence>[],
  }) async =>
      throw _failure;
}

void main() {
  const LoopStateMachine machine = LoopStateMachine();

  group('LoopHomeRepository', () {
    test('an empty store produces a valid, empty HomeSnapshot — not an '
        'error, not fabricated content', () async {
      final InMemoryLoopRepository repository = InMemoryLoopRepository();
      final LoopHomeRepository homeRepository = LoopHomeRepository(
        repository: repository,
        clock: FixedClock(t0),
      );

      final HomeSnapshot snapshot = await homeRepository.fetchHome();

      expect(snapshot.activeLoops, 0);
      expect(snapshot.closedCount, 0);
      expect(snapshot.isEmpty, isTrue);
      expect(snapshot.profile, UserProfile.anonymous);
    });

    test('a stored loop is reflected in the fetched HomeSnapshot', () async {
      final InMemoryLoopRepository repository = InMemoryLoopRepository();
      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repository.saveOutcome(created, newEvidence: <Evidence>[basis]);

      final LoopHomeRepository homeRepository = LoopHomeRepository(
        repository: repository,
        clock: FixedClock(t0),
      );
      final HomeSnapshot snapshot = await homeRepository.fetchHome();

      expect(snapshot.activeLoops, 1);
    });

    test('profile defaults to UserProfile.anonymous — never a fabricated '
        'name', () {
      final LoopHomeRepository homeRepository = LoopHomeRepository(
        repository: InMemoryLoopRepository(),
      );
      expect(homeRepository.profile, UserProfile.anonymous);
    });

    test('changes fires after a write reaches the repository', () async {
      final InMemoryLoopRepository repository = InMemoryLoopRepository();
      final LoopHomeRepository homeRepository = LoopHomeRepository(
        repository: repository,
      );

      final List<void> events = <void>[];
      final subscription = homeRepository.changes.listen(events.add);
      await Future<void>.delayed(Duration.zero);

      final ObservedFact basis = fact(id: basisId.value);
      final LoopOutcome created = machine.create(
        id: loopId,
        title: 'x',
        basis: basis.id,
        now: t0,
      );
      await repository.saveOutcome(created, newEvidence: <Evidence>[basis]);
      await Future<void>.delayed(Duration.zero);

      expect(events, isNotEmpty);
      await subscription.cancel();
    });

    test('a persistence failure surfaces as HomeLoadFailure, never the raw '
        'PersistenceFailure or anything Drift-shaped', () async {
      final _ThrowingRepository repository = _ThrowingRepository(
        const PersistenceConstraintViolation('simulated FK violation'),
      );
      final LoopHomeRepository homeRepository = LoopHomeRepository(
        repository: repository,
      );

      await expectLater(
        homeRepository.fetchHome,
        throwsA(isA<HomeLoadFailure>()),
      );
    });
  });
}
