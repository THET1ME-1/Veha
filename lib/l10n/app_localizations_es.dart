// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get navCalendar => 'Calendario';

  @override
  String get navList => 'Lista';

  @override
  String get navAccess => 'Acceso';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get viewDay => 'Día';

  @override
  String get viewDays => 'Días';

  @override
  String get viewWeek => 'Semana';

  @override
  String get viewMonth => 'Mes';

  @override
  String get readingClock => 'Reloj';

  @override
  String get readingChain => 'Cadena';

  @override
  String get viewNotBuilt => 'Esta vista aún no está lista';

  @override
  String get newEvent => 'Nuevo evento';

  @override
  String get today => 'hoy';

  @override
  String get nothingPlanned => 'Nada planeado';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String spanDayOf(int current, int total) {
    return 'día $current de $total';
  }

  @override
  String spanUntil(String date) {
    return 'hasta $date';
  }
}
