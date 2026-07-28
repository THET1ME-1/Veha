import '../data/models.dart';
import 'recurrence.dart';

/// Разворачивает хранимые события в экземпляры для окна `[from; to]`.
///
/// Ряд не лежит в базе строками: занятие «каждый понедельник без конца» —
/// это одна запись плюс правило. Календарю нужны отдельные карточки, поэтому
/// экземпляры рождаются здесь, на чтении, и живут ровно столько, сколько
/// открыт видимый диапазон.
List<VEvent> expandOccurrences(
  List<VEvent> stored, {
  required DateTime from,
  required DateTime to,
  Map<String, Set<DateTime>> excluded = const {},
}) {
  final out = <VEvent>[];

  // Выломанные экземпляры: занятие перенесли на другой час, но ряд остался.
  // Виртуальный экземпляр на старом времени рисовать уже нельзя, иначе
  // занятие раздваивается.
  final overrides = <String>{
    for (final e in stored)
      if (e.recurrenceId != null && e.originalStart != null)
        _slot(e.recurrenceId!, e.originalStart!),
  };

  for (final e in stored) {
    if (e.rrule == null) {
      out.add(e);
      continue;
    }
    // Окно отодвигается назад на длительность события: ночная смена с 23:00
    // до 01:00 принадлежит и следующему дню, а её экземпляр начинается
    // накануне.
    final dates = Recurrence.expand(
      rrule: e.rrule!,
      start: e.start,
      windowStart: from.subtract(e.duration),
      windowEnd: to,
      timezone: e.timezone,
      excluded: excluded[e.id] ?? const {},
    );
    for (final date in dates) {
      if (overrides.contains(_slot(e.id, date))) continue;
      final instance = _instanceAt(e, date);
      if (instance.end.isAfter(from) && instance.start.isBefore(to)) {
        out.add(instance);
      }
    }
  }

  out.sort((a, b) => a.start.compareTo(b.start));
  return out;
}

String _slot(String seriesId, DateTime start) =>
    '$seriesId@${start.millisecondsSinceEpoch}';

VEvent _instanceAt(VEvent series, DateTime start) => VEvent(
      // Ключ экземпляра, а не ряда: три занятия подряд с одним `id` схлопнут
      // друг друга в списках и анимациях.
      id: _slot(series.id, start),
      calendarId: series.calendarId,
      subcategoryId: series.subcategoryId,
      title: series.title,
      start: start,
      end: start.add(series.duration),
      color: series.color,
      iconName: series.iconName,
      isAllDay: series.isAllDay,
      rrule: series.rrule,
      recurrenceId: series.id,
      originalStart: start,
      isVirtual: true,
      timezone: series.timezone,
      location: series.location,
      fields: series.fields,
    );
