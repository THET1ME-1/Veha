import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:veha/domain/recurrence.dart';
import 'package:veha/features/repeat/repeat_rule.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  final monday = DateTime(2026, 7, 27, 16);

  test('Без повторения правило пустое', () {
    expect(const RepeatRule.none().toRrule(monday), isNull);
  });

  test('Каждый день', () {
    expect(
      const RepeatRule(unit: RepeatUnit.day).toRrule(monday),
      'FREQ=DAILY',
    );
  });

  test('Каждые две недели по понедельникам и четвергам', () {
    final rule = const RepeatRule(
      unit: RepeatUnit.week,
      interval: 2,
      weekdays: {1, 4},
    );

    expect(rule.toRrule(monday), 'FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH');
  });

  test('Неделя без выбранных дней берёт день самого события', () {
    const rule = RepeatRule(unit: RepeatUnit.week);
    expect(rule.toRrule(monday), 'FREQ=WEEKLY;BYDAY=MO');
  });

  test('Окончание после N повторов', () {
    const rule = RepeatRule(unit: RepeatUnit.week, count: 5);
    expect(rule.toRrule(monday), contains('COUNT=5'));
  });

  test('Окончание по дате', () {
    final rule = RepeatRule(
      unit: RepeatUnit.month,
      until: DateTime(2026, 12, 31),
    );
    expect(rule.toRrule(monday), contains('UNTIL=20261231'));
  });

  test('Правило читается обратно из строки', () {
    final rule = RepeatRule.parse('FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,TH', monday);

    expect(rule.unit, RepeatUnit.week);
    expect(rule.interval, 2);
    expect(rule.weekdays, {1, 4});
  });

  test('Собранное правило разворачивается движком повторений', () {
    final rrule = const RepeatRule(
      unit: RepeatUnit.week,
      interval: 1,
      weekdays: {1, 4},
      count: 4,
    ).toRrule(monday)!;

    final dates = Recurrence.expand(
      rrule: rrule,
      start: monday,
      windowStart: monday,
      windowEnd: DateTime(2026, 9, 1),
    );

    expect(dates, hasLength(4));
    expect(dates.first, DateTime(2026, 7, 27, 16));
    expect(dates.last, DateTime(2026, 8, 6, 16));
  });
}
