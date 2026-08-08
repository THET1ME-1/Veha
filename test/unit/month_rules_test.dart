import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/recurrence.dart';
import 'package:veha/features/repeat/repeat_rule.dart';

/// Правила месяца из ТЗ: по числу, по позиции («второй вторник»), последний
/// рабочий день. Ряд занятий и оплата аренды описываются только ими, а
/// ошибиться здесь легко на границах месяца — потому даты проверяются на
/// три месяца вперёд, включая переход через год.
void main() {
  List<DateTime> dates(RepeatRule rule, DateTime from, {int months = 3}) =>
      Recurrence.expand(
        rrule: rule.toRrule(from)!,
        start: from,
        windowStart: from,
        windowEnd: DateTime(from.year, from.month + months + 1, 1),
      ).toList();

  test('По числу: 27-е каждого месяца', () {
    final from = DateTime(2026, 7, 27, 10);
    final rule = const RepeatRule(
      unit: RepeatUnit.month,
      monthRule: MonthRule.byDate,
    );

    expect(dates(rule, from).take(3).map((d) => '${d.day}.${d.month}'),
        ['27.7', '27.8', '27.9']);
  });

  test('По позиции: второй вторник месяца', () {
    // 14 июля 2026 — вторник и второй в месяце.
    final from = DateTime(2026, 7, 14, 16);
    final rule = const RepeatRule(
      unit: RepeatUnit.month,
      monthRule: MonthRule.byWeekday,
    );

    expect(dates(rule, from).take(3).map((d) => '${d.day}.${d.month}'),
        ['14.7', '11.8', '8.9']);
  });

  test('По позиции: последняя пятница месяца', () {
    // 31 июля 2026 — пятница и последняя в месяце: позиция считается с конца,
    // иначе «пятая пятница» пропустит месяцы, где её нет.
    final from = DateTime(2026, 7, 31, 18);
    final rule = const RepeatRule(
      unit: RepeatUnit.month,
      monthRule: MonthRule.byWeekday,
    );

    expect(dates(rule, from).take(3).map((d) => '${d.day}.${d.month}'),
        ['31.7', '28.8', '25.9']);
  });

  test('Последний рабочий день месяца', () {
    final from = DateTime(2026, 7, 31, 12);
    final rule = const RepeatRule(
      unit: RepeatUnit.month,
      monthRule: MonthRule.lastWorkday,
    );

    // Август кончается понедельником, сентябрь — средой: выходные пропущены.
    expect(dates(rule, from).take(3).map((d) => '${d.day}.${d.month}'),
        ['31.7', '31.8', '30.9']);
  });

  test('Правило читается обратно тем же, чем записано', () {
    final from = DateTime(2026, 7, 14, 16);
    for (final kind in MonthRule.values) {
      final rule = RepeatRule(unit: RepeatUnit.month, monthRule: kind);
      final back = RepeatRule.parse(rule.toRrule(from), from);
      expect(back.monthRule, kind, reason: 'правило $kind не пережило запись');
      expect(back.unit, RepeatUnit.month);
    }
  });
}
