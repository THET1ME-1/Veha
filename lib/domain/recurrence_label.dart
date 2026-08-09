import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart' show Frequency;

import '../data/models.dart';
import '../l10n/app_localizations.dart';
import 'recurrence.dart';

/// Подпись правила повторения на языке приложения.
///
/// Строится из RRULE каждый раз: правило меняется, а сохранённая строка
/// осталась бы старой и врала бы про ряд.
///
/// Слова собираются здесь, а не в домене повторений: в русском порядковое
/// слово согласуется с родом дня («вторая пятница», но «второй вторник»), а
/// имена дней недели проще взять у `intl` — там они верны на всех семи языках.
String? recurrenceLabelOf(L l, VEvent e, {String locale = 'ru'}) {
  if (e.rrule == null) return null;
  try {
    final shape = Recurrence.shape(e.rrule!);
    final names = _weekdayNames(locale);

    switch (shape.frequency) {
      case Frequency.daily:
        return l.ruleDaily(shape.interval);
      case Frequency.weekly:
        final every = l.ruleWeekly(shape.interval);
        if (shape.weekdays.isEmpty) return every;
        final days = shape.weekdays.map((d) => names[d - 1]).join(', ');
        return l.ruleWeekDays(every, days);
      case Frequency.monthly:
        final every = l.ruleMonthly(shape.interval);
        final pos = shape.monthPosition;
        final weekday = shape.monthWeekday;
        if (pos == null || weekday == null) return every;
        final ordinals = switch (pos) {
          -1 => l.ordinalLast,
          1 => l.ordinal1,
          2 => l.ordinal2,
          3 => l.ordinal3,
          _ => l.ordinal4,
        }
            .split(',');
        return l.ruleMonthPosition(every, ordinals[weekday - 1], names[weekday - 1]);
      case Frequency.yearly:
        return l.ruleYearly;
      default:
        return l.repeatByRule;
    }
  } on FormatException {
    // Правило могло приехать с чужого устройства в неизвестном диалекте:
    // событие показываем без подписи, но не роняем экран.
    return null;
  }
}

/// Имена дней недели языка приложения, с понедельника.
List<String> _weekdayNames(String locale) {
  final format = DateFormat('EEEE', locale);
  // 5 января 2026 — понедельник; неделя от него и берётся.
  final monday = DateTime(2026, 1, 5);
  return [
    for (var i = 0; i < 7; i++) format.format(monday.add(Duration(days: i))),
  ];
}
