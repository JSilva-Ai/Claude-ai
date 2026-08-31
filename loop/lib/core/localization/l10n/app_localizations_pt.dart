// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'LOOP';

  @override
  String get appTagline =>
      'O aplicativo que não deixa sua vida ficar pela metade.';

  @override
  String get menuButton => 'Menu';

  @override
  String get profileButton => 'Seu perfil';

  @override
  String get statusOnline => 'Online';

  @override
  String get greetingMorning => 'Bom dia';

  @override
  String get greetingAfternoon => 'Boa tarde';

  @override
  String get greetingEvening => 'Boa noite';

  @override
  String greetingWithName(String greeting, String name) {
    return '$greeting, $name.';
  }

  @override
  String get heresWhatsImportant => 'Veja o que é importante hoje.';

  @override
  String get loopsActive => 'LOOPS\nATIVOS';

  @override
  String activeLoopsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loops ativos',
      one: '1 loop ativo',
    );
    return '$_temp0';
  }

  @override
  String get atRisk => 'EM RISCO';

  @override
  String get atRiskDescription => 'Precisa da sua atenção';

  @override
  String get waiting => 'AGUARDANDO';

  @override
  String get waitingDescription => 'Esperando outras pessoas';

  @override
  String get today => 'HOJE';

  @override
  String get todayDescription => 'Planejado para hoje';

  @override
  String get done => 'CONCLUÍDO';

  @override
  String get doneDescription => 'Loops fechados';

  @override
  String summaryCardSemantics(String title, String description, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loops',
      one: '1 loop',
      zero: 'nenhum loop',
    );
    return '$title, $description, $_temp0';
  }

  @override
  String get aiInsight => 'INSIGHT DA IA';

  @override
  String get upNext => 'A SEGUIR';

  @override
  String get addToCalendar => 'Adicionar à agenda';

  @override
  String upNextToday(String time) {
    return 'Hoje, $time';
  }

  @override
  String upNextTomorrow(String time) {
    return 'Amanhã, $time';
  }

  @override
  String upNextOnDate(String date, String time) {
    return '$date, $time';
  }

  @override
  String countdownDaysHours(int days, int hours) {
    return 'em ${days}d ${hours}h';
  }

  @override
  String countdownHoursMinutes(int hours, int minutes) {
    return 'em ${hours}h ${minutes}min';
  }

  @override
  String countdownMinutes(int minutes) {
    return 'em ${minutes}min';
  }

  @override
  String get countdownNow => 'agora';

  @override
  String get countdownOverdue => 'atrasado';

  @override
  String get navHome => 'Início';

  @override
  String get navLoops => 'Loops';

  @override
  String get navCreate => 'Criar';

  @override
  String get navFocus => 'Foco';

  @override
  String get navMore => 'Mais';

  @override
  String comingSoonTitle(String section) {
    return '$section está a caminho';
  }

  @override
  String get comingSoonBody =>
      'Esta tela faz parte de uma fase posterior. A Home é a primeira peça do LOOP a ser construída.';

  @override
  String get close => 'Fechar';

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
  String get loading => 'Carregando seus loops…';

  @override
  String get errorTitle => 'Não conseguimos carregar seus loops';

  @override
  String get errorBody => 'Algo deu errado do nosso lado. Nada foi perdido.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get emptyTitle => 'Nada em aberto';

  @override
  String get emptyBody => 'Todos os loops estão fechados. Aproveite.';

  @override
  String get refresh => 'Atualizar';
}
