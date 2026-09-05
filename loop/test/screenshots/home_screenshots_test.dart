@Tags(<String>['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/app.dart';
import 'package:loop/core/utils/clock.dart';
import 'package:loop/features/home/data/mock_home_repository.dart';

/// Renders the Home to PNG files so it can be looked at.
///
/// This is a tool, not a test: it asserts nothing and it is tagged out of the
/// default run. It exists because "does it look right" cannot be answered by
/// `expect`, and because a screenshot of the real widget tree is the only
/// honest way to review a design without a device.
///
///   LOOP_SCREENSHOTS=1 flutter test --update-goldens test/screenshots
///
/// Skipped without that variable: a golden compared against a machine's own
/// font rendering is a test that fails on somebody else's laptop for reasons
/// that have nothing to do with the code.
///
/// Writes into build/screenshots/.
void main() {
  final DateTime nineFortyOne = DateTime(2026, 8, 31, 9, 41);
  final FixedClock clock = FixedClock(nineFortyOne);

  setUpAll(() async {
    // The test framework substitutes a font that draws every glyph as a box.
    // Real type is the entire point here, so Roboto and the icon font are
    // loaded out of the Flutter SDK's own cache.
    final String root = Platform.environment['FLUTTER_ROOT']!;
    Future<void> load(String family, List<String> paths) async {
      final FontLoader loader = FontLoader(family);
      for (final String path in paths) {
        loader.addFont(
          File('$root/bin/cache/artifacts/material_fonts/$path')
              .readAsBytes()
              .then(
                (List<int> bytes) =>
                    ByteData.view(Uint8List.fromList(bytes).buffer),
              ),
        );
      }
      await loader.load();
    }

    await load('Roboto', <String>[
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Light.ttf',
    ]);
    await load('MaterialIcons', <String>['MaterialIcons-Regular.otf']);
  });

  Future<void> shoot(
    WidgetTester tester,
    String name, {
    required Size size,
    required Locale locale,
    bool empty = false,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: LoopApp(
          repository: MockHomeRepository(
            clock: clock,
            delay: Duration.zero,
            empty: empty,
          ),
          clock: clock,
          initialLocale: locale,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Golden paths resolve against this file's directory, so the climb out of
    // test/screenshots/ is what puts the images in the project's build
    // directory rather than committing them next to the code.
    await expectLater(
      find.byType(LoopApp),
      matchesGoldenFile('../../build/screenshots/$name.png'),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  }

  testWidgets('home in three languages and three sizes',
      skip: !Platform.environment.containsKey('LOOP_SCREENSHOTS'),
      (WidgetTester tester) async {
    const Size phone = Size(390, 844);

    await shoot(tester, 'home-en', size: phone, locale: const Locale('en'));
    await shoot(tester, 'home-pt', size: phone, locale: const Locale('pt'));
    await shoot(tester, 'home-es', size: phone, locale: const Locale('es'));
    await shoot(
      tester,
      'home-small',
      size: const Size(320, 568),
      locale: const Locale('en'),
    );
    await shoot(
      tester,
      'home-tablet',
      size: const Size(834, 1112),
      locale: const Locale('en'),
    );
    await shoot(
      tester,
      'home-large-text',
      size: phone,
      locale: const Locale('pt'),
      textScale: 1.8,
    );
    await shoot(
      tester,
      'home-empty',
      size: phone,
      locale: const Locale('en'),
      empty: true,
    );
  });
}
