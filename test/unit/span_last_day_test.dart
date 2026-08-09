import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';

/// Последний день полосы.
///
/// Google выгружает суточное событие не датой, а временем: с полуночи 26-го до
/// полуночи 27-го. В 27-м оно не длится ни минуты, но полоса в месяце красила
/// клетку по дате конца и захватывала лишний день — ровно то же двухдневное
/// пятно, что и у праздника с испорченным концом, только причина другая.
///
/// У события на весь день конец — последний занятый день, а не полночь после
/// него: там вычитать нечего.
void main() {
  VEvent midnightToMidnight() => VEvent(
        id: 'birthday',
        calendarId: 'family',
        title: 'Богдан Цавц — день рождения',
        start: DateTime(2024, 8, 26),
        end: DateTime(2024, 8, 27),
      );

  test('Сутки от полуночи до полуночи занимают один день', () {
    expect(midnightToMidnight().lastDay, DateTime(2024, 8, 26));
  });

  test('Курс до четырнадцатого кончается четырнадцатого', () {
    final course = VEvent(
      id: 'course',
      calendarId: 'study',
      title: 'Летний курс',
      start: DateTime(2026, 6, 20),
      end: DateTime(2026, 8, 14),
      isAllDay: true,
    );
    expect(course.lastDay, DateTime(2026, 8, 14));
  });

  test('Праздник на один день кончается в свой же день', () {
    final holiday = VEvent(
      id: 'parade',
      calendarId: 'hol',
      title: 'Парад планет',
      start: DateTime(2026, 8, 12),
      end: DateTime(2026, 8, 12),
      isAllDay: true,
    );
    expect(holiday.lastDay, DateTime(2026, 8, 12));
  });

  test('Ночная смена кончается утром следующего дня', () {
    final shift = VEvent(
      id: 'shift',
      calendarId: 'work',
      title: 'Смена',
      start: DateTime(2026, 8, 12, 22),
      end: DateTime(2026, 8, 13, 6),
    );
    expect(shift.lastDay, DateTime(2026, 8, 13));
  });
}
