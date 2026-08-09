import '../data/models.dart';

/// Итоги за период: сколько времени занято, чем и когда.
///
/// Считается по развёрнутым событиям, а не по правилам: занятие «каждый
/// вторник» должно давать столько часов, сколько вторников попало в период.
class Stats {
  const Stats({
    required this.busy,
    required this.events,
    required this.tasksDone,
    required this.byCalendar,
    required this.byWeekday,
    required this.days,
    this.busiestDay,
    this.busiestAmount = Duration.zero,
  });

  /// Занятое время. Многодневные полосы сюда не идут: абонемент на месяц
  /// занимает не 720 часов, а те, что человек в зале провёл.
  final Duration busy;

  final int events;
  final int tasksDone;

  /// Время по календарям. Пустой календарь в карту не попадает.
  final Map<String, Duration> byCalendar;

  /// Семь значений, понедельник первым.
  final List<Duration> byWeekday;

  final int days;
  final DateTime? busiestDay;
  final Duration busiestAmount;

  Duration get perDay =>
      days == 0 ? Duration.zero : Duration(minutes: busy.inMinutes ~/ days);

  bool get isEmpty => events == 0 && tasksDone == 0;

  static const empty = Stats(
    busy: Duration.zero,
    events: 0,
    tasksDone: 0,
    byCalendar: {},
    byWeekday: [
      Duration.zero,
      Duration.zero,
      Duration.zero,
      Duration.zero,
      Duration.zero,
      Duration.zero,
      Duration.zero,
    ],
    days: 0,
  );
}

/// Подсчёт итогов.
///
/// Отдельной функцией без базы и виджетов: считать часы и проверять счёт —
/// разные занятия, и второе должно обходиться без экрана.
Stats computeStats({
  required List<VEvent> events,
  required List<VTask> tasks,
  required DateTime from,
  required DateTime to,
}) {
  final byCalendar = <String, Duration>{};
  final byWeekday = List.filled(7, Duration.zero);
  final byDay = <DateTime, Duration>{};
  var busy = Duration.zero;
  var counted = 0;

  for (final e in events) {
    // Обрезаем по краям периода: занятие, начавшееся до понедельника, даёт в
    // неделю только свой хвост.
    final start = e.start.isBefore(from) ? from : e.start;
    final end = e.end.isAfter(to) ? to : e.end;
    if (!end.isAfter(start)) continue;

    counted++;
    // Полосы длиной больше суток — это абонементы и отпуска: они помечают
    // дни, а не занимают часы.
    if (e.isSpan) continue;

    final span = end.difference(start);
    busy += span;
    byCalendar[e.calendarId] = (byCalendar[e.calendarId] ?? Duration.zero) + span;
    byWeekday[start.weekday - 1] += span;

    final day = DateTime(start.year, start.month, start.day);
    byDay[day] = (byDay[day] ?? Duration.zero) + span;
  }

  var tasksDone = 0;
  for (final t in tasks) {
    final at = t.completedAt;
    if (at == null) continue;
    if (at.isBefore(from) || !at.isBefore(to)) continue;
    tasksDone++;
  }

  DateTime? busiestDay;
  var busiestAmount = Duration.zero;
  for (final entry in byDay.entries) {
    if (entry.value > busiestAmount) {
      busiestDay = entry.key;
      busiestAmount = entry.value;
    }
  }

  return Stats(
    busy: busy,
    events: counted,
    tasksDone: tasksDone,
    byCalendar: byCalendar,
    byWeekday: byWeekday,
    days: to.difference(from).inDays,
    busiestDay: busiestDay,
    busiestAmount: busiestAmount,
  );
}
