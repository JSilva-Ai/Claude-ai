import 'package:flutter_test/flutter_test.dart';
import 'package:loop/data/local/mapping/persisted_time.dart';

void main() {
  group('persisted time', () {
    test('a UTC moment round-trips exactly', () {
      final DateTime original = DateTime.utc(2026, 9, 1, 9, 41, 30, 250);
      final int stored = toPersistedMillis(original);
      final DateTime restored = fromPersistedMillis(stored);
      expect(restored, original);
      expect(restored.isUtc, isTrue);
    });

    test('a local (non-UTC) moment round-trips to the same instant', () {
      // The point of storing UTC explicitly: whatever timezone the device is
      // in when a value is written, reading it back must be the same moment,
      // not a value that has silently drifted by the writer's UTC offset.
      // [fromPersistedMillis] always returns a UTC-flagged DateTime by
      // contract (see its doc), so a local original is only ever compared by
      // instant here, not by `==` — Dart's own DateTime equality is not
      // guaranteed to ignore the isUtc flag.
      final DateTime local = DateTime(2026, 3, 15, 8, 0);
      final int stored = toPersistedMillis(local);
      final DateTime restored = fromPersistedMillis(stored);
      expect(restored.isAtSameMomentAs(local), isTrue);
      expect(restored.isUtc, isTrue);
    });

    test(
        'two DateTimes for the same instant, one local one UTC, persist '
        'identically', () {
      final DateTime asUtc = DateTime.utc(2026, 6, 1, 12, 0);
      final DateTime asLocal = asUtc.toLocal();
      expect(toPersistedMillis(asUtc), toPersistedMillis(asLocal));
    });

    test('millisecond precision survives, no truncation to seconds', () {
      final DateTime withMillis = DateTime.utc(2026, 1, 1, 0, 0, 0, 123);
      expect(fromPersistedMillis(toPersistedMillis(withMillis)), withMillis);
    });
  });
}
