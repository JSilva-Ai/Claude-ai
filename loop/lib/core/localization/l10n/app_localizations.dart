import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt')
  ];

  /// The product name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'LOOP'**
  String get appTitle;

  /// Positioning line, used by the app switcher entry and the menu sheet.
  ///
  /// In en, this message translates to:
  /// **'The app that makes sure nothing important gets left unfinished.'**
  String get appTagline;

  /// Accessibility label for the header menu button.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuButton;

  /// Accessibility label for the header avatar.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get profileButton;

  /// Accessibility label for the dot on the avatar.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Greeting plus the user's first name, with the sentence punctuation the language wants.
  ///
  /// In en, this message translates to:
  /// **'{greeting}, {name}.'**
  String greetingWithName(String greeting, String name);

  /// No description provided for @heresWhatsImportant.
  ///
  /// In en, this message translates to:
  /// **'Here\'s what\'s important today.'**
  String get heresWhatsImportant;

  /// Label inside the ring. The newline is the intended two-line break.
  ///
  /// In en, this message translates to:
  /// **'LOOPS\nACTIVE'**
  String get loopsActive;

  /// Spoken form of the ring, which is a graphic.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 active loop} other{{count} active loops}}'**
  String activeLoopsSemantics(int count);

  /// No description provided for @atRisk.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get atRisk;

  /// No description provided for @atRiskDescription.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get atRiskDescription;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING'**
  String get waiting;

  /// No description provided for @waitingDescription.
  ///
  /// In en, this message translates to:
  /// **'Waiting for others'**
  String get waitingDescription;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @todayDescription.
  ///
  /// In en, this message translates to:
  /// **'Planned for today'**
  String get todayDescription;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get done;

  /// No description provided for @doneDescription.
  ///
  /// In en, this message translates to:
  /// **'Loops closed'**
  String get doneDescription;

  /// Spoken form of a summary card, so a screen reader gets state without relying on colour.
  ///
  /// In en, this message translates to:
  /// **'{title}, {description}, {count, plural, =0{no loops} =1{1 loop} other{{count} loops}}'**
  String summaryCardSemantics(String title, String description, int count);

  /// No description provided for @aiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHT'**
  String get aiInsight;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'UP NEXT'**
  String get upNext;

  /// No description provided for @addToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get addToCalendar;

  /// Date line when the item is today.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String upNextToday(String time);

  /// No description provided for @upNextTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, {time}'**
  String upNextTomorrow(String time);

  /// No description provided for @upNextOnDate.
  ///
  /// In en, this message translates to:
  /// **'{date}, {time}'**
  String upNextOnDate(String date, String time);

  /// No description provided for @countdownDaysHours.
  ///
  /// In en, this message translates to:
  /// **'in {days}d {hours}h'**
  String countdownDaysHours(int days, int hours);

  /// No description provided for @countdownHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {hours}h {minutes}m'**
  String countdownHoursMinutes(int hours, int minutes);

  /// No description provided for @countdownMinutes.
  ///
  /// In en, this message translates to:
  /// **'in {minutes}m'**
  String countdownMinutes(int minutes);

  /// No description provided for @countdownNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get countdownNow;

  /// No description provided for @countdownOverdue.
  ///
  /// In en, this message translates to:
  /// **'overdue'**
  String get countdownOverdue;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLoops.
  ///
  /// In en, this message translates to:
  /// **'Loops'**
  String get navLoops;

  /// No description provided for @navCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get navCreate;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Placeholder sheet shown where a screen does not exist yet.
  ///
  /// In en, this message translates to:
  /// **'{section} is coming'**
  String comingSoonTitle(String section);

  /// No description provided for @comingSoonBody.
  ///
  /// In en, this message translates to:
  /// **'This screen is part of a later phase. The Home is the first piece of LOOP to be built.'**
  String get comingSoonBody;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your loops…'**
  String get loading;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your loops'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side. Nothing was lost.'**
  String get errorBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing is open'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Every loop is closed. Enjoy it.'**
  String get emptyBody;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
