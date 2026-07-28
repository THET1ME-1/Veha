import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:veha/data/models.dart';
import 'package:veha/domain/occurrences.dart';
import 'package:veha/domain/recurrence.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  String d(DateTime x) =>
      '${x.day}.${x.month} ${x.hour.toString().padLeft(2, '0')}:${x.minute.toString().padLeft(2, '0')}';

  VEvent lesson({String? rrule, DateTime? start}) => VEvent(
        id: 'e-eng',
        calendarId: 'c-study',
        title: 'Английский',
        start: start ?? DateTime(2026, 5, 4, 16),
        end: (start ?? DateTime(2026, 5, 4, 16)).add(const Duration(hours: 1)),
        rrule: rrule,
      );

  test('Ряд, начатый до окна, разворачивается внутри окна', () {
    final out = expandOccurrences(
      [lesson(rrule: Recurrence.weekly(interval: 1, weekdays: {1}))],
      from: DateTime(2026, 7, 27),
      to: DateTime(2026, 8, 10),
    );

    // 10 августа окно кончается в полночь, а занятие в 16:00 — оно уже за
    // краем.
    expect(out.map((e) => d(e.start)).toList(), ['27.7 16:00', '3.8 16:00']);
  });

  test('Ночной экземпляр, начатый накануне, попадает в окно дня', () {
    final shift = VEvent(
      id: 'e-shift',
      calendarId: 'c-work',
      title: 'Смена',
      start: DateTime(2026, 7, 26, 23),
      end: DateTime(2026, 7, 27, 1),
      rrule: 'FREQ=DAILY',
    );

    final out = expandOccurrences(
      [shift],
      from: DateTime(2026, 7, 27),
      to: DateTime(2026, 7, 28),
    );

    expect(out.map((e) => d(e.start)).toList(), ['26.7 23:00', '27.7 23:00']);
  });

  test('Отменённое занятие пропадает из ряда', () {
    final out = expandOccurrences(
      [lesson(rrule: Recurrence.weekly(interval: 1, weekdays: {1}))],
      from: DateTime(2026, 7, 1),
      to: DateTime(2026, 7, 31),
      excluded: {
        'e-eng': {DateTime(2026, 7, 13)},
      },
    );

    expect(out.map((e) => d(e.start)).toList(),
        ['6.7 16:00', '20.7 16:00', '27.7 16:00']);
  });

  test('Перенесённое занятие вытесняет свой экземпляр, а не дублирует его', () {
    final moved = VEvent(
      id: 'e-eng-0713',
      calendarId: 'c-study',
      title: 'Английский',
      start: DateTime(2026, 7, 13, 18),
      end: DateTime(2026, 7, 13, 19),
      recurrenceId: 'e-eng',
      originalStart: DateTime(2026, 7, 13, 16),
    );

    final out = expandOccurrences(
      [lesson(rrule: Recurrence.weekly(interval: 1, weekdays: {1})), moved],
      from: DateTime(2026, 7, 6),
      to: DateTime(2026, 7, 21),
    );

    expect(out.map((e) => d(e.start)).toList(),
        ['6.7 16:00', '13.7 18:00', '20.7 16:00']);
  });

  test('Экземпляр помнит ряд, своё место в нём и не путается ключом', () {
    final out = expandOccurrences(
      [lesson(rrule: Recurrence.weekly(interval: 1, weekdays: {1}))],
      from: DateTime(2026, 7, 6),
      to: DateTime(2026, 7, 21),
    );

    expect(out.map((e) => e.id).toSet(), hasLength(3),
        reason: 'Три карточки в списке — три разных ключа');
    expect(out.every((e) => e.recurrenceId == 'e-eng'), isTrue);
    expect(out.first.originalStart, DateTime(2026, 7, 6, 16));
  });
}
