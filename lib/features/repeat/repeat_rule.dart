import 'package:flutter/foundation.dart' show immutable;

/// Единица повторения.
enum RepeatUnit { none, day, week, month, year }

/// Чем месяц отмеряет дату повтора.
///
/// Три ответа, а не один: «27-го» описывает оплату, «второй вторник» —
/// расписание занятий, «последний рабочий» — отчёт. Календарь, умеющий одно
/// только число, расписание не опишет.
enum MonthRule {
  /// По числу: 27-го каждого месяца.
  byDate,

  /// По позиции дня недели: второй вторник, последняя пятница.
  byWeekday,

  /// Последний рабочий день месяца.
  lastWorkday,
}

/// Правило повторения в том виде, в каком его собирает человек.
///
/// Экран правит этот объект, а RRULE строится из него одной функцией: правило
/// в базе и правило на экране обязаны сходиться, и сходятся они здесь.
@immutable
class RepeatRule {
  const RepeatRule({
    this.unit = RepeatUnit.week,
    this.interval = 1,
    this.weekdays = const {},
    this.monthRule = MonthRule.byDate,
    this.count,
    this.until,
  });

  const RepeatRule.none() : this(unit: RepeatUnit.none);

  final RepeatUnit unit;
  final int interval;

  /// Дни недели по ISO. Пустой набор — берётся день самого события.
  final Set<int> weekdays;

  /// Чем месяц отмеряет дату. Работает только при [RepeatUnit.month].
  final MonthRule monthRule;

  /// Окончание: после N повторов либо до даты. Оба сразу RFC 5545 запрещает.
  final int? count;
  final DateTime? until;

  bool get repeats => unit != RepeatUnit.none;

  RepeatRule copyWith({
    RepeatUnit? unit,
    int? interval,
    Set<int>? weekdays,
    MonthRule? monthRule,
    Object? count = _keep,
    Object? until = _keep,
  }) =>
      RepeatRule(
        unit: unit ?? this.unit,
        interval: interval ?? this.interval,
        weekdays: weekdays ?? this.weekdays,
        monthRule: monthRule ?? this.monthRule,
        count: count == _keep ? this.count : count as int?,
        until: until == _keep ? this.until : until as DateTime?,
      );

  /// Строка RFC 5545. `null` — событие не повторяется.
  String? toRrule(DateTime start) {
    if (!repeats) return null;

    const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    final parts = <String>[
      'FREQ=${switch (unit) {
        RepeatUnit.day => 'DAILY',
        RepeatUnit.week => 'WEEKLY',
        RepeatUnit.month => 'MONTHLY',
        RepeatUnit.year => 'YEARLY',
        RepeatUnit.none => 'DAILY',
      }}',
      if (interval > 1) 'INTERVAL=$interval',
    ];

    if (unit == RepeatUnit.week) {
      // Пустой набор дней означает «в тот же день, что и событие»: правило
      // без BYDAY повторяется от даты начала, но подпись выходит невнятной.
      final days = weekdays.isEmpty ? {start.weekday} : weekdays;
      parts.add('BYDAY=${(days.toList()..sort()).map((d) => names[d - 1]).join(',')}');
    }

    if (unit == RepeatUnit.month) {
      switch (monthRule) {
        case MonthRule.byDate:
          parts.add('BYMONTHDAY=${start.day}');
        case MonthRule.byWeekday:
          // Позиция считается с конца, когда день последний такой в месяце:
          // «пятая пятница» есть не в каждом месяце, и ряд бы их пропускал,
          // а человек, выбравший последнюю пятницу июля, ждёт её и в августе.
          parts.add('BYDAY=${weekPosition(start)}${names[start.weekday - 1]}');
        case MonthRule.lastWorkday:
          parts
            ..add('BYDAY=MO,TU,WE,TH,FR')
            ..add('BYSETPOS=-1');
      }
    }

    if (count != null) {
      parts.add('COUNT=$count');
    } else if (until != null) {
      // Граница берётся концом дня: «до 31 декабря» означает, что 31-е ещё
      // входит в ряд, а не обрывается накануне в полночь.
      final edge = DateTime(until!.year, until!.month, until!.day, 23, 59);
      parts.add('UNTIL=${_stamp(edge)}');
    }

    return parts.join(';');
  }

  /// Какой по счёту этот день недели в своём месяце: 1–4, либо −1 для
  /// последнего. Отрицательная позиция — не украшение: месяцы разной длины, и
  /// пятого вторника в феврале не бывает.
  static int weekPosition(DateTime day) {
    final daysInMonth = DateTime(day.year, day.month + 1, 0).day;
    if (day.day + 7 > daysInMonth) return -1;
    return ((day.day - 1) ~/ 7) + 1;
  }

  /// Разбор сохранённого правила — чтобы форма открылась на том, что есть.
  static RepeatRule parse(String? rrule, DateTime start) {
    if (rrule == null || rrule.isEmpty) return const RepeatRule.none();

    final body = rrule.startsWith('RRULE:') ? rrule.substring(6) : rrule;
    final parts = <String, String>{
      for (final p in body.split(';'))
        if (p.contains('=')) p.split('=').first: p.split('=').sublist(1).join('='),
    };

    const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    final byDay = parts['BYDAY'];

    return RepeatRule(
      unit: switch (parts['FREQ']) {
        'DAILY' => RepeatUnit.day,
        'WEEKLY' => RepeatUnit.week,
        'MONTHLY' => RepeatUnit.month,
        'YEARLY' => RepeatUnit.year,
        _ => RepeatUnit.week,
      },
      interval: int.tryParse(parts['INTERVAL'] ?? '1') ?? 1,
      weekdays: byDay == null
          ? const {}
          : {
              for (final d in byDay.split(','))
                if (names.contains(d.replaceAll(RegExp(r'[^A-Z]'), '')))
                  names.indexOf(d.replaceAll(RegExp(r'[^A-Z]'), '')) + 1,
            },
      // Что именно отмеряет месяц, видно по набору полей: перечисленные будни
      // с отбором последнего — рабочий день, одиночный день с позицией —
      // «второй вторник», всё остальное — число.
      monthRule: switch (parts) {
        {'BYSETPOS': _, 'BYDAY': final days} when days.contains(',') =>
          MonthRule.lastWorkday,
        {'BYDAY': final days}
            when parts['FREQ'] == 'MONTHLY' &&
                RegExp(r'^-?\d').hasMatch(days) =>
          MonthRule.byWeekday,
        _ => MonthRule.byDate,
      },
      count: int.tryParse(parts['COUNT'] ?? ''),
      until: _parseStamp(parts['UNTIL']),
    );
  }

  static String _stamp(DateTime d) {
    final u = d.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}00Z';
  }

  static DateTime? _parseStamp(String? raw) {
    if (raw == null || raw.length < 8) return null;
    final year = int.tryParse(raw.substring(0, 4));
    final month = int.tryParse(raw.substring(4, 6));
    final day = int.tryParse(raw.substring(6, 8));
    if (year == null || month == null || day == null) return null;
    return DateTime(year, month, day);
  }

  static const Object _keep = Object();
}
