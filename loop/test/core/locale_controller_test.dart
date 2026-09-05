import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/localization/locale_controller.dart';
import 'package:loop/core/localization/locale_preferences.dart';

/// Records what it was asked to remember, and hands back whatever it was
/// seeded with — the whole surface a real implementation has to satisfy.
class _RecordingPreferences implements LocalePreferences {
  _RecordingPreferences([this.stored]);

  Locale? stored;
  final List<Locale?> saved = <Locale?>[];

  @override
  Future<Locale?> load() async => stored;

  @override
  Future<void> save(Locale? locale) async {
    saved.add(locale);
  }
}

void main() {
  group('LocaleController', () {
    test('follows the device until something is chosen', () {
      expect(LocaleController().locale, isNull);
    });

    test('restores what was stored', () async {
      final _RecordingPreferences prefs = _RecordingPreferences(
        const Locale('pt'),
      );
      final LocaleController controller = LocaleController(
        preferences: prefs,
      );

      await controller.restore();

      expect(controller.locale, const Locale('pt'));
    });

    test('restoring nothing leaves the device in charge', () async {
      final LocaleController controller = LocaleController(
        preferences: _RecordingPreferences(),
      );
      int notifications = 0;
      controller.addListener(() => notifications++);

      await controller.restore();

      expect(controller.locale, isNull);
      // Nothing changed, so nothing rebuilds.
      expect(notifications, 0);
    });

    test('writes a choice through to storage', () async {
      final _RecordingPreferences prefs = _RecordingPreferences();
      final LocaleController controller = LocaleController(
        preferences: prefs,
      );

      controller.select(const Locale('es'));
      controller.select(null);

      // The write is not awaited by select — the interface repaints on the
      // choice — so let the microtasks drain before reading the record.
      await Future<void>.delayed(Duration.zero);

      expect(prefs.saved, <Locale?>[const Locale('es'), null]);
    });

    test('choosing the language already in effect changes nothing', () async {
      final _RecordingPreferences prefs = _RecordingPreferences();
      final LocaleController controller = LocaleController(
        preferences: prefs,
      );
      controller.select(const Locale('es'));
      controller.select(const Locale('es'));
      await Future<void>.delayed(Duration.zero);

      expect(prefs.saved.length, 1);
    });

    test('the shipped preferences forget, and say so plainly', () async {
      const LocalePreferences prefs = EphemeralLocalePreferences();
      await prefs.save(const Locale('pt'));
      expect(await prefs.load(), isNull);
    });
  });
}
