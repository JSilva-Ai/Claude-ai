import 'package:flutter_test/flutter_test.dart';
import 'package:loop/features/home/data/home_repository.dart';
import 'package:loop/features/home/models/home_snapshot.dart';
import 'package:loop/features/home/models/loop_category.dart';
import 'package:loop/features/home/models/user_profile.dart';
import 'package:loop/features/home/state/home_controller.dart';
import 'package:loop/features/home/state/home_state.dart';

/// A repository that answers on command, so the test controls the ordering
/// instead of racing a timer.
class _FakeRepository implements HomeRepository {
  _FakeRepository();

  int calls = 0;
  Object? error;
  HomeSnapshot snapshot = const HomeSnapshot(
    profile: UserProfile(id: 'u', displayName: 'Jorge'),
    summaries: <LoopCategory, int>{LoopCategory.atRisk: 1},
  );

  @override
  Future<HomeSnapshot> fetchHome() async {
    calls++;
    final Object? error = this.error;
    if (error != null) throw error;
    return snapshot;
  }
}

void main() {
  group('HomeController', () {
    test('starts loading and settles on ready', () async {
      final _FakeRepository repository = _FakeRepository();
      final HomeController controller = HomeController(repository: repository);

      expect(controller.state, isA<HomeLoading>());
      await controller.load();
      expect(controller.state, isA<HomeReady>());
    });

    test('a failed cold load surfaces the error', () async {
      final _FakeRepository repository = _FakeRepository()
        ..error = const HomeLoadFailure('boom');
      final HomeController controller = HomeController(repository: repository);

      await controller.load();

      expect(controller.state, isA<HomeFailure>());
      expect((controller.state as HomeFailure).error, isA<HomeLoadFailure>());
    });

    test('a failed refresh keeps the data already on screen', () async {
      final _FakeRepository repository = _FakeRepository();
      final HomeController controller = HomeController(repository: repository);
      await controller.load();

      repository.error = const HomeLoadFailure('offline');
      await controller.refresh();

      // The user was reading a working page; an error banner replacing it
      // would lose information they already had.
      expect(controller.state, isA<HomeReady>());
      expect((controller.state as HomeReady).isRefreshing, isFalse);
    });

    test('a second load while one is in flight is ignored', () async {
      final _FakeRepository repository = _FakeRepository();
      final HomeController controller = HomeController(repository: repository);

      await Future.wait(<Future<void>>[controller.load(), controller.load()]);

      expect(repository.calls, 1);
    });

    test('notifies its listeners', () async {
      final _FakeRepository repository = _FakeRepository();
      final HomeController controller = HomeController(repository: repository);
      int notifications = 0;
      controller.addListener(() => notifications++);

      await controller.load();

      expect(notifications, greaterThan(0));
    });
  });
}
