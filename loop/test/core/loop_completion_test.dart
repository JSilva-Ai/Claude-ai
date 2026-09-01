import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/theme/loop_motion.dart';
import 'package:loop/core/widgets/loop_completion.dart';
import 'package:loop/core/widgets/loop_logo.dart';

/// Reads the two numbers the animation is actually made of, off the mark it
/// drives — the ring's fraction and the check's.
({double ring, double check}) marks(WidgetTester tester) {
  final LoopMark mark = tester.widget<LoopMark>(find.byType(LoopMark));
  return (ring: mark.progress, check: mark.completion);
}

Widget wrap(Widget child, {bool reduceMotion = false}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );

void main() {
  group('LoopCompletion', () {
    testWidgets('closes the ring, then strokes the check', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(const LoopCompletion()));

      // Nothing has been drawn on the first frame.
      expect(marks(tester).ring, 0);
      expect(marks(tester).check, 0);

      // A third of the way in: the ring is drawing and the check has not
      // started. The order is the whole point of the sequence.
      await tester.pump();
      await tester.pump(LoopMotion.completion * 0.3);
      final ({double check, double ring}) early = marks(tester);
      expect(early.ring, greaterThan(0));
      expect(early.ring, lessThan(1));
      expect(early.check, 0);

      // Two thirds: the ring has closed and the check is under way.
      await tester.pump(LoopMotion.completion * 0.4);
      final ({double check, double ring}) mid = marks(tester);
      expect(mid.ring, greaterThan(early.ring));
      expect(mid.check, greaterThan(0));

      await tester.pumpAndSettle();
      expect(marks(tester).ring, 1);
      expect(marks(tester).check, 1);
    });

    testWidgets('reports when the loop is closed', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        wrap(LoopCompletion(onCompleted: () => closed++)),
      );
      await tester.pumpAndSettle();

      expect(closed, 1);
    });

    testWidgets('with reduced motion it arrives without travelling', (
      WidgetTester tester,
    ) async {
      int closed = 0;
      await tester.pumpWidget(
        wrap(
          LoopCompletion(onCompleted: () => closed++),
          reduceMotion: true,
        ),
      );
      await tester.pump();

      // One frame, final state — the same picture the animation ends on.
      expect(marks(tester).ring, 1);
      expect(marks(tester).check, 1);
      expect(closed, 1);
    });

    testWidgets('holds at the start when it is not told to play', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(wrap(const LoopCompletion(autoPlay: false)));
      await tester.pump(LoopMotion.completion * 2);

      expect(marks(tester).ring, 0);
      expect(marks(tester).check, 0);
    });

    testWidgets('the footer lands last', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(const LoopCompletion(footer: Text('DONE'))),
      );
      await tester.pump();
      await tester.pump(LoopMotion.completion * 0.5);

      expect(
        tester.widget<Opacity>(find.byType(Opacity)).opacity,
        0,
        reason: 'the footer must not appear before the check',
      );

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      expect(find.text('DONE'), findsOneWidget);
    });
  });
}
