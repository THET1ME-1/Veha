import 'package:rrule/rrule.dart';
import 'package:timezone/timezone.dart' as tz;

/// Движок повторяющихся событий.
///
/// Ряд никогда не материализуется в базе: экземпляры разворачиваются только
/// для видимого диапазона плюс запас. Иначе «каждый день без конца» — это
/// бесконечная таблица, и удалить такой ряд потом нечем.
class Recurrence {
  const Recurrence._();

  /// Разворачивает правило в даты внутри окна.
  ///
  /// [start] — первая дата ряда в местном времени, [timezone] — пояс события.
  /// Считаем в поясе события, а не в поясе устройства: занятие в 16:00
  /// остаётся в 16:00 и после переезда, и после перевода часов.
  static List<DateTime> expand({
    required String rrule,
    required DateTime start,
    required DateTime windowStart,
    required DateTime windowEnd,
    String timezone = 'UTC',
    Set<DateTime> excluded = const {},
  }) {
    final rule = RecurrenceRule.fromString(
      rrule.startsWith('RRULE:') ? rrule : 'RRULE:$rrule',
    );

    // Правило разворачивается в «настенном» времени, а не в абсолютном.
    // Занятие в 16:00 обязано остаться в 16:00 и после перевода часов; если
    // считать в UTC, ряд сдвигается на час и все занятия уезжают.
    // rrule принимает только UTC, поэтому местные компоненты подставляются
    // в UTC как есть и так же снимаются обратно.
    final startFloating = _floating(start);
    var after = _floating(windowStart);
    if (after.isBefore(startFloating)) after = startFloating;

    final instances = rule.getInstances(
      start: startFloating,
      after: after,
      before: _floating(windowEnd),
      includeAfter: true,
      includeBefore: true,
    );

    final excludedKeys = {for (final d in excluded) _dayKey(d)};

    return [
      for (final i in instances)
        if (!excludedKeys.contains(_dayKey(i)))
          DateTime(i.year, i.month, i.day, i.hour, i.minute),
    ];
  }

  /// Абсолютный момент экземпляра — для напоминаний и синхронизации.
  /// Вот здесь пояс уже нужен: 16:00 в Кишинёве это разный UTC летом и зимой.
  static DateTime absoluteMoment(DateTime local, String timezone) {
    final t = tz.TZDateTime(
      _location(timezone),
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
    return t.toUtc();
  }

  static DateTime _floating(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, d.hour, d.minute);

  /// Правило «каждые N недель по дням недели» — самый частый случай,
  /// который к тому же не умеет половина календарей.
  static String weekly({
    required int interval,
    required Set<int> weekdays,
    int? count,
    DateTime? until,
  }) {
    const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    final days = (weekdays.toList()..sort()).map((d) => names[d - 1]).join(',');

    final parts = <String>[
      'FREQ=WEEKLY',
      if (interval > 1) 'INTERVAL=$interval',
      if (days.isNotEmpty) 'BYDAY=$days',
      if (count != null) 'COUNT=$count',
      if (until != null) 'UNTIL=${_utcStamp(until)}',
    ];
    return parts.join(';');
  }

  /// Правило по позиции: «вторая среда», «последняя пятница месяца».
  static String monthlyByPosition({
    required int weekday,
    required int position,
    int interval = 1,
  }) {
    const names = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    return [
      'FREQ=MONTHLY',
      if (interval > 1) 'INTERVAL=$interval',
      'BYDAY=$position${names[weekday - 1]}',
    ].join(';');
  }

  /// Правило для половины ряда до разреза: занятия идут до кануна [cut].
  ///
  /// Счётчик повторов честно делится: у ряда «шесть занятий» после разреза
  /// перед четвёртым остаётся три, а не шесть.
  static String endBefore(String rrule, DateTime cut, {required DateTime start}) {
    final parts = _parts(rrule);
    final eve = cut.subtract(const Duration(minutes: 1));

    if (parts.containsKey('COUNT')) {
      parts['COUNT'] = '${_countBefore(rrule, start, cut)}';
      return _join(parts);
    }

    parts['UNTIL'] = _utcStamp(eve);
    return _join(parts);
  }

  /// Правило для половины ряда после разреза.
  static String cutBefore(String rrule, DateTime cut, {required DateTime start}) {
    final parts = _parts(rrule);
    final count = parts['COUNT'];
    if (count == null) return _join(parts);

    final total = int.tryParse(count) ?? 0;
    parts['COUNT'] = '${total - _countBefore(rrule, start, cut)}';
    return _join(parts);
  }

  /// Сколько занятий ряд успел провести до разреза.
  static int _countBefore(String rrule, DateTime start, DateTime cut) => expand(
        rrule: rrule,
        start: start,
        windowStart: start,
        windowEnd: cut.subtract(const Duration(minutes: 1)),
      ).length;

  static Map<String, String> _parts(String rrule) {
    final body = rrule.startsWith('RRULE:') ? rrule.substring(6) : rrule;
    return {
      for (final p in body.split(';'))
        if (p.contains('=')) p.split('=').first: p.split('=').sublist(1).join('='),
    };
  }

  static String _join(Map<String, String> parts) =>
      parts.entries.map((e) => '${e.key}=${e.value}').join(';');

  static tz.Location _location(String name) {
    try {
      return tz.getLocation(name);
    } catch (_) {
      return tz.UTC;
    }
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  static String _utcStamp(DateTime d) {
    final u = d.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}00Z';
  }

  /// Человекочитаемая подпись правила для карточки события.
  ///
  /// Хранить её отдельной строкой нельзя: правило меняется, а подпись
  /// остаётся старой и врёт. Строится из самого RRULE.
  /// [weekdayNames] — форма для перечисления («по понедельникам»),
  /// [weekdayNominative] — именительный падеж для правил по позиции
  /// («последняя пятница»). Одним списком не обойтись: в русском у позиции
  /// другой падеж, да ещё и род меняет прилагательное.
  /// Разобранное правило: частота, шаг и дни. Слова подбирает слой
  /// интерфейса — грамматика у каждого языка своя, и домену тут делать нечего.
  static RecurrenceShape shape(String rrule) {
    final rule = RecurrenceRule.fromString(
      rrule.startsWith('RRULE:') ? rrule : 'RRULE:$rrule',
    );
    return RecurrenceShape(
      frequency: rule.frequency,
      interval: rule.interval ?? 1,
      weekdays: [for (final d in rule.byWeekDays) d.day],
      monthPosition:
          rule.byWeekDays.isEmpty ? null : rule.byWeekDays.first.occurrence,
      monthWeekday:
          rule.byWeekDays.isEmpty ? null : rule.byWeekDays.first.day,
    );
  }
}

/// Правило повторения, разобранное на части.
class RecurrenceShape {
  const RecurrenceShape({
    required this.frequency,
    required this.interval,
    required this.weekdays,
    this.monthPosition,
    this.monthWeekday,
  });

  final Frequency frequency;
  final int interval;

  /// Дни недели, 1 — понедельник.
  final List<int> weekdays;

  /// Позиция дня в месяце: 1..4 либо −1 для последнего.
  final int? monthPosition;
  final int? monthWeekday;
}
