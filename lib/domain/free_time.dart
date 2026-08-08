import '../data/models.dart';

/// Свободные окна дня.
///
/// Календарь отвечает на «когда я занят» и молчит про «когда я свободен» —
/// а спрашивают чаще второе. Считается без базы и без экрана: чистая функция
/// под тестами.
class TimeSlot {
  const TimeSlot(this.start, this.end);

  final DateTime start;
  final DateTime end;

  Duration get length => end.difference(start);
}

/// Границы дня, в которых имеет смысл искать окно. Ночь не предлагаем:
/// «свободен в 04:00» — правда, которая никому не нужна.
class DayBounds {
  const DayBounds({this.from = 8, this.to = 22});

  final int from;
  final int to;
}

/// Окна между занятостями за день.
///
/// Многодневные полосы не считаются занятостью: абонемент в бассейн помечает
/// день, а не занимает его.
List<TimeSlot> freeSlots(
  List<VEvent> events,
  DateTime day, {
  Duration atLeast = const Duration(minutes: 30),
  DayBounds bounds = const DayBounds(),
  DateTime? now,
}) {
  final start = DateTime(day.year, day.month, day.day, bounds.from);
  final end = DateTime(day.year, day.month, day.day, bounds.to);

  // Прошедшее время не предлагаем: окно в десять утра бесполезно в полдень.
  var cursor = start;
  if (now != null &&
      now.year == day.year &&
      now.month == day.month &&
      now.day == day.day &&
      now.isAfter(cursor)) {
    cursor = now;
  }

  final busy = [
    for (final e in events)
      // Событие, помеченное «свободен», стоит в календаре отметкой и часов
      // не держит: день рождения не мешает назначить встречу.
      if (e.availability == Availability.busy &&
          !e.isMultiDay &&
          e.end.isAfter(cursor) &&
          e.busyFrom.isBefore(end))
        e,
  ]..sort((a, b) => a.busyFrom.compareTo(b.busyFrom));

  final slots = <TimeSlot>[];
  for (final e in busy) {
    // Занятость начинается с выхода из дома, а не с начала встречи: окно
    // прямо перед поездкой на другой конец города свободным не считается.
    final from = e.busyFrom;
    if (from.isAfter(cursor)) {
      final gap = TimeSlot(cursor, from.isBefore(end) ? from : end);
      if (gap.length >= atLeast) slots.add(gap);
    }
    if (e.end.isAfter(cursor)) cursor = e.end;
  }

  if (cursor.isBefore(end)) {
    final tail = TimeSlot(cursor, end);
    if (tail.length >= atLeast) slots.add(tail);
  }

  return slots;
}

/// Первое окно нужной длины начиная с этого дня. Смотрит вперёд не дальше
/// [days] суток: «никогда» честнее бесконечного поиска.
TimeSlot? firstFreeSlot({
  required List<VEvent> Function(DateTime day) eventsOf,
  required DateTime from,
  required Duration length,
  DayBounds bounds = const DayBounds(),
  int days = 14,
  DateTime? now,
}) {
  for (var i = 0; i < days; i++) {
    final day = DateTime(from.year, from.month, from.day + i);
    final slots = freeSlots(
      eventsOf(day),
      day,
      atLeast: length,
      bounds: bounds,
      now: i == 0 ? now : null,
    );
    if (slots.isNotEmpty) {
      final slot = slots.first;
      // Начало округляем вверх до четверти часа: событий на 10:07 не бывает.
      final minute = slot.start.minute;
      final rounded = minute % 15 == 0 ? minute : (minute ~/ 15 + 1) * 15;
      final start = DateTime(
        slot.start.year,
        slot.start.month,
        slot.start.day,
        slot.start.hour,
        rounded,
      );
      if (!start.add(length).isAfter(slot.end)) {
        return TimeSlot(start, start.add(length));
      }
      return slot;
    }
  }
  return null;
}

/// Накладываются ли два промежутка. Встык — не накладка: занятие, которое
/// кончается ровно тогда, когда начинается следующее, никому не мешает.
bool intervalsOverlap(
  DateTime aStart,
  DateTime aEnd,
  DateTime bStart,
  DateTime bEnd,
) =>
    aStart.isBefore(bEnd) && aEnd.isAfter(bStart);

/// С чем событие пересекается. Пустой список — свободно.
///
/// Событие без окончания не считается ни с той, ни с другой стороны: за ним
/// не числится времени, и «накладка» с ним была бы выдумкой.
List<VEvent> conflictsOf(VEvent event, List<VEvent> others) =>
    event.isOpenEnded
        ? const []
        : [
            for (final other in others)
              if (other.id != event.id &&
                  !other.isMultiDay &&
                  !other.isOpenEnded &&
                  intervalsOverlap(
                      event.start, event.end, other.start, other.end))
                other,
          ];
