import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/reminder_plan.dart';

/// План напоминаний — чистая функция: что показать и когда. Система умеет
/// держать ограниченное число будильников, поэтому решение, какие из них
/// поставить, важнее самой постановки.
void main() {
  VEvent event({
    String id = 'e1',
    required DateTime start,
    List<int> reminders = const [30],
    String title = 'Английский',
    int travel = 0,
  }) =>
      VEvent(
        id: id,
        calendarId: 'c-study',
        title: title,
        start: start,
        end: start.add(const Duration(hours: 1)),
        reminders: reminders,
        travelMinutes: travel,
      );

  final now = DateTime(2026, 7, 28, 9);

  test('Момент считается от начала события', () {
    final plan = planReminders(
      [event(start: DateTime(2026, 7, 28, 16))],
      now: now,
    );

    expect(plan, hasLength(1));
    expect(plan.single.moment, DateTime(2026, 7, 28, 15, 30));
    expect(plan.single.title, 'Английский');
  });

  test('Прошедшее не планируется', () {
    final plan = planReminders(
      [
        event(start: DateTime(2026, 7, 28, 9, 10)), // напомнить надо было в 8:40
        event(id: 'e2', start: DateTime(2026, 7, 28, 18)),
      ],
      now: now,
    );

    expect(plan.map((r) => r.eventId), ['e2']);
  });

  test('Несколько сроков одного события — несколько будильников', () {
    final plan = planReminders(
      [
        event(start: DateTime(2026, 7, 29, 10), reminders: const [1440, 30]),
      ],
      now: now,
    );

    expect(plan.map((r) => r.minutesBefore), [1440, 30]);
    expect(plan.first.moment, DateTime(2026, 7, 28, 10));
  });

  test('План идёт по времени и режется лимитом с дальнего конца', () {
    final plan = planReminders(
      [
        event(id: 'e1', start: DateTime(2026, 7, 30, 10)),
        event(id: 'e2', start: DateTime(2026, 7, 28, 10)),
        event(id: 'e3', start: DateTime(2026, 7, 29, 10)),
      ],
      now: now,
      limit: 2,
    );

    expect(plan.map((r) => r.eventId), ['e2', 'e3']);
  });

  test('Событие без напоминаний в план не попадает', () {
    final plan = planReminders(
      [event(start: DateTime(2026, 7, 28, 18), reminders: const [])],
      now: now,
    );

    expect(plan, isEmpty);
  });

  // Ключ будильника система хранит числом. Пересчёт плана не должен менять
  // ключи уже поставленных: иначе каждая правка плодит дубли.
  test('Ключ будильника устойчив и различает сроки', () {
    final first = planReminders(
      [event(start: DateTime(2026, 7, 28, 16), reminders: const [60, 30])],
      now: now,
    );
    final second = planReminders(
      [event(start: DateTime(2026, 7, 28, 16), reminders: const [60, 30])],
      now: now,
    );

    expect(first.map((r) => r.alarmId), second.map((r) => r.alarmId));
    expect(first[0].alarmId, isNot(first[1].alarmId));
    expect(first.every((r) => r.alarmId > 0), isTrue);
  });

  test('Дорога сдвигает напоминание к выходу, а не к началу', () {
    // «За полчаса» у встречи на другом конце города означает полчаса до
    // выхода: предупредить в момент, когда ехать уже поздно, — пустой звук.
    final plan = planReminders(
      [
        event(
          start: DateTime(2026, 7, 28, 16),
          reminders: const [30],
          travel: 45,
        ),
      ],
      now: now,
    );

    expect(plan.single.moment, DateTime(2026, 7, 28, 14, 45));
  });
}
