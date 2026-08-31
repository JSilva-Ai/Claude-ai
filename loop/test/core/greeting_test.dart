import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/utils/greeting.dart';

void main() {
  group('dayPartFor', () {
    test('splits the day at noon and at six', () {
      DayPart at(int hour, [int minute = 0]) =>
          dayPartFor(DateTime(2026, 8, 31, hour, minute));

      expect(at(0), DayPart.morning);
      expect(at(11, 59), DayPart.morning);
      expect(at(12), DayPart.afternoon);
      expect(at(17, 59), DayPart.afternoon);
      expect(at(18), DayPart.evening);
      expect(at(23, 59), DayPart.evening);
    });
  });
}
