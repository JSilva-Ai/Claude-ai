import '../../../core/utils/clock.dart';
import '../models/ai_insight.dart';
import '../models/home_snapshot.dart';
import '../models/loop_category.dart';
import '../models/upcoming_item.dart';
import '../models/user_profile.dart';
import 'home_repository.dart';

/// Demonstration data.
///
/// It lives behind the same interface the real aggregator will implement, and
/// it is the only file in the feature that knows a name like "Jorge". The
/// delay is not decoration: without it the loading state would never be seen,
/// and a state nobody ever renders is a state nobody notices is broken.
class MockHomeRepository implements HomeRepository {
  const MockHomeRepository({
    this.clock = const Clock(),
    this.delay = const Duration(milliseconds: 650),
    this.failure = false,
    this.empty = false,
  });

  final Clock clock;
  final Duration delay;

  /// Set by the debug menu to exercise the error and empty states on a device.
  final bool failure;
  final bool empty;

  @override
  Future<HomeSnapshot> fetchHome() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (failure) {
      throw const HomeLoadFailure('mock repository asked to fail');
    }

    const UserProfile profile = UserProfile(
      id: 'demo-user',
      displayName: 'Jorge Silva',
      isOnline: true,
    );

    if (empty) {
      return const HomeSnapshot(
        profile: profile,
        summaries: <LoopCategory, int>{},
      );
    }

    final DateTime now = clock.now();

    // 2pm today, or 2pm tomorrow once today's has passed, so the demo never
    // shows an appointment that already happened.
    DateTime appointment = DateTime(now.year, now.month, now.day, 14);
    if (!appointment.isAfter(now)) {
      appointment = appointment.add(const Duration(days: 1));
    }

    return HomeSnapshot(
      profile: profile,
      // Six distinct loops across nine card entries: two of them are both at
      // risk and planned for today, which is exactly the overlap the ring's
      // explicit count exists for.
      activeLoops: 6,
      summaries: const <LoopCategory, int>{
        LoopCategory.atRisk: 3,
        LoopCategory.waiting: 2,
        LoopCategory.today: 4,
        LoopCategory.done: 6,
      },
      insight: AIInsight(
        id: 'insight-demo',
        headline: "You're on top of things!",
        detail: '3 loops closed yesterday.',
        tone: InsightTone.positive,
        generatedAt: now,
      ),
      upNext: UpcomingItem(
        id: 'appointment-demo',
        title: 'Dentist appointment',
        scheduledAt: appointment,
        isOnCalendar: false,
      ),
    );
  }
}
