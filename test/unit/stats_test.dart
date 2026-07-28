import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/stats.dart';

/// Итоги считаются без базы и без экрана — значит и проверяются так же.
void main() {
  final from = DateTime(2026, 7, 27); // Понедельник
  final to = DateTime(2026, 8, 3);

  VEvent event({
    required String id,
    required String calendarId,
    required DateTime start,
    required DateTime end,
  }) =>
      VEvent(
        id: id,
        calendarId: calendarId,
        title: id,
        start: start,
        end: end,
      );

  test('Часы складываются по календарям и дням недели', () {
    final stats = computeStats(
      events: [
        event(
          id: 'a',
          calendarId: 'study',
          start: DateTime(2026, 7, 27, 10),
          end: DateTime(2026, 7, 27, 12),
        ),
        event(
          id: 'b',
          calendarId: 'study',
          start: DateTime(2026, 7, 29, 16),
          end: DateTime(2026, 7, 29, 17, 30),
        ),
        event(
          id: 'c',
          calendarId: 'sport',
          start: DateTime(2026, 7, 27, 19),
          end: DateTime(2026, 7, 27, 20),
        ),
      ],
      tasks: const [],
      from: from,
      to: to,
    );

    expect(stats.busy, const Duration(hours: 4, minutes: 30));
    expect(stats.events, 3);
    expect(stats.byCalendar['study'], const Duration(hours: 3, minutes: 30));
    expect(stats.byCalendar['sport'], const Duration(hours: 1));
    expect(stats.byWeekday[0], const Duration(hours: 3), reason: 'Понедельник');
    expect(stats.byWeekday[2], const Duration(hours: 1, minutes: 30));
    expect(stats.busiestDay, DateTime(2026, 7, 27));
    expect(stats.busiestAmount, const Duration(hours: 3));
    expect(stats.perDay, const Duration(minutes: 38));
  });

  test('Событие на краю периода считается только хвостом', () {
    final stats = computeStats(
      events: [
        event(
          id: 'ночное',
          calendarId: 'home',
          start: DateTime(2026, 7, 26, 22),
          end: DateTime(2026, 7, 27, 2),
        ),
      ],
      tasks: const [],
      from: from,
      to: to,
    );

    expect(stats.busy, const Duration(hours: 2));
  });

  // Абонемент на месяц занимает не 720 часов, а те, что человек в зале
  // провёл. Полосы помечают дни, а не заполняют их.
  test('Многодневная полоса в занятое время не идёт', () {
    final stats = computeStats(
      events: [
        event(
          id: 'абонемент',
          calendarId: 'sport',
          start: DateTime(2026, 7, 20),
          end: DateTime(2026, 8, 20),
        ),
      ],
      tasks: const [],
      from: from,
      to: to,
    );

    expect(stats.busy, Duration.zero);
    expect(stats.events, 1, reason: 'В счётчике событий полоса остаётся');
    expect(stats.byCalendar, isEmpty);
  });

  test('Закрытые задачи считаются по дате отметки', () {
    final stats = computeStats(
      events: const [],
      tasks: [
        VTask(
          id: 't1',
          calendarId: 'home',
          title: 'В периоде',
          completedAt: DateTime(2026, 7, 28, 9),
        ),
        VTask(
          id: 't2',
          calendarId: 'home',
          title: 'До периода',
          completedAt: DateTime(2026, 7, 20, 9),
        ),
        const VTask(id: 't3', calendarId: 'home', title: 'Не закрыта'),
      ],
      from: from,
      to: to,
    );

    expect(stats.tasksDone, 1);
    expect(stats.isEmpty, isFalse);
  });

  test('Пустой период честно пуст', () {
    final stats =
        computeStats(events: const [], tasks: const [], from: from, to: to);
    expect(stats.isEmpty, isTrue);
    expect(stats.perDay, Duration.zero);
  });
}
