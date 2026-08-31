// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LOOP';

  @override
  String get appTagline =>
      'La aplicación que evita que lo importante de tu vida quede sin terminar.';

  @override
  String get menuButton => 'Menú';

  @override
  String get profileButton => 'Tu perfil';

  @override
  String get statusOnline => 'En línea';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name.';
  }

  @override
  String get heresWhatsImportant => 'Esto es lo importante de hoy.';

  @override
  String get loopsActive => 'LOOPS\nACTIVOS';

  @override
  String activeLoopsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loops activos',
      one: '1 loop activo',
    );
    return '$_temp0';
  }

  @override
  String get atRisk => 'EN RIESGO';

  @override
  String get atRiskDescription => 'Necesita tu atención';

  @override
  String get waiting => 'EN ESPERA';

  @override
  String get waitingDescription => 'Esperando a otros';

  @override
  String get today => 'HOY';

  @override
  String get todayDescription => 'Previsto para hoy';

  @override
  String get done => 'HECHO';

  @override
  String get doneDescription => 'Loops cerrados';

  @override
  String summaryCardSemantics(String title, String description, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loops',
      one: '1 loop',
      zero: 'ningún loop',
    );
    return '$title, $description, $_temp0';
  }

  @override
  String get aiInsight => 'INSIGHT DE IA';

  @override
  String get upNext => 'A CONTINUACIÓN';

  @override
  String get addToCalendar => 'Añadir al calendario';

  @override
  String upNextToday(String time) {
    return 'Hoy, $time';
  }

  @override
  String upNextTomorrow(String time) {
    return 'Mañana, $time';
  }

  @override
  String upNextOnDate(String date, String time) {
    return '$date, $time';
  }

  @override
  String countdownDaysHours(int days, int hours) {
    return 'en $days d $hours h';
  }

  @override
  String countdownHoursMinutes(int hours, int minutes) {
    return 'en $hours h $minutes min';
  }

  @override
  String countdownMinutes(int minutes) {
    return 'en $minutes min';
  }

  @override
  String get countdownNow => 'ahora';

  @override
  String get countdownOverdue => 'atrasado';

  @override
  String get navHome => 'Inicio';

  @override
  String get navLoops => 'Loops';

  @override
  String get navCreate => 'Crear';

  @override
  String get navFocus => 'Enfoque';

  @override
  String get navMore => 'Más';

  @override
  String comingSoonTitle(String section) {
    return '$section llegará pronto';
  }

  @override
  String get comingSoonBody =>
      'Esta pantalla forma parte de una fase posterior. La Home es la primera pieza de LOOP.';

  @override
  String get close => 'Cerrar';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageSpanish => 'Español';

  @override
  String get loading => 'Cargando tus loops…';

  @override
  String get errorTitle => 'No pudimos cargar tus loops';

  @override
  String get errorBody => 'Algo falló de nuestro lado. No se perdió nada.';

  @override
  String get retry => 'Intentar de nuevo';

  @override
  String get emptyTitle => 'No hay nada abierto';

  @override
  String get emptyBody => 'Todos los loops están cerrados. Disfrútalo.';

  @override
  String get refresh => 'Actualizar';
}
