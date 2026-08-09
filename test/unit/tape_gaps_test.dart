import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/free_time.dart';

/// Окна ленты дня считаются по всему, что в ней нарисовано.
///
/// Google помечает отдых и игры `TRANSP:TRANSPARENT`, у нас это
/// «свободен» — такое событие часов не держит, и подсказка «когда я свободен»
/// правильно делает, что его пропускает. Но лента рисует его блоком, и окно,
/// посчитанное мимо него, легло поверх: между занятиями в пятнадцать минут
/// стояло «2 ч 15 мин свободно», а красная риска «сейчас» рисовалась дважды —
/// момент попадал и в окно, и в блок.
void main() {
  final day = DateTime(2026, 8, 9);

  VEvent walk() => VEvent(
        id: 'walk',
        calendarId: 'life',
        title: 'Прогулка',
        start: DateTime(2026, 8, 9, 18),
        end: DateTime(2026, 8, 9, 21, 45),
      );

  VEvent rest() => VEvent(
        id: 'rest',
        calendarId: 'life',
        title: 'Отдых',
        start: DateTime(2026, 8, 9, 22),
        end: DateTime(2026, 8, 9, 23, 30),
        availability: Availability.free,
      );

  test('Отметка «свободен» держит место в ленте', () {
    final slots = freeSlots(
      [walk(), rest()],
      day,
      atLeast: const Duration(minutes: 10),
      bounds: const DayBounds(from: 0, to: 24),
      marksOccupyTime: true,
    );

    expect(
      slots.map((s) => '${s.start.hour}:${s.start.minute}–${s.end.hour}:${s.end.minute}'),
      ['0:0–18:0', '21:45–22:0', '23:30–0:0'],
    );
  });

  test('Подсказке «когда я свободен» отметка по-прежнему не мешает', () {
    final slots = freeSlots(
      [walk(), rest()],
      day,
      atLeast: const Duration(minutes: 10),
      bounds: const DayBounds(from: 0, to: 24),
    );

    expect(slots.last.start, DateTime(2026, 8, 9, 21, 45));
    expect(slots.last.end, DateTime(2026, 8, 10));
  });
}
