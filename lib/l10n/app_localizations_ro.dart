// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class LRo extends L {
  LRo([String locale = 'ro']) : super(locale);

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navList => 'Listă';

  @override
  String get navAccess => 'Acces';

  @override
  String get navSettings => 'Setări';

  @override
  String get viewDay => 'Zi';

  @override
  String get viewDays => 'Zile';

  @override
  String get viewWeek => 'Săptămână';

  @override
  String get viewMonth => 'Lună';

  @override
  String get readingClock => 'Ceas';

  @override
  String get readingChain => 'Lanț';

  @override
  String get viewNotBuilt => 'Vizualizarea nu este gata';

  @override
  String get newEvent => 'Eveniment nou';

  @override
  String get today => 'azi';

  @override
  String get nothingPlanned => 'Nimic planificat';

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
    return 'ziua $current din $total';
  }

  @override
  String spanUntil(String date) {
    return 'până la $date';
  }
}
