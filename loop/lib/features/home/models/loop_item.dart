import 'package:flutter/foundation.dart';

import 'loop_category.dart';

/// Where LOOP learned about a loop.
///
/// Recorded on the item rather than inferred later, because the answer to
/// "why does the app think I owe someone a document" has to be traceable to
/// something the user can recognise — and because a commitment the user typed
/// in themselves may never be silently overwritten by one a mailbox produced.
enum LoopSource { manual, email, calendar, message, document }

/// A single open loop: one thing that was started and is not finished.
///
/// The Home does not render these — it renders [LoopSummary] counts, which is
/// all four cards need. This type exists now because everything the product
/// is eventually about is an attribute of *this* object and not of a count:
/// who is waiting on whom ([counterparty]), when it stops being recoverable
/// ([dueAt]), how long it has been silent ([lastActivityAt]), and what the
/// one next move is ([nextAction]). Defining it late would mean discovering
/// late that the summary was the wrong shape to build on.
///
/// It is deliberately inert: no behaviour beyond what can be derived from its
/// own fields, no repository, no engine. The risk and next-action engines will
/// read it and produce new copies; they are not being written now.
@immutable
class LoopItem {
  const LoopItem({
    required this.id,
    required this.title,
    required this.category,
    required this.createdAt,
    this.detail,
    this.counterparty,
    this.dueAt,
    this.lastActivityAt,
    this.nextAction,
    this.source = LoopSource.manual,
  });

  final String id;

  /// What the user would call it. "Send the signed lease to Marina."
  final String title;

  /// The sentence under it, where there is one — the fragment of context that
  /// makes the title make sense a week later.
  final String? detail;

  final LoopCategory category;

  /// The other person, when the loop has one. This is the edge of the
  /// commitment graph: `user → promised → thing → counterparty`.
  final String? counterparty;

  /// When it stops being recoverable. Null where nothing external imposes a
  /// date — plenty of loops have no deadline and are still loops.
  final DateTime? dueAt;

  final DateTime createdAt;

  /// The last time anything happened on it. The input the future risk engine
  /// needs most: a loop that is waiting and silent is the one that fails.
  final DateTime? lastActivityAt;

  /// The single next move, phrased as an action. Null until something can
  /// propose one; the UI must never invent one.
  final String? nextAction;

  final LoopSource source;

  bool get isClosed => category == LoopCategory.done;

  /// Past its date and still open.
  bool isOverdue(DateTime now) {
    final DateTime? dueAt = this.dueAt;
    return dueAt != null && !isClosed && now.isAfter(dueAt);
  }

  /// How long it has been silent. Falls back to age when nothing has ever
  /// happened on it, which is the honest reading: it has been silent since it
  /// was created.
  Duration silenceAt(DateTime now) =>
      now.difference(lastActivityAt ?? createdAt);

  LoopItem copyWith({
    String? id,
    String? title,
    String? detail,
    LoopCategory? category,
    String? counterparty,
    DateTime? dueAt,
    DateTime? createdAt,
    DateTime? lastActivityAt,
    String? nextAction,
    LoopSource? source,
  }) {
    return LoopItem(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      category: category ?? this.category,
      counterparty: counterparty ?? this.counterparty,
      dueAt: dueAt ?? this.dueAt,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      nextAction: nextAction ?? this.nextAction,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoopItem &&
          other.id == id &&
          other.title == title &&
          other.detail == detail &&
          other.category == category &&
          other.counterparty == counterparty &&
          other.dueAt == dueAt &&
          other.createdAt == createdAt &&
          other.lastActivityAt == lastActivityAt &&
          other.nextAction == nextAction &&
          other.source == source;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        detail,
        category,
        counterparty,
        dueAt,
        createdAt,
        lastActivityAt,
        nextAction,
        source,
      );

  @override
  String toString() => 'LoopItem($id, ${category.name}, $title)';
}

/// Counts a list of loops into the shape the Home draws.
///
/// Here rather than in the widget layer so that the day the repository starts
/// returning real items, the summary the cards read is derived from them by
/// one function with a test, instead of by whichever screen got there first.
Map<LoopCategory, int> summariseLoops(Iterable<LoopItem> items) {
  final Map<LoopCategory, int> counts = <LoopCategory, int>{
    for (final LoopCategory category in LoopCategory.values) category: 0,
  };
  for (final LoopItem item in items) {
    counts[item.category] = counts[item.category]! + 1;
  }
  return counts;
}
