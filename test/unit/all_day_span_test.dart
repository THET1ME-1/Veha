import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/free_time.dart';

/// Событие на весь день — всегда полоса, даже если день один.
///
/// Полосой считалось только то, что длиннее суток, и однодневный праздник
/// попадал в дневной список наравне со встречами: блок в полночь высотой в
/// сорок точек. Пока конец праздника ошибочно стоял на сутки дальше, это не
/// было видно — событие проходило по длительности.
void main() {
  VEvent holiday({DateTime? end}) => VEvent(
        id: 'holiday',
        calendarId: 'hol',
        title: 'Парад планет',
        start: DateTime(2026, 8, 12),
        end: end ?? DateTime(2026, 8, 12),
        isAllDay: true,
      );

  test('Праздник на один день — полоса', () {
    expect(holiday().isSpan, isTrue);
  });

  test('Праздник длиной в неделю — тоже полоса', () {
    expect(holiday(end: DateTime(2026, 8, 19)).isSpan, isTrue);
  });

  test('Встреча на полтора часа полосой не считается', () {
    final meeting = VEvent(
      id: 'call',
      calendarId: 'work',
      title: 'Созвон',
      start: DateTime(2026, 8, 12, 10),
      end: DateTime(2026, 8, 12, 11, 30),
    );
    expect(meeting.isSpan, isFalse);
  });

  test('Праздник не отъедает свободное время дня', () {
    final slots = freeSlots(
      [holiday()],
      DateTime(2026, 8, 12),
      atLeast: const Duration(minutes: 30),
      bounds: const DayBounds(from: 9, to: 18),
    );

    expect(slots, hasLength(1));
    expect(slots.single.start, DateTime(2026, 8, 12, 9));
    expect(slots.single.end, DateTime(2026, 8, 12, 18));
  });
}
