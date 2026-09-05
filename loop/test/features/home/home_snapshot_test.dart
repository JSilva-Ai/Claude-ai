import 'package:flutter_test/flutter_test.dart';
import 'package:loop/features/home/models/home_snapshot.dart';
import 'package:loop/core/models/loop_category.dart';
import 'package:loop/features/home/models/user_profile.dart';

void main() {
  HomeSnapshot snapshotOf(
    Map<LoopCategory, int> counts, {
    int? activeLoops,
  }) =>
      HomeSnapshot(
        profile: const UserProfile(id: 'u', displayName: 'Jorge Silva'),
        summaries: counts,
        activeLoops: activeLoops,
      );

  group('HomeSnapshot', () {
    test('the ring reports the distinct loop count it was given', () {
      // The reference design's own numbers: the categories overlap, so six
      // active loops sit above cards reading 3, 2 and 4.
      final HomeSnapshot snapshot = snapshotOf(
        const <LoopCategory, int>{
          LoopCategory.atRisk: 3,
          LoopCategory.waiting: 2,
          LoopCategory.today: 4,
          LoopCategory.done: 6,
        },
        activeLoops: 6,
      );

      expect(snapshot.activeLoops, 6);
      expect(snapshot.openCount, 9);
      expect(snapshot.closedCount, 6);
      expect(snapshot.openRatio, closeTo(0.5, 1e-9));
    });

    test('falls back to summing the open cards when nothing better is known',
        () {
      final HomeSnapshot snapshot = snapshotOf(const <LoopCategory, int>{
        LoopCategory.atRisk: 3,
        LoopCategory.waiting: 2,
        LoopCategory.today: 4,
      });
      expect(snapshot.activeLoops, 9);
    });

    test('a missing category reads as zero rather than throwing', () {
      final HomeSnapshot snapshot = snapshotOf(const <LoopCategory, int>{
        LoopCategory.done: 2,
      });
      expect(snapshot.countOf(LoopCategory.atRisk), 0);
      expect(snapshot.activeLoops, 0);
    });

    test('an empty day does not divide by zero', () {
      final HomeSnapshot snapshot = snapshotOf(const <LoopCategory, int>{});
      expect(snapshot.openRatio, 0);
      expect(snapshot.isEmpty, isTrue);
    });
  });

  group('UserProfile', () {
    test('greets by first name', () {
      const UserProfile profile = UserProfile(
        id: 'u',
        displayName: '  Jorge Silva ',
      );
      expect(profile.firstName, 'Jorge');
      expect(profile.initial, 'J');
    });

    test('the anonymous profile renders rather than crashing', () {
      expect(UserProfile.anonymous.firstName, '');
      expect(UserProfile.anonymous.initial, '?');
    });
  });
}
