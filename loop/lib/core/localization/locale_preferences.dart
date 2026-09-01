import 'package:flutter/widgets.dart';

/// Where the chosen language is remembered between launches.
///
/// The seam exists; the storage does not. Persisting a preference on a phone
/// means a plugin — `shared_preferences`, or `path_provider` and a file — and
/// a plugin is a platform channel, a version to track and a native build to
/// keep working, which is more than this phase should spend to remember one
/// string. So the interface is here, [LocaleController] already reads and
/// writes through it, and adding real storage later is one class implementing
/// two methods plus one argument at the call site in `app.dart`.
///
/// Deliberately async: every real implementation of this is.
abstract interface class LocalePreferences {
  /// The saved language, or null for "never chosen — follow the device".
  Future<Locale?> load();

  /// Remembers a choice. Null clears it back to following the device.
  Future<void> save(Locale? locale);
}

/// The implementation shipped in phase 1: it forgets.
///
/// Not a stub that throws — the app runs against this, and its behaviour is
/// exactly today's behaviour, which is that a language chosen from the menu
/// lasts until the app is closed.
@immutable
class EphemeralLocalePreferences implements LocalePreferences {
  const EphemeralLocalePreferences();

  @override
  Future<Locale?> load() async => null;

  @override
  Future<void> save(Locale? locale) async {}
}
