import 'package:flutter/widgets.dart';

/// The chosen language, or null for "follow the device".
///
/// LOOP ships in three languages from the first build, and on a phone set to a
/// fourth one the only way to see any of them is to choose. Following the
/// system is still the default — an app that ignores the device language is
/// the thing people complain about — but it is not the only option.
class LocaleController extends ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void select(Locale? locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
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
