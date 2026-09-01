import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/localization/l10n/app_localizations.dart';
import 'package:loop/core/models/loop_category.dart';
import 'package:loop/core/theme/loop_dimens.dart';
import 'package:loop/core/theme/loop_theme.dart';
import 'package:loop/core/widgets/loop_icon_button.dart';
import 'package:loop/core/widgets/primary_button.dart';
import 'package:loop/core/widgets/status_badge.dart';

/// The components need the theme extension and the localizations, and nothing
/// else — which is itself worth asserting: a design-system widget that needed a
/// screen around it would not be reusable.
Widget host(Widget child, {double width = 400}) => MaterialApp(
      theme: LoopTheme.dark,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body:
            Center(child: SizedBox(width: width, child: Center(child: child))),
      ),
    );

/// True when anything inside [of] is drawn at less than full opacity — how a
/// disabled control says so without a screenshot.
bool dimmed(WidgetTester tester, Finder of) => tester
    .widgetList<AnimatedOpacity>(
      find.descendant(of: of, matching: find.byType(AnimatedOpacity)),
    )
    .any((AnimatedOpacity o) => o.opacity < 1);

void main() {
  group('PrimaryButton', () {
    testWidgets('presses', (WidgetTester tester) async {
      int taps = 0;
      await tester.pumpWidget(
        host(PrimaryButton(label: 'Try again', onPressed: () => taps++)),
      );

      await tester.tap(find.text('Try again'));
      expect(taps, 1);
    });

    testWidgets('a null callback disables it', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(const PrimaryButton(label: 'Try again', onPressed: null)),
      );

      await tester.tap(find.text('Try again'));
      await tester.pump();

      // Nothing to assert but the absence of a crash and the dimming — which
      // is the point: a disabled control must look disabled, not just behave
      // that way.
      expect(dimmed(tester, find.byType(PrimaryButton)), isTrue);
    });

    testWidgets('loading refuses taps and holds its width', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(PrimaryButton(label: 'Try again', onPressed: () => taps++)),
      );
      final double idle = tester.getSize(find.byType(PrimaryButton)).width;

      await tester.pumpWidget(
        host(
          PrimaryButton(
            label: 'Try again',
            isLoading: true,
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.tap(find.byType(PrimaryButton));

      expect(taps, 0);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // A control that shrinks to a spinner moves the layout under the finger
      // that just pressed it.
      expect(tester.getSize(find.byType(PrimaryButton)).width, idle);
    });

    testWidgets('clears the minimum touch target', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(PrimaryButton(label: 'Ok', onPressed: () {})),
      );
      expect(
        tester.getSize(find.byType(PrimaryButton)).height,
        greaterThanOrEqualTo(LoopSizes.minTouchTarget),
      );
    });
  });

  group('LoopIconButton', () {
    testWidgets('is never wider than the button', (
      WidgetTester tester,
    ) async {
      // The defect this guards: a Center inside a minimum-size box takes every
      // pixel its parent offers, and the header's menu became a hit area
      // spanning the whole row — a tap on it opened the profile.
      await tester.pumpWidget(
        host(
          LoopIconButton(
            icon: Icons.menu_rounded,
            semanticLabel: 'Menu',
            onPressed: () {},
          ),
          width: 900,
        ),
      );

      final Size size = tester.getSize(find.byType(LoopIconButton));
      expect(size.width, LoopSizes.minTouchTarget);
      expect(size.height, LoopSizes.minTouchTarget);
    });

    testWidgets('answers to its label and presses', (
      WidgetTester tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(
        host(
          LoopIconButton(
            icon: Icons.calendar_month_rounded,
            semanticLabel: 'Add to calendar',
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Add to calendar'));
      expect(taps, 1);
    });

    testWidgets('a null callback disables it', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const LoopIconButton(
            icon: Icons.menu_rounded,
            semanticLabel: 'Menu',
            onPressed: null,
          ),
        ),
      );

      expect(dimmed(tester, find.byType(LoopIconButton)), isTrue);
    });
  });

  group('StatusBadge', () {
    testWidgets('every state carries a word and a glyph, not just a colour', (
      WidgetTester tester,
    ) async {
      const Map<LoopCategory, String> expected = <LoopCategory, String>{
        LoopCategory.atRisk: 'AT RISK',
        LoopCategory.waiting: 'WAITING',
        LoopCategory.today: 'TODAY',
        LoopCategory.done: 'DONE',
      };

      for (final MapEntry<LoopCategory, String> entry in expected.entries) {
        await tester.pumpWidget(host(StatusBadge(category: entry.key)));

        expect(find.text(entry.value), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(StatusBadge),
            matching: find.byType(Icon),
          ),
          findsOneWidget,
          reason: '${entry.key.name} must not rely on colour alone',
        );
      }
    });

    testWidgets('the icon form still announces the state', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const StatusBadge(
            category: LoopCategory.atRisk,
            variant: StatusBadgeVariant.icon,
          ),
        ),
      );

      // No text on screen in this variant — the label is all a screen reader
      // has to go on.
      expect(find.text('AT RISK'), findsNothing);
      expect(find.bySemanticsLabel('AT RISK'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('speaks the language it is built in', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LoopTheme.dark,
          locale: const Locale('pt'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Center(child: StatusBadge(category: LoopCategory.waiting)),
          ),
        ),
      );

      expect(find.text('AGUARDANDO'), findsOneWidget);
    });
  });
}
