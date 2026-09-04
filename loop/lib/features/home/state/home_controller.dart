import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/home_repository.dart';
import 'home_state.dart';

/// Owns the Home's state.
///
/// A [ChangeNotifier] and nothing else. The alternative was a state-management
/// package, and at one screen with one repository it would have bought
/// indirection rather than capability: this class is already testable without
/// a widget tree, already replaceable behind [HomeScope], and already the only
/// thing that would need rewriting if the project later adopts Riverpod.
/// Adding a dependency to earn what the framework gives away is not free — it
/// is a version to track and a convention every future contributor must learn.
///
/// Reactive updates ride the same path a manual [refresh] already did,
/// rather than a second state system next to it: the controller subscribes
/// to [HomeRepository.changes] once, in its own constructor, and every event
/// just calls [refresh]. A repository with nothing reactive behind it (the
/// mock) never fires, so this is a no-op for every existing test and
/// screenshot — the subscription exists, it is simply never triggered.
class HomeController extends ChangeNotifier {
  HomeController({required HomeRepository repository})
      : _repository = repository {
    _changes = _repository.changes.listen((_) => refresh());
  }

  final HomeRepository _repository;
  late final StreamSubscription<void> _changes;

  HomeState _state = const HomeLoading();
  HomeState get state => _state;

  /// Guards against a second load starting while one is in flight — two taps
  /// on "try again" should not race each other into the notifier.
  bool _inFlight = false;

  Future<void> load() => _fetch(keepCurrent: false);

  /// Re-fetches without tearing down what is on screen.
  Future<void> refresh() => _fetch(keepCurrent: true);

  Future<void> _fetch({required bool keepCurrent}) async {
    if (_inFlight) return;
    _inFlight = true;

    final HomeState previous = _state;
    if (keepCurrent && previous is HomeReady) {
      _set(HomeReady(previous.snapshot, isRefreshing: true));
    } else {
      _set(const HomeLoading());
    }

    try {
      _set(HomeReady(await _repository.fetchHome()));
    } catch (error) {
      // A failed refresh keeps the data it already had; only a cold load has
      // nothing better to show than the error.
      if (keepCurrent && previous is HomeReady) {
        _set(HomeReady(previous.snapshot));
      } else {
        _set(HomeFailure(error));
      }
    } finally {
      _inFlight = false;
    }
  }

  void _set(HomeState next) {
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_changes.cancel());
    super.dispose();
  }
}

/// Puts the controller in the tree.
///
/// An [InheritedNotifier] rather than a global: two Homes (a preview, a test,
/// a future family-mode account switcher) can exist at once without sharing
/// state, and every widget below rebuilds from the same notification.
class HomeScope extends InheritedNotifier<HomeController> {
  const HomeScope({
    required HomeController super.notifier,
    required super.child,
    super.key,
  });

  static HomeController of(BuildContext context) {
    final HomeScope? scope =
        context.dependOnInheritedWidgetOfExactType<HomeScope>();
    assert(scope != null, 'No HomeScope above this widget');
    return scope!.notifier!;
  }
}
