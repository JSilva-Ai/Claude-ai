import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/models/loop_category.dart';
import 'package:loop/core/models/loop_item.dart';

void main() {
  final DateTime now = DateTime(2026, 8, 31, 9, 41);

  LoopItem item({
    String id = 'l1',
    LoopCategory category = LoopCategory.waiting,
    DateTime? dueAt,
    DateTime? lastActivityAt,
  }) =>
      LoopItem(
        id: id,
        title: 'Send the signed lease',
        category: category,
        createdAt: now.subtract(const Duration(days: 6)),
        counterparty: 'Marina',
        dueAt: dueAt,
        lastActivityAt: lastActivityAt,
      );

  group('LoopItem', () {
    test('is overdue only when open and past its date', () {
      expect(
        item(dueAt: now.subtract(const Duration(hours: 1))).isOverdue(now),
        isTrue,
      );
      expect(
        item(dueAt: now.add(const Duration(hours: 1))).isOverdue(now),
        isFalse,
      );
      // A date with no deadline cannot be late.
      expect(item().isOverdue(now), isFalse);
      // Neither can a closed one, however long ago it was due.
      expect(
        item(
          category: LoopCategory.done,
          dueAt: now.subtract(const Duration(days: 30)),
        ).isOverdue(now),
        isFalse,
      );
    });

    test('silence falls back to age when nothing has happened yet', () {
      expect(item().silenceAt(now), const Duration(days: 6));
      expect(
        item(lastActivityAt: now.subtract(const Duration(days: 2)))
            .silenceAt(now),
        const Duration(days: 2),
      );
    });

    test('closed is a property of the category, not a second flag', () {
      expect(item(category: LoopCategory.done).isClosed, isTrue);
      expect(item(category: LoopCategory.atRisk).isClosed, isFalse);
    });

    test('copyWith and equality behave as a value type', () {
      final LoopItem a = item();
      expect(a, equals(item()));
      expect(a.hashCode, equals(item().hashCode));
      expect(a.copyWith(category: LoopCategory.done).isClosed, isTrue);
      expect(a.copyWith(category: LoopCategory.done), isNot(equals(a)));
    });
  });

  group('summariseLoops', () {
    test('counts into the shape the Home cards read', () {
      final List<LoopItem> loops = <LoopItem>[
        item(id: '1', category: LoopCategory.atRisk),
        item(id: '2', category: LoopCategory.atRisk),
        item(id: '3', category: LoopCategory.waiting),
        item(id: '4', category: LoopCategory.done),
      ];

      final Map<LoopCategory, int> counts = summariseLoops(loops);

      expect(counts[LoopCategory.atRisk], 2);
      expect(counts[LoopCategory.waiting], 1);
      expect(counts[LoopCategory.done], 1);
      // Present and zero, not missing — the card still has to draw.
      expect(counts[LoopCategory.today], 0);
    });

    test('an empty day counts every category as zero', () {
      final Map<LoopCategory, int> counts = summariseLoops(<LoopItem>[]);
      expect(counts.length, LoopCategory.values.length);
      expect(counts.values.every((int c) => c == 0), isTrue);
    });
  });
}
