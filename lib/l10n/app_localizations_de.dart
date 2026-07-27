// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navList => 'Liste';

  @override
  String get navAccess => 'Zugriff';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get viewDay => 'Tag';

  @override
  String get viewDays => 'Tage';

  @override
  String get viewWeek => 'Woche';

  @override
  String get viewMonth => 'Monat';

  @override
  String get readingClock => 'Uhr';

  @override
  String get readingChain => 'Kette';

  @override
  String get viewNotBuilt => 'Diese Ansicht fehlt noch';

  @override
  String get newEvent => 'Neuer Termin';

  @override
  String get today => 'heute';

  @override
  String get nothingPlanned => 'Nichts geplant';

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String durationHours(int hours) {
    return '$hours Std.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String spanDayOf(int current, int total) {
    return 'Tag $current von $total';
  }

  @override
  String spanUntil(String date) {
    return 'bis $date';
  }
}
