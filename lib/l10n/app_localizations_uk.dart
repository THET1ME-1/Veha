// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class LUk extends L {
  LUk([String locale = 'uk']) : super(locale);

  @override
  String get navCalendar => 'Календар';

  @override
  String get navList => 'Список';

  @override
  String get navAccess => 'Доступ';

  @override
  String get navSettings => 'Налаштування';

  @override
  String get viewDay => 'День';

  @override
  String get viewDays => 'Дні';

  @override
  String get viewWeek => 'Тиждень';

  @override
  String get viewMonth => 'Місяць';

  @override
  String get readingClock => 'Годинник';

  @override
  String get readingChain => 'Ланцюжок';

  @override
  String get viewNotBuilt => 'Вигляд ще не зібрано';

  @override
  String get newEvent => 'Нова подія';

  @override
  String get today => 'сьогодні';

  @override
  String get nothingPlanned => 'Нічого не заплановано';

  @override
  String durationMinutes(int minutes) {
    return '$minutes хв';
  }

  @override
  String durationHours(int hours) {
    return '$hours год';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours год $minutes хв';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current-й із $total';
  }

  @override
  String spanUntil(String date) {
    return 'до $date';
  }
}
