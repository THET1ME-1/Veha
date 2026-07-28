import '../data/models.dart';

/// Один будильник: что показать и когда.
class PlannedReminder {
  const PlannedReminder({
    required this.eventId,
    required this.minutesBefore,
    required this.moment,
    required this.title,
    required this.eventStart,
  });

  /// Ключ экземпляра, а не ряда: занятия одного ряда предупреждают по
  /// отдельности.
  final String eventId;
  final int minutesBefore;

  /// Момент срабатывания в «настенном» времени события.
  final DateTime moment;
  final String title;
  final DateTime eventStart;

  /// Ключ будильника для системы: она хранит его числом.
  ///
  /// Считается из пары «событие + срок», поэтому пересчёт плана попадает в те
  /// же ключи и не плодит дубли. Старший бит снят: отрицательные значения
  /// Android принимает, но читать их в логах невозможно.
  int get alarmId => Object.hash(eventId, minutesBefore) & 0x3fffffff;
}

/// План будильников на ближайшее время.
///
/// [events] — уже развёрнутые экземпляры: развёрткой ряда занимается
/// репозиторий, а здесь только отбор. Прошедшие моменты выбрасываются: система
/// показала бы их сразу же после постановки.
///
/// [limit] существует потому, что Android держит ограниченное число
/// отложенных уведомлений (порядка пятисот на приложение). Режем дальний
/// конец: ближние напоминания нужнее, а план пересобирается на каждой правке.
List<PlannedReminder> planReminders(
  List<VEvent> events, {
  required DateTime now,
  int limit = 200,
}) {
  final out = <PlannedReminder>[];

  for (final e in events) {
    for (final minutes in e.reminders) {
      final moment = e.start.subtract(Duration(minutes: minutes));
      if (!moment.isAfter(now)) continue;
      out.add(PlannedReminder(
        eventId: e.id,
        minutesBefore: minutes,
        moment: moment,
        title: e.title,
        eventStart: e.start,
      ));
    }
  }

  out.sort((a, b) => a.moment.compareTo(b.moment));
  return out.length <= limit ? out : out.sublist(0, limit);
}
