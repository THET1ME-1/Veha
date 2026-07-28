import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/week_layout.dart';

void main() {
  test('По умолчанию показываются все семь дней', () {
    expect(WeekLayout.full.weekdays, {1, 2, 3, 4, 5, 6, 7});
    expect(WeekLayout.full.daysOf(DateTime(2026, 7, 29)), hasLength(7));
  });

  test('Только будни отдают пять колонок с понедельника', () {
    final workweek = WeekLayout(weekdays: const {1, 2, 3, 4, 5});
    final days = workweek.daysOf(DateTime(2026, 7, 29));

    expect(days, hasLength(5));
    expect(days.first, DateTime(2026, 7, 27));
    expect(days.last, DateTime(2026, 7, 31));
  });

  test('Выбранный день всегда попадает в набор', () {
    // Человек стоит на субботе, а показываются будни — суббота обязана
    // остаться видимой, иначе выбранный день исчезает с экрана.
    final workweek = WeekLayout(weekdays: const {1, 2, 3, 4, 5});
    final days = workweek.daysOf(DateTime(2026, 8, 1));

    expect(days, contains(DateTime(2026, 8, 1)));
    expect(days, hasLength(6));
  });

  test('Неделя может начинаться с воскресенья', () {
    final sundayFirst = WeekLayout(
      weekdays: const {1, 2, 3, 4, 5, 6, 7},
      firstDay: DateTime.sunday,
    );

    expect(sundayFirst.daysOf(DateTime(2026, 7, 29)).first,
        DateTime(2026, 7, 26));
  });

  test('Пустой набор дней невозможен', () {
    expect(WeekLayout(weekdays: const {}).weekdays, isNotEmpty);
  });

  test('Настройка переживает перезапуск', () {
    final saved = WeekLayout(
      weekdays: const {2, 4, 6},
      firstDay: DateTime.sunday,
    ).encode();

    final restored = WeekLayout.decode(saved);
    expect(restored.weekdays, {2, 4, 6});
    expect(restored.firstDay, DateTime.sunday);
  });

  test('Испорченная настройка откатывается к полной неделе', () {
    expect(WeekLayout.decode('чепуха').weekdays, WeekLayout.full.weekdays);
    expect(WeekLayout.decode(null).weekdays, WeekLayout.full.weekdays);
  });
}
