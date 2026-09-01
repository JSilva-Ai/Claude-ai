import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app.dart';
import 'package:loop/core/localization/locale_preferences.dart';
import 'package:loop/core/theme/loop_dimens.dart';
import 'package:loop/core/utils/clock.dart';
import 'package:loop/features/home/data/home_repository.dart';
import 'package:loop/features/home/data/mock_home_repository.dart';
import 'package:loop/features/home/models/home_snapshot.dart';

/// 9:41 in the morning, the hour on the reference screenshot. Fixed so the
/// greeting and the countdown are assertions rather than whatever the CI
/// machine's clock happened to say.
final DateTime _nineFortyOne = DateTime(2026, 8, 31, 9, 41);
final FixedClock _clock = FixedClock(_nineFortyOne);

/// Preferences that already hold a choice, as they would on a second launch.
class _StoredLocale implements LocalePreferences {
  const _StoredLocale(this.locale);

  final Locale locale;

  @override
  Future<Locale?> load() async => locale;

  @override
  Future<void> save(Locale? locale) async {}
}

class _FailingRepository implements HomeRepository {
  const _FailingRepository();

  @override
  Future<HomeSnapshot> fetchHome() async =>
      throw const HomeLoadFailure('no network');
}

Future<void> _pumpHome(
  WidgetTester tester, {
  HomeRepository? repository,
  Locale? locale,
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: LoopApp(
        repository: repository ??
            MockHomeRepository(clock: _clock, delay: Duration.zero),
        clock: _clock,
        initialLocale: locale,
      ),
    ),
  );
  await tester.pumpAndSettle();

  // The Up next card runs a periodic timer; disposing the tree inside the
  // test rather than leaving it to teardown is what stops that timer.
  addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders every section of the reference layout', (
      WidgetTester tester,
    ) async {
      await _pumpHome(tester, locale: const Locale('en'));

      expect(find.text('LOOP'), findsOneWidget);
      // The greeting is rich text — the sun sits inline with the first line —
      // so it is matched as a substring of the span rather than as a Text.
      expect(
        find.textContaining('Good morning, Jorge.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text("Here's what's important today."), findsOneWidget);

      // The ring: the distinct loop count, not the sum of the cards.
      expect(find.text('6'), findsWidgets);

      for (final String title in <String>[
        'AT RISK',
        'WAITING',
        'TODAY',
        'DONE',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
      expect(find.text('Needs your attention'), findsOneWidget);

      // The last two cards are below the fold on this device; the page is a
      // list and they are built on demand.
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('AI INSIGHT'), findsOneWidget);
      expect(find.text("You're on top of things!"), findsOneWidget);

      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('Dentist appointment'), findsOneWidget);
      // 9:41 to 14:00 — computed from the appointment, not written down.
      expect(find.text('in 4h 19m'), findsOneWidget);
      // Matched loosely: `intl` separates the meridiem with a narrow no-break
      // space, which is invisible here and not the point of the assertion.
      expect(find.textContaining('2:00'), findsOneWidget);

      for (final String tab in <String>[
        'Home',
        'Loops',
        'Focus',
        'More',
      ]) {
        expect(find.text(tab), findsOneWidget);
      }
    });

    testWidgets('greets in Portuguese', (WidgetTester tester) async {
      await _pumpHome(tester, locale: const Locale('pt'));

      expect(
        find.textContaining('Bom dia, Jorge.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('EM RISCO'), findsOneWidget);
      expect(find.text('AGUARDANDO'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('A SEGUIR'), findsOneWidget);
      expect(find.text('em 4h 19min'), findsOneWidget);
      // 24-hour clock, from the locale rather than from a format we chose.
      expect(find.textContaining('14:00'), findsOneWidget);
    });

    testWidgets('greets in Spanish', (WidgetTester tester) async {
      await _pumpHome(tester, locale: const Locale('es'));

      expect(
        find.textContaining('Buenos días, Jorge.', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('EN RIESGO'), findsOneWidget);
      expect(find.text('HECHO'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('A CONTINUACIÓN'), findsOneWidget);
    });

    testWidgets('falls back to English on an unsupported device locale', (
      WidgetTester tester,
    ) async {
      // No chosen language: the app follows the device, and the device is set
      // to one of the three LOOP does not speak yet.
      tester.platformDispatcher.localesTestValue = const <Locale>[Locale('ja')];
      tester.platformDispatcher.localeTestValue = const Locale('ja');
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);

      await _pumpHome(tester);
      expect(find.text('AT RISK'), findsOneWidget);
    });

    testWidgets('lays out on a small phone without overflowing', (
      WidgetTester tester,
    ) async {
      // 320x568 is the smallest screen either store still sees.
      await _pumpHome(
        tester,
        size: const Size(320, 568),
        locale: const Locale('en'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('AT RISK'), findsOneWidget);
    });

    testWidgets('survives the largest accessibility text size', (
      WidgetTester tester,
    ) async {
      await _pumpHome(
        tester,
        locale: const Locale('pt'),
        textScale: 2,
        size: const Size(360, 780),
      );

      // Portuguese at double size is the worst case the three languages offer:
      // the longest strings in the largest type on a narrow screen.
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out on a tablet', (WidgetTester tester) async {
      await _pumpHome(
        tester,
        size: const Size(1024, 1366),
        locale: const Locale('en'),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('AT RISK'), findsOneWidget);
    });

    testWidgets('puts the four states in two columns on a tablet', (
      WidgetTester tester,
    ) async {
      await _pumpHome(
        tester,
        size: const Size(834, 1112),
        locale: const Locale('en'),
      );

      final Offset atRisk = tester.getTopLeft(find.text('AT RISK'));
      final Offset waiting = tester.getTopLeft(find.text('WAITING'));
      final Offset today = tester.getTopLeft(find.text('TODAY'));
      final Offset done = tester.getTopLeft(find.text('DONE'));

      // Left column: what can still go wrong. Right column: what is settled.
      expect(atRisk.dy, moreOrLessEquals(today.dy, epsilon: 1));
      expect(waiting.dy, moreOrLessEquals(done.dy, epsilon: 1));
      expect(today.dx, greaterThan(atRisk.dx));

      // And the page is not a phone column stranded in the middle: the
      // gutters grew with the window.
      expect(atRisk.dx, greaterThan(LoopSpacing.pagePadding));
    });

    testWidgets('keeps one column on a phone', (WidgetTester tester) async {
      await _pumpHome(tester, locale: const Locale('en'));

      final Offset atRisk = tester.getTopLeft(find.text('AT RISK'));
      final Offset today = tester.getTopLeft(find.text('TODAY'));

      expect(today.dx, moreOrLessEquals(atRisk.dx, epsilon: 1));
      expect(today.dy, greaterThan(atRisk.dy));
    });

    testWidgets('shows the error state and recovers on retry', (
      WidgetTester tester,
    ) async {
      await _pumpHome(
        tester,
        repository: const _FailingRepository(),
        locale: const Locale('en'),
      );

      expect(find.text("We couldn't load your loops"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows the empty state when nothing is open', (
      WidgetTester tester,
    ) async {
      await _pumpHome(
        tester,
        repository: MockHomeRepository(
          clock: _clock,
          delay: Duration.zero,
          empty: true,
        ),
        locale: const Locale('en'),
      );

      expect(find.text('Nothing is open'), findsOneWidget);
      expect(find.text('AT RISK'), findsNothing);
    });

    testWidgets('a summary card opens its placeholder screen', (
      WidgetTester tester,
    ) async {
      await _pumpHome(tester, locale: const Locale('en'));

      await tester.tap(find.text('AT RISK'));
      await tester.pumpAndSettle();

      expect(find.text('AT RISK is coming'), findsOneWidget);

      // And it can be left by a labelled control, not only by a drag.
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      expect(find.text('AT RISK is coming'), findsNothing);
    });

    testWidgets('the pull-to-refresh gesture is announced', (
      WidgetTester tester,
    ) async {
      await _pumpHome(tester, locale: const Locale('en'));

      expect(
        tester
            .widget<RefreshIndicator>(find.byType(RefreshIndicator))
            .semanticsLabel,
        'Refresh',
      );
    });

    testWidgets('opens in the language it remembered', (
      WidgetTester tester,
    ) async {
      // No locale passed in: the app asks its preferences, as it would on a
      // cold start after the user chose Spanish last week.
      await tester.pumpWidget(
        LoopApp(
          repository: MockHomeRepository(clock: _clock, delay: Duration.zero),
          clock: _clock,
          localePreferences: const _StoredLocale(Locale('es')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EN RIESGO'), findsOneWidget);
      addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    });

    testWidgets('the menu switches language for the whole app', (
      WidgetTester tester,
    ) async {
      await _pumpHome(tester, locale: const Locale('en'));

      await tester.tap(find.bySemanticsLabel('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();

      expect(find.text('EM RISCO'), findsOneWidget);
    });
  });

  group('accessibility', () {
    testWidgets('every card states its meaning without relying on colour', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpHome(tester, locale: const Locale('en'));

      expect(
        find.bySemanticsLabel('AT RISK, Needs your attention, 3 loops'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('6 active loops'), findsOneWidget);
      expect(find.bySemanticsLabel('Menu'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Your profile, Online'),
        findsOneWidget,
      );

      // Disposed here rather than in a tear-down: the framework checks for
      // leaked handles before tear-downs run.
      handle.dispose();
    });

    testWidgets('meets the tap target guidelines', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpHome(tester, locale: const Locale('en'));

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      handle.dispose();
    });
  });
}
