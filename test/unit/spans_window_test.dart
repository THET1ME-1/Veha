import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/providers.dart';

/// Полосы длинных событий: какие из них принадлежат показанному отрезку.
///
/// Окно базы шире видимого: события подгружаются на месяц вокруг, чтобы
/// листалось без рывков. Отдавать виду всё окно нельзя — над неделей повисали
/// дни рождения из сентября, и подпись «день N из 2» уходила в минус, потому
/// что событие ещё не начиналось.
void main() {
  VEvent span(String id, DateTime start, DateTime end) => VEvent(
        id: id,
        calendarId: 'c1',
        title: id,
        start: start,
        end: end,
        isAllDay: true,
        timezone: 'Europe/Chisinau',
      );

  final data = RangeData(
    byDay: const {},
    spans: [
      span('на неделе', DateTime(2026, 8, 4), DateTime(2026, 8, 6)),
      span('раньше', DateTime(2026, 7, 20), DateTime(2026, 7, 22)),
      span('позже', DateTime(2026, 9, 13), DateTime(2026, 9, 14)),
      span('через всю неделю', DateTime(2026, 7, 30), DateTime(2026, 8, 20)),
      span('захватывает понедельник', DateTime(2026, 8, 1), DateTime(2026, 8, 4)),
      // Конец у события на весь день — последний занятый день, поэтому
      // «накануне» это второе августа, а не третье.
      span('кончился накануне', DateTime(2026, 8, 1), DateTime(2026, 8, 2)),
    ],
  );

  test('Неделя берёт только свои полосы', () {
    final shown = data.spansBetween(
      DateTime(2026, 8, 3),
      DateTime(2026, 8, 8),
    );

    expect(
      shown.map((e) => e.id).toSet(),
      {'на неделе', 'через всю неделю', 'захватывает понедельник'},
    );
  });

  test('Отрезок без полос отдаёт пусто', () {
    final shown = data.spansBetween(
      DateTime(2026, 8, 24),
      DateTime(2026, 8, 29),
    );

    expect(shown, isEmpty);
  });

  test('День остаётся частным случаем отрезка', () {
    final day = data.spansOn(DateTime(2026, 8, 5));
    final same = data.spansBetween(
      DateTime(2026, 8, 5),
      DateTime(2026, 8, 6),
    );

    expect(day.map((e) => e.id), same.map((e) => e.id));
  });
}
