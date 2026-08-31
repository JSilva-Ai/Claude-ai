import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/localization/l10n/app_localizations.dart';
import 'core/localization/locale_controller.dart';
import 'core/theme/loop_theme.dart';
import 'core/utils/clock.dart';
import 'features/home/data/home_repository.dart';
import 'features/home/data/mock_home_repository.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/state/home_controller.dart';

/// The application.
///
/// Both dependencies it has — where the data comes from and what time it is —
/// are constructor arguments with sensible defaults. That is what lets a test
/// mount the whole app against a failing repository at a fixed hour without a
/// service locator anywhere in the project.
class LoopApp extends StatefulWidget {
  const LoopApp({
    this.repository = const MockHomeRepository(),
    this.clock = const Clock(),
    this.initialLocale,
    super.key,
  });

  final HomeRepository repository;
  final Clock clock;

  /// Starts in a chosen language instead of the device's.
  ///
  /// Null means "follow the system", which is what the app does in production
  /// until someone picks a language. It is a constructor argument so a test or
  /// a screenshot run can open the Home in Portuguese without going through
  /// the menu, and so a saved preference has somewhere to be restored into.
  final Locale? initialLocale;

  @override
  State<LoopApp> createState() => _LoopAppState();
}

class _LoopAppState extends State<LoopApp> {
  late final HomeController _home = HomeController(
    repository: widget.repository,
  );
  late final LocaleController _locale = LocaleController()
    ..select(widget.initialLocale);

  @override
  void initState() {
    super.initState();
    _home.load();
  }

  @override
  void dispose() {
    _home.dispose();
    _locale.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      notifier: _locale,
      child: ListenableBuilder(
        listenable: _locale,
        builder: (BuildContext context, _) => MaterialApp(
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: LoopTheme.dark,
          // One theme for now. `themeMode` is left at its default rather than
          // forced to dark, so the day a light theme exists the switch is a
          // `darkTheme:` line and not a search for hardcoded colours.
          locale: _locale.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AnnotatedRegion<SystemUiOverlayStyle>(
            // The page paints its own dark ground under the status bar, so the
            // bars are transparent and their icons light. Set here rather than
            // in main() so it survives a theme change later.
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: ListenableBuilder(
              listenable: _home,
              builder: (BuildContext context, _) => HomeScope(
                notifier: _home,
                child: HomeScreen(clock: widget.clock),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
