import 'package:flutter/foundation.dart';

/// The source of "now".
///
/// Injected rather than called directly because two things on the Home depend
/// on the wall clock — the greeting and the countdown — and a test that cannot
/// choose the time can only assert that *something* was rendered. With a clock
/// in the constructor, "good evening in São Paulo" is a unit test.
@immutable
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}

/// A clock frozen at a chosen instant, for tests and for screenshots.
@immutable
class FixedClock implements Clock {
  const FixedClock(this._now);

  final DateTime _now;

  @override
  DateTime now() => _now;
}
