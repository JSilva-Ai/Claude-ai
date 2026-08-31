import 'package:flutter/foundation.dart';

import '../models/home_snapshot.dart';

/// The Home is always in exactly one of three states.
///
/// Sealed, so adding a fourth (offline, say) makes every `switch` over it a
/// compile error until it has been handled. A nullable snapshot beside a
/// nullable error would have let the same fourth state ship as a blank screen.
@immutable
sealed class HomeState {
  const HomeState();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeReady extends HomeState {
  const HomeReady(this.snapshot, {this.isRefreshing = false});

  final HomeSnapshot snapshot;

  /// A refresh over data already on screen. Kept distinct from [HomeLoading]
  /// so pulling to refresh does not blank out the page the user is reading.
  final bool isRefreshing;
}

class HomeFailure extends HomeState {
  const HomeFailure(this.error);

  final Object error;
}
