// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class LPl extends L {
  LPl([String locale = 'pl']) : super(locale);

  @override
  String get navCalendar => 'Kalendarz';

  @override
  String get navList => 'Lista';

  @override
  String get navAccess => 'Dostęp';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get viewDay => 'Dzień';

  @override
  String get viewDays => 'Dni';

  @override
  String get viewWeek => 'Tydzień';

  @override
  String get viewMonth => 'Miesiąc';

  @override
  String get readingClock => 'Zegar';

  @override
  String get readingChain => 'Łańcuch';

  @override
  String get viewNotBuilt => 'Ten widok nie jest gotowy';

  @override
  String get newEvent => 'Nowe wydarzenie';

  @override
  String get today => 'dziś';

  @override
  String get nothingPlanned => 'Nic nie zaplanowano';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours godz.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours godz. $minutes min';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current. z $total';
  }

  @override
  String spanUntil(String date) {
    return 'do $date';
  }
}
