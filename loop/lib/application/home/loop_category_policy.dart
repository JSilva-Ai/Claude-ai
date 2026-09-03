import '../../core/models/loop_category.dart';
import '../../domain/intelligence/loop_signals.dart';
import '../../domain/intelligence/risk_assessment.dart';
import '../../domain/loop/loop.dart';
import '../../domain/loop/loop_state.dart';

/// Which Home cards a loop belongs to, right now — not what it *is*.
///
/// The constitutional distinctions this exists to keep: `LoopCategory` is a
/// presentation bucket, never written back onto the aggregate, and the three
/// axes that feed it stay separate the whole way through —
/// [LoopState] answers "where is this in its lifecycle", [RiskAssessment]
/// answers "how likely is this to go wrong", and *this* function answers
/// "does today's Home want to show it, and where". A `waiting` loop can
/// still land in [LoopCategory.atRisk]; a loop due [LoopCategory.today] can
/// be risky too — the reference design shows the same overlap
/// (`HomeSnapshot`'s own doc: three at risk, two waiting, four today, six
/// active loops in total), which is why this returns a [Set], not one
/// category picked among the others.
///
/// Deterministic and presentation-independent: no widget, no string, no
/// locale — just the categories a caller elsewhere resolves into cards.
Set<LoopCategory> categoriesFor({
  required Loop loop,
  required RiskAssessment risk,
  required LoopSignals signals,
  required DateTime now,
}) {
  if (loop.state.isTerminal) {
    // Only a loop the person actually closed reads as DONE. One that was
    // abandoned was given up on, not completed — the product has no card
    // for that today, and folding it into DONE would call a decision that
    // never happened a success. It still exists, just outside every bucket
    // this summary draws; a future Loops screen is where "abandoned" gets
    // its own place, not this projection.
    return loop.state == LoopState.resolved
        ? const <LoopCategory>{LoopCategory.done}
        : const <LoopCategory>{};
  }

  final Set<LoopCategory> categories = <LoopCategory>{};

  if (risk.band == RiskBand.high || risk.band == RiskBand.critical) {
    categories.add(LoopCategory.atRisk);
  }

  if (loop.state == LoopState.waiting) {
    categories.add(LoopCategory.waiting);
  }

  final DateTime? deadline = signals.deadline;
  if (deadline != null && _isSameLocalDay(deadline, now)) {
    categories.add(LoopCategory.today);
  }

  return categories;
}

/// Local-calendar "today", not a 24-hour window: a deadline at 8am read at
/// 5pm the same day is still today, even though it is already
/// [LoopSignals.isOverdue]. Normalises both sides to local time first, so
/// the comparison is correct regardless of which zone either [DateTime] was
/// constructed in — see `data/local/mapping/persisted_time.dart`, which
/// always hands back UTC.
bool _isSameLocalDay(DateTime a, DateTime b) {
  final DateTime la = a.toLocal();
  final DateTime lb = b.toLocal();
  return la.year == lb.year && la.month == lb.month && la.day == lb.day;
}
