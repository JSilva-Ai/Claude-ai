import 'package:flutter/foundation.dart';

/// The next thing on the clock.
///
/// It holds a [DateTime], never a formatted string. "in 4h 18m" is a fact about
/// the moment it is read, so the only correct place to compute it is at render
/// time — see `countdown.dart`.
@immutable
class UpcomingItem {
  const UpcomingItem({
    required this.id,
    required this.title,
    required this.scheduledAt,
    this.isOnCalendar = false,
  });

  final String id;
  final String title;
  final DateTime scheduledAt;

  /// False where LOOP inferred the commitment from a message rather than
  /// reading it from a calendar — which is what the "add to calendar" action
  /// on the card is for.
  final bool isOnCalendar;

  Duration timeUntil(DateTime now) => scheduledAt.difference(now);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpcomingItem &&
          other.id == id &&
          other.title == title &&
          other.scheduledAt == scheduledAt &&
          other.isOnCalendar == isOnCalendar;

  @override
  int get hashCode => Object.hash(id, title, scheduledAt, isOnCalendar);
}
