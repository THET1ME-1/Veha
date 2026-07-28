import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/free_time.dart';

/// «Когда я свободен» — вопрос, на который календари обычно не отвечают.
/// Считается без базы, значит и проверяется без неё.
void main() {
  final day = DateTime(2026, 7, 27);

  VEvent at(int fromHour, int toHour, {String id = 'e'}) => VEvent(
        id: id,
        calendarId: 'c',
        title: 'Занято',
        start: DateTime(2026, 7, 27, fromHour),
        end: DateTime(2026, 7, 27, toHour),
      );

  test('Окна считаются между занятостями и по краям дня', () {
    final slots = freeSlots([at(10, 11), at(13, 14, id: 'e2')], day);

    expect(slots.length, 3);
    expect(slots[0].start.hour, 8);
    expect(slots[0].end.hour, 10);
    expect(slots[1].start.hour, 11);
    expect(slots[1].end.hour, 13);
    expect(slots[2].end.hour, 22);
  });

  test('Короткие промежутки не предлагаются', () {
    final slots = freeSlots(
      [at(8, 12), at(12, 22, id: 'e2')],
      day,
      atLeast: const Duration(minutes: 30),
    );
    expect(slots, isEmpty, reason: 'День занят целиком');
  });

  test('Прошедшее время не предлагается', () {
    final slots = freeSlots(
      const [],
      day,
      now: DateTime(2026, 7, 27, 15, 20),
    );
    expect(slots.single.start, DateTime(2026, 7, 27, 15, 20));
  });

  test('Многодневная полоса день не занимает', () {
    final pass = VEvent(
      id: 'pass',
      calendarId: 'c',
      title: 'Абонемент',
      start: DateTime(2026, 7, 20),
      end: DateTime(2026, 8, 20),
    );
    final slots = freeSlots([pass], day);
    expect(slots.single.length, const Duration(hours: 14));
  });

  test('Первое окно ищется по дням вперёд', () {
    final busy = {
      '2026-7-27': [at(8, 22)],
      '2026-7-28': [at(8, 12)],
    };

    final slot = firstFreeSlot(
      eventsOf: (d) => busy['${d.year}-${d.month}-${d.day}'] ?? const [],
      from: day,
      length: const Duration(hours: 2),
    );

    expect(slot, isNotNull);
    expect(slot!.start.day, 28, reason: '27-е занято целиком');
    expect(slot.start.hour, 8, reason: 'Занятость 28-го считается своим днём');
  });

  test('Окна нет — честно ничего', () {
    final slot = firstFreeSlot(
      eventsOf: (d) => [
        VEvent(
          id: 'x',
          calendarId: 'c',
          title: 'Занято',
          start: DateTime(d.year, d.month, d.day, 0),
          end: DateTime(d.year, d.month, d.day, 23, 59),
        ),
      ],
      from: day,
      length: const Duration(hours: 1),
      days: 3,
    );
    expect(slot, isNull);
  });

  test('Пересечения находятся, своё событие не считается', () {
    final event = at(10, 11, id: 'mine');
    final clash = conflictsOf(event, [event, at(10, 30, id: 'other')]);
    expect(clash.single.id, 'other');
  });
}
