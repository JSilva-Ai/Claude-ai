import 'dart:async';

import 'package:flutter/widgets.dart';

import 'locale_preferences.dart';

/// The chosen language, or null for "follow the device".
///
/// LOOP ships in three languages from the first build, and on a phone set to a
/// fourth one the only way to see any of them is to choose. Following the
/// system is still the default — an app that ignores the device language is
/// the thing people complain about — but it is not the only option.
class LocaleController extends ChangeNotifier {
  LocaleController({
    LocalePreferences preferences = const EphemeralLocalePreferences(),
  }) : _preferences = preferences;

  final LocalePreferences _preferences;

  Locale? _locale;
  Locale? get locale => _locale;

  /// Reads back whatever was chosen last time.
  ///
  /// Called once at startup. With the phase-1 preferences this resolves to
  /// null and nothing changes, which is why it is safe to call unconditionally
  /// — the day storage is real, this is already the code that restores it.
  Future<void> restore() async {
    final Locale? saved = await _preferences.load();
    if (saved == null || saved == _locale) return;
    _locale = saved;
    notifyListeners();
  }

  void select(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    // Not awaited: the interface repaints on the choice, it does not wait for
    // a disk. A failed write costs the preference, never the interaction.
    unawaited(_preferences.save(locale));
  }
}

class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({
    required LocaleController super.notifier,
    required super.child,
    super.key,
  });

  static LocaleController of(BuildContext context) {
    final LocaleScope? scope =
        context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'No LocaleScope above this widget');
    return scope!.notifier!;
  }
}
