import 'package:flutter/foundation.dart' show immutable;

/// Из чего состоит вид «Неделя».
///
/// Семь колонок нужны не всем: у сменного графика неделя из трёх дней, у
/// студента — пять будних, у кого-то суббота рабочая, а понедельник нет.
/// Поэтому набор дней задаёт человек, а не календарь.
@immutable
class WeekLayout {
  WeekLayout({
    required Set<int> weekdays,
    this.firstDay = DateTime.monday,
  }) : weekdays = weekdays.isEmpty
            ? const {1, 2, 3, 4, 5, 6, 7}
            : Set.unmodifiable(weekdays.toList()..sort());

  /// Полная неделя — то, чего ждут по умолчанию.
  static final WeekLayout full = WeekLayout(weekdays: const {1, 2, 3, 4, 5, 6, 7});

  /// Дни недели по ISO: понедельник 1, воскресенье 7.
  final Set<int> weekdays;

  /// С какого дня начинается неделя.
  final int firstDay;

  bool get isFullWeek => weekdays.length == 7;

  /// Колонки для недели, в которую попадает [day].
  ///
  /// Выбранный день попадает в набор всегда, даже если его день недели
  /// отключён: иначе человек тыкает в субботу и остаётся без субботы.
  List<DateTime> daysOf(DateTime day) {
    final start = _weekStart(day);
    final selected = DateTime(day.year, day.month, day.day);

    final days = <DateTime>[
      for (var i = 0; i < 7; i++)
        if (weekdays.contains(start.add(Duration(days: i)).weekday) ||
            start.add(Duration(days: i)) == selected)
          start.add(Duration(days: i)),
    ];
    return days;
  }

  DateTime _weekStart(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    final shift = (date.weekday - firstDay + 7) % 7;
    return date.subtract(Duration(days: shift));
  }

  WeekLayout toggle(int weekday) {
    final next = weekdays.toSet();
    if (!next.remove(weekday)) next.add(weekday);
    return WeekLayout(weekdays: next, firstDay: firstDay);
  }

  WeekLayout withFirstDay(int day) =>
      WeekLayout(weekdays: weekdays, firstDay: day);

  /// Хранится строкой в настройках: «1234567/1» — дни и первый день недели.
  String encode() => '${weekdays.join()}/$firstDay';

  static WeekLayout decode(String? raw) {
    if (raw == null) return full;
    final parts = raw.split('/');
    if (parts.length != 2) return full;

    final days = <int>{
      for (final c in parts.first.split(''))
        if (int.tryParse(c) case final d? when d >= 1 && d <= 7) d,
    };
    final first = int.tryParse(parts.last);
    if (days.isEmpty || first == null || first < 1 || first > 7) return full;

    return WeekLayout(weekdays: days, firstDay: first);
  }
}
