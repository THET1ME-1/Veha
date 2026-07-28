import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/repeat/repeat_screen.dart';

void main() {
  group('nextDates', () {
    test('Каждые 2 недели по понедельникам и четвергам', () {
      // Отсчёт от понедельника 27 июля 2026: сама эта неделя считается тактом.
      final dates = nextDates(DateTime(2026, 7, 27), 2, {1, 4}, 5);
      expect(dates.map((d) => '${d.day}.${d.month}').toList(), [
        '30.7',
        '10.8',
        '13.8',
        '24.8',
        '27.8',
      ]);
    });

    test('Каждую неделю по средам', () {
      final dates = nextDates(DateTime(2026, 7, 27), 1, {3}, 3);
      expect(dates.map((d) => d.day).toList(), [29, 5, 12]);
    });

    test('Без выбранных дней правило пустое', () {
      expect(nextDates(DateTime(2026, 7, 27), 2, {}, 5), isEmpty);
    });
  });
}
