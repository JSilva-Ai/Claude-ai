import 'package:flutter/foundation.dart';

// These live in core rather than under features/home because they describe
// what a loop *is*, not what the Home *shows*: the design system's StatusBadge
// draws them, and the Loops screen will read them. What stayed behind in
// features/home/models is the material of one screen — the snapshot, the
// insight, the next appointment.

/// The four states a loop can be in, in the order the Home shows them.
///
/// Ordered by consequence, not by count: what can still go wrong comes before
/// what has already gone right. That order is the product's opinion about what
/// matters, so it belongs to the model and not to whichever widget happens to
/// build the list.
enum LoopCategory {
  atRisk,
  waiting,
  today,
  done;

  /// True where the category represents work still open. Kept here so that a
  /// future screen counting "open loops" cannot disagree with this one.
  bool get isOpen => this != LoopCategory.done;
}

/// A category with its current count.
///
/// The strings are deliberately absent: a model that carried "AT RISK" could
/// only ever be English. The presentation layer resolves the label from the
/// category through the localizations.
@immutable
class LoopSummary {
  const LoopSummary({required this.category, required this.count})
      : assert(count >= 0, 'A loop count cannot be negative');

  final LoopCategory category;
  final int count;

  LoopSummary copyWith({LoopCategory? category, int? count}) => LoopSummary(
        category: category ?? this.category,
        count: count ?? this.count,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoopSummary &&
          other.category == category &&
          other.count == count;

  @override
  int get hashCode => Object.hash(category, count);

  @override
  String toString() => 'LoopSummary(${category.name}, $count)';
}
