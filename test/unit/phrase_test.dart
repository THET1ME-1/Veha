import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/phrase.dart';

/// Разбор фразы. Всё, что не разобралось, обязано остаться названием: хуже
/// непонятой строки только строка, понятая неправильно.
void main() {
  // Понедельник, 27 июля 2026, 09:41.
  final now = DateTime(2026, 7, 27, 9, 41);

  test('«Созвон завтра в 15:00 на час»', () {
    final p = parsePhrase('Созвон завтра в 15:00 на час', now: now);

    expect(p.title, 'Созвон');
    expect(p.start, DateTime(2026, 7, 28, 15));
    expect(p.duration, const Duration(hours: 1));
    expect(p.hasTime, isTrue);
  });

  test('«Обед в 13»', () {
    final p = parsePhrase('Обед в 13', now: now);
    expect(p.title, 'Обед');
    expect(p.start, DateTime(2026, 7, 27, 13));
  });

  test('«Английский в пятницу в 16:30 на 90 минут»', () {
    final p = parsePhrase('Английский в пятницу в 16:30 на 90 минут', now: now);

    expect(p.title, 'Английский');
    expect(p.start, DateTime(2026, 7, 31, 16, 30));
    expect(p.duration, const Duration(minutes: 90));
  });

  test('«Зубной через два дня»', () {
    final p = parsePhrase('Зубной через два дня', now: now);
    expect(p.title, 'Зубной');
    expect(p.start.day, 29);
    // Времени не назвали: не полночь, а рабочее утро.
    expect(p.start.hour, 9);
    expect(p.hasTime, isFalse);
  });

  test('«Отпуск через неделю»', () {
    final p = parsePhrase('Отпуск через неделю', now: now);
    expect(p.start.day, 3);
    expect(p.start.month, 8);
  });

  test('День недели, названный в тот же день, означает следующий', () {
    final p = parsePhrase('Планёрка в понедельник', now: now);
    expect(p.start.day, 3, reason: 'Не сегодня, а через неделю');
  });

  test('Предлог «на» в названии не съедается', () {
    final p = parsePhrase('Встреча на кафедре завтра', now: now);
    expect(p.title, 'Встреча на кафедре');
    expect(p.start.day, 28);
  });

  test('Ничего не разобралось — всё осталось названием', () {
    final p = parsePhrase('Купить лампу', now: now);
    expect(p.title, 'Купить лампу');
    expect(p.duration, const Duration(hours: 1));
    // Сегодня, ближайший круглый час впереди.
    expect(p.start, DateTime(2026, 7, 27, 10));
  });

  test('Английская фраза разбирается тем же кодом', () {
    final p = parsePhrase('Standup tomorrow at 10:15', now: now);
    expect(p.title, 'Standup');
    expect(p.start, DateTime(2026, 7, 28, 10, 15));
  });

  test('Немецкая фраза: «Zahnarzt morgen um 9»', () {
    final p = parsePhrase('Zahnarzt morgen um 9', now: now);
    expect(p.title, 'Zahnarzt');
    expect(p.start, DateTime(2026, 7, 28, 9));
  });

  test('«Полчаса» понимается как длительность', () {
    final p = parsePhrase('Прогулка сегодня в 18 на полчаса', now: now);
    expect(p.duration, const Duration(minutes: 30));
    expect(p.start, DateTime(2026, 7, 27, 18));
  });
}
