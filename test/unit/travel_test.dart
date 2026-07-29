import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/domain/day_review.dart';
import 'package:veha/domain/free_time.dart';

import 'sqlite_for_tests.dart';

/// Время на дорогу до места.
///
/// Полчаса пути — это занятые полчаса: календарь, который считает свободным
/// время прямо перед встречей на другом конце города, врёт.
void main() {
  setUpAll(useSystemSqlite);

  final day = DateTime(2026, 7, 27);

  VEvent meeting({int travel = 0, int hour = 12}) => VEvent(
        id: 'm',
        calendarId: 'c',
        title: 'Встреча',
        start: DateTime(day.year, day.month, day.day, hour),
        end: DateTime(day.year, day.month, day.day, hour + 1),
        location: 'Кофейня',
        travelMinutes: travel,
      );

  test('Дорога сдвигает начало занятости, но не само событие', () {
    final e = meeting(travel: 30);
    expect(e.start.hour, 12);
    expect(e.busyFrom.hour, 11);
    expect(e.busyFrom.minute, 30);
    // Без дороги занятость начинается ровно с события.
    expect(meeting().busyFrom, meeting().start);
  });

  test('Окно перед встречей укорачивается на дорогу', () {
    final slots = freeSlots(
      [meeting(travel: 30)],
      day,
      bounds: const DayBounds(from: 9, to: 18),
    );

    final before = slots.first;
    expect(before.end.hour, 11);
    expect(before.end.minute, 30);
  });

  test('Дорога считается занятым временем в разборе дня', () {
    final review = reviewDay(
      [meeting(travel: 30)],
      day,
      bounds: const DayBounds(from: 9, to: 18),
    );
    expect(review.busy, const Duration(minutes: 90));
  });

  test('Дорога переживает круг через базу', () async {
    final db = VehaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = VehaRepository(db);
    await repo.upsertCalendar(const VCalendar(
      id: 'c',
      name: 'Личное',
      iconName: 'home',
      color: Color(0xFF41CCB5),
    ));

    await repo.upsertEvent(meeting(travel: 45));
    final back = await repo.eventById('m');

    expect(back?.travelMinutes, 45);
  });
}
