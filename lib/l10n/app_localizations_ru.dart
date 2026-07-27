// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navList => 'Список';

  @override
  String get navAccess => 'Доступ';

  @override
  String get navSettings => 'Настройки';

  @override
  String get viewDay => 'День';

  @override
  String get viewDays => 'Дни';

  @override
  String get viewWeek => 'Неделя';

  @override
  String get viewMonth => 'Месяц';

  @override
  String get readingClock => 'Часы';

  @override
  String get readingChain => 'Цепочка';

  @override
  String get viewNotBuilt => 'Вид ещё не собран';

  @override
  String get newEvent => 'Новое событие';

  @override
  String get today => 'сегодня';

  @override
  String get nothingPlanned => 'Ничего не запланировано';

  @override
  String durationMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String durationHours(int hours) {
    return '$hours ч';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String spanDayOf(int current, int total) {
    return '$current-й из $total';
  }

  @override
  String spanUntil(String date) {
    return 'до $date';
  }
}
