import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/free_time.dart';
import 'package:veha/domain/ics.dart';

/// Событие без времени окончания: «зашёл в мастерскую», «сел писать».
///
/// Отдельного поля в схеме нет намеренно — конец, равный началу, и означает
/// «неизвестно». Иначе правка схемы тянет миграцию на клиенте и на сервере
/// ради флага, который выводится из двух дат.
void main() {
  VEvent open() => VEvent(
        id: 'open',
        calendarId: 'c',
        title: 'Мастерская',
        start: DateTime(2026, 7, 27, 14),
        end: DateTime(2026, 7, 27, 14),
      );

  VEvent lunch() => VEvent(
        id: 'lunch',
        calendarId: 'c',
        title: 'Обед',
        start: DateTime(2026, 7, 27, 13, 30),
        end: DateTime(2026, 7, 27, 14, 30),
      );

  test('Конец, равный началу, означает «без окончания»', () {
    expect(open().isOpenEnded, isTrue);
    expect(lunch().isOpenEnded, isFalse);
  });

  test('Открытое событие никого не загораживает', () {
    // Времени оно не занимает: показать «накладку» с тем, у чего нет
    // длительности, значит соврать.
    expect(conflictsOf(open(), [lunch()]), isEmpty);
    expect(conflictsOf(lunch(), [open()]), isEmpty);
  });

  test('В выгрузке у открытого события нет DTEND', () {
    final text = toIcs([open()], defs: const {});
    expect(text, contains('DTSTART'));
    expect(text, isNot(contains('DTEND')));
  });

  test('Обычное событие выгружается с DTEND', () {
    expect(toIcs([lunch()], defs: const {}), contains('DTEND'));
  });

  test('Событие без DTEND читается обратно открытым', () {
    final text = toIcs([open()], defs: const {});
    final back = parseIcs(text).events.single;
    expect(back.isOpenEnded, isTrue);
    expect(back.start, open().start);
  });
}
