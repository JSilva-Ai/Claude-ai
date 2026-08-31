import 'package:flutter/foundation.dart';

import 'ai_insight.dart';
import 'loop_category.dart';
import 'upcoming_item.dart';
import 'user_profile.dart';

/// Everything the Home draws, as one immutable value.
///
/// One object rather than five independent streams, because the screen has to
/// be internally consistent: a ring reading 6 above cards adding to 4 is worse
/// than either number being briefly stale.
@immutable
class HomeSnapshot {
  const HomeSnapshot({
    required this.profile,
    required this.summaries,
    int? activeLoops,
    this.insight,
    this.upNext,
  }) : _activeLoops = activeLoops;

  final UserProfile profile;

  /// Counts per category. Missing entries read as zero, so a backend that only
  /// sends non-empty buckets does not break the layout.
  final Map<LoopCategory, int> summaries;

  /// How many distinct loops are open.
  ///
  /// Explicit rather than summed, because the categories overlap: a loop can
  /// be at risk *and* planned for today, and it is one loop, not two. The
  /// reference design says so out loud — three at risk, two waiting, four
  /// today, and six active — and a Home whose headline number disagreed with
  /// its own cards would be the first thing anyone noticed.
  ///
  /// Left null by a source that cannot tell distinct loops apart yet, in which
  /// case the open categories are summed as the best available answer.
  final int? _activeLoops;

  final AIInsight? insight;
  final UpcomingItem? upNext;

  int countOf(LoopCategory category) => summaries[category] ?? 0;

  int get activeLoops => _activeLoops ?? openCount;

  /// The sum of the open categories — every card except DONE. Not the same
  /// thing as [activeLoops]; see above.
  int get openCount => LoopCategory.values
      .where((LoopCategory c) => c.isOpen)
      .fold(0, (int sum, LoopCategory c) => sum + countOf(c));

  int get closedCount => countOf(LoopCategory.done);

  /// 0..1 for the ring: the share of the day's loops that are still open, so a
  /// good day visibly empties it. Guarded against the empty state, where the
  /// honest answer is an empty ring rather than a division by zero.
  double get openRatio {
    final int total = activeLoops + closedCount;
    return total == 0 ? 0 : activeLoops / total;
  }

  bool get isEmpty => activeLoops == 0 && closedCount == 0 && upNext == null;
}
