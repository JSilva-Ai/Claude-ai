import 'package:flutter/foundation.dart';

/// A duration reduced to the two units worth showing.
///
/// "in 4h 18m" is not a formatted string in the model; it is this, resolved
/// against the localizations at render time. Keeping the arithmetic here and
/// the wording there is what lets Portuguese say "em 4h 18min" without the
/// countdown logic knowing that Portuguese exists.
@immutable
class Countdown {
  const Countdown._(this.unit, {this.major = 0, this.minor = 0});

  factory Countdown.between(DateTime now, DateTime target) {
    final Duration left = target.difference(now);

    // Past is past. A negative countdown rendered as "in -3h" is the kind of
    // detail that makes an app feel unfinished.
    if (left.isNegative) return const Countdown._(CountdownUnit.overdue);

    // Under a minute reads as "now"; nobody needs seconds ticking on a Home.
    if (left.inMinutes < 1) return const Countdown._(CountdownUnit.now);

    if (left.inHours < 1) {
      return Countdown._(CountdownUnit.minutes, major: left.inMinutes);
    }
    if (left.inDays < 1) {
      return Countdown._(
        CountdownUnit.hoursMinutes,
        major: left.inHours,
        minor: left.inMinutes.remainder(60),
      );
    }
    return Countdown._(
      CountdownUnit.daysHours,
      major: left.inDays,
      minor: left.inHours.remainder(24),
    );
  }

  final CountdownUnit unit;
  final int major;
  final int minor;

  /// How long until this rendering becomes wrong.
  ///
  /// The card rebuilds on this interval instead of every second: below a day
  /// the smallest unit shown is a minute, so a per-second timer would wake the
  /// device sixty times to draw the same pixels.
  Duration get refreshInterval => switch (unit) {
        CountdownUnit.overdue ||
        CountdownUnit.now =>
          const Duration(minutes: 1),
        CountdownUnit.minutes ||
        CountdownUnit.hoursMinutes =>
          const Duration(minutes: 1),
        CountdownUnit.daysHours => const Duration(minutes: 15),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Countdown &&
          other.unit == unit &&
          other.major == major &&
          other.minor == minor;

  @override
  int get hashCode => Object.hash(unit, major, minor);

  @override
  String toString() => 'Countdown(${unit.name}, $major, $minor)';
}

enum CountdownUnit { overdue, now, minutes, hoursMinutes, daysHours }

/// Which date wording an item wants: today, tomorrow, or a written date.
enum RelativeDay { today, tomorrow, other }

RelativeDay relativeDayFor(DateTime now, DateTime target) {
  // Compared as calendar dates, not as a 24-hour distance: 11pm and 1am are
  // two hours apart and still "today" and "tomorrow".
  final DateTime a = DateTime(now.year, now.month, now.day);
  final DateTime b = DateTime(target.year, target.month, target.day);
  final int days = b.difference(a).inDays;
  return switch (days) {
    0 => RelativeDay.today,
    1 => RelativeDay.tomorrow,
    _ => RelativeDay.other,
  };
}
