import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/utils/countdown.dart';

void main() {
  final DateTime now = DateTime(2026, 8, 31, 9, 42);

  Countdown after(Duration d) => Countdown.between(now, now.add(d));

  group('Countdown', () {
    test('the reference case: 4h 18m out', () {
      final Countdown c = after(const Duration(hours: 4, minutes: 18));
      expect(c.unit, CountdownUnit.hoursMinutes);
      expect(c.major, 4);
      expect(c.minor, 18);
    });

    test('under an hour drops to minutes', () {
      final Countdown c = after(const Duration(minutes: 45));
      expect(c.unit, CountdownUnit.minutes);
      expect(c.major, 45);
    });

    test('over a day is days and hours', () {
      final Countdown c = after(const Duration(days: 2, hours: 3));
      expect(c.unit, CountdownUnit.daysHours);
      expect(c.major, 2);
      expect(c.minor, 3);
    });

    test('under a minute is "now", not a count of seconds', () {
      expect(after(const Duration(seconds: 20)).unit, CountdownUnit.now);
    });

    test('the past is overdue, never a negative countdown', () {
      expect(after(const Duration(hours: -3)).unit, CountdownUnit.overdue);
    });

    test('refreshes once a minute below a day, rarely above it', () {
      expect(
        after(const Duration(hours: 4)).refreshInterval,
        const Duration(minutes: 1),
      );
      expect(
        after(const Duration(days: 3)).refreshInterval,
        const Duration(minutes: 15),
      );
    });
  });

  group('relativeDayFor', () {
    test('compares calendar days, not elapsed hours', () {
      final DateTime lateNight = DateTime(2026, 8, 31, 23, 30);
      final DateTime justAfterMidnight = DateTime(2026, 9, 1, 0, 30);

      // Two hours apart, and still a different day.
      expect(
        relativeDayFor(lateNight, justAfterMidnight),
        RelativeDay.tomorrow,
      );
      expect(
        relativeDayFor(lateNight, DateTime(2026, 8, 31, 23, 59)),
        RelativeDay.today,
      );
      expect(
        relativeDayFor(lateNight, DateTime(2026, 9, 5)),
        RelativeDay.other,
      );
    });
  });
}
