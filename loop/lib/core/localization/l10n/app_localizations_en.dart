// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LOOP';

  @override
  String get menuButton => 'Menu';

  @override
  String get profileButton => 'Your profile';

  @override
  String get statusOnline => 'Online';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name.';
  }

  @override
  String get heresWhatsImportant => 'Here\'s what\'s important today.';

  @override
  String get loopsActive => 'LOOPS\nACTIVE';

  @override
  String activeLoopsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active loops',
      one: '1 active loop',
    );
    return '$_temp0';
  }

  @override
  String get atRisk => 'AT RISK';

  @override
  String get atRiskDescription => 'Needs your attention';

  @override
  String get waiting => 'WAITING';

  @override
  String get waitingDescription => 'Waiting for others';

  @override
  String get today => 'TODAY';

  @override
  String get todayDescription => 'Planned for today';

  @override
  String get done => 'DONE';

  @override
  String get doneDescription => 'Loops closed';

  @override
  String summaryCardSemantics(String title, String description, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loops',
      one: '1 loop',
      zero: 'no loops',
    );
    return '$title, $description, $_temp0';
  }

  @override
  String get aiInsight => 'AI INSIGHT';

  @override
  String get upNext => 'UP NEXT';

  @override
  String get addToCalendar => 'Add to calendar';

  @override
  String upNextToday(String time) {
    return 'Today, $time';
  }

  @override
  String upNextTomorrow(String time) {
    return 'Tomorrow, $time';
  }

  @override
  String upNextOnDate(String date, String time) {
    return '$date, $time';
  }

  @override
  String countdownDaysHours(int days, int hours) {
    return 'in ${days}d ${hours}h';
  }

  @override
  String countdownHoursMinutes(int hours, int minutes) {
    return 'in ${hours}h ${minutes}m';
  }

  @override
  String countdownMinutes(int minutes) {
    return 'in ${minutes}m';
  }

  @override
  String get countdownNow => 'now';

  @override
  String get countdownOverdue => 'overdue';

  @override
  String get navHome => 'Home';

  @override
  String get navLoops => 'Loops';

  @override
  String get navCreate => 'Create';

  @override
  String get navFocus => 'Focus';

  @override
  String get navMore => 'More';

  @override
  String comingSoonTitle(String section) {
    return '$section is coming';
  }

  @override
  String get comingSoonBody =>
      'This screen is part of a later phase. The Home is the first piece of LOOP to be built.';

  @override
  String get close => 'Close';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Español';

  @override
  String get loading => 'Loading your loops…';

  @override
  String get errorTitle => 'We couldn\'t load your loops';

  @override
  String get errorBody => 'Something went wrong on our side. Nothing was lost.';

  @override
  String get retry => 'Try again';

  @override
  String get emptyTitle => 'Nothing is open';

  @override
  String get emptyBody => 'Every loop is closed. Enjoy it.';

  @override
  String get refresh => 'Refresh';
}
