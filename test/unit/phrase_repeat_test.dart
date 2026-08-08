import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/phrase.dart';
import 'package:veha/domain/recurrence.dart';

/// Правило повтора обычным текстом.
///
/// ТЗ обещает строку, которая принимает «каждую последнюю пятницу месяца» и
/// раскладывает её в правило. Разбор дат в приложении был, повторов — нет:
/// человек писал «каждый вторник», получал одно занятие во вторник и узнавал
/// об этом через неделю.
void main() {
  final now = DateTime(2026, 7, 27, 9, 41); // понедельник

  /// Даты, которые даёт разобранное правило.
  List<String> dates(Phrase p, {int take = 3}) => Recurrence.expand(
        rrule: p.rrule!,
        start: p.start,
        windowStart: p.start,
        windowEnd: p.start.add(const Duration(days: 400)),
      ).take(take).map((d) => '${d.day}.${d.month}').toList();

  test('«каждый день» даёт ежедневный ряд', () {
    final p = parsePhrase('зарядка каждый день в 7:30', now: now);

    expect(p.title, 'зарядка');
    expect(p.rrule, contains('FREQ=DAILY'));
    expect(p.start.hour, 7);
  });

  test('«по будням» даёт пять дней недели', () {
    final p = parsePhrase('планёрка по будням в 10:00', now: now);

    expect(p.rrule, contains('BYDAY=MO,TU,WE,TH,FR'));
    expect(p.title, 'планёрка');
  });

  test('«каждый вторник» ставит событие на вторник и повторяет еженедельно',
      () {
    final p = parsePhrase('английский каждый вторник в 16:00', now: now);

    expect(p.rrule, contains('FREQ=WEEKLY'));
    expect(p.rrule, contains('BYDAY=TU'));
    // Ближайший вторник, а не сегодняшний понедельник.
    expect(p.start.day, 28);
    expect(dates(p), ['28.7', '4.8', '11.8']);
  });

  test('«каждые 2 недели» переживают шаг', () {
    final p = parsePhrase('созвон каждые 2 недели', now: now);

    expect(p.rrule, contains('INTERVAL=2'));
    expect(dates(p), ['27.7', '10.8', '24.8']);
  });

  test('«каждый месяц» повторяет числом', () {
    final p = parsePhrase('аренда каждый месяц', now: now);

    expect(p.rrule, contains('FREQ=MONTHLY'));
    expect(dates(p), ['27.7', '27.8', '27.9']);
  });

  test('«каждую последнюю пятницу месяца» считает позицию с конца', () {
    final p = parsePhrase('отчёт каждую последнюю пятницу месяца', now: now);

    expect(p.rrule, contains('FREQ=MONTHLY'));
    expect(p.rrule, contains('BYDAY=-1FR'));
    expect(dates(p), ['31.7', '28.8', '25.9']);
  });

  test('Слова правила уходят из названия', () {
    final p = parsePhrase('бассейн каждый вторник и четверг в 19:00', now: now);

    expect(p.title, 'бассейн');
    expect(p.rrule, contains('BYDAY=TU,TH'));
  });

  test('Без слов о повторе правила нет', () {
    final p = parsePhrase('обед с Ниной завтра в 13:00', now: now);

    expect(p.rrule, isNull);
    expect(p.title, 'обед с Ниной');
  });
}
