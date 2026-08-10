import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/ics.dart';
import 'package:veha/domain/occurrences.dart';

/// Отменённое занятие в файле — это `EXDATE` у ряда.
///
/// Google так помечает пару, которой не было: неделя аттестаций, каникулы,
/// перенос. Разбор их не читал, и приложение рисовало занятия там, где их
/// отменили — расписание расходилось с настоящим на целую неделю.
void main() {
  const file = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Google Inc//Google Calendar 70.9054//EN
BEGIN:VEVENT
DTSTART;TZID=Europe/Chisinau:20260204T094500
DTEND;TZID=Europe/Chisinau:20260204T111500
RRULE:FREQ=WEEKLY;WKST=MO;UNTIL=20260527T205959Z;BYDAY=WE
EXDATE;TZID=Europe/Chisinau:20260218T094500,20260422T094500
EXDATE;TZID=Europe/Chisinau:20260429T094500
UID:backend@google.com
SUMMARY:Backend
END:VEVENT
END:VCALENDAR
''';

  test('EXDATE разбирается в исключения ряда', () {
    final data = parseIcs(file, untitled: 'Без названия');
    final event = data.events.single;

    expect(data.excluded[event.id], hasLength(3));
    expect(
      data.excluded[event.id],
      contains(DateTime(2026, 4, 22, 9, 45)),
    );
  });

  test('Развёртка пропускает отменённое занятие', () {
    final data = parseIcs(file, untitled: 'Без названия');
    final event = data.events.single;

    final days = expandOccurrences(
      [event],
      from: DateTime(2026, 4, 20),
      to: DateTime(2026, 4, 27),
      excluded: {event.id: data.excluded[event.id]!},
    );

    expect(days, isEmpty);
  });

  test('Выгрузка пишет отменённые занятия обратно в файл', () {
    final data = parseIcs(file, untitled: 'Без названия');
    final event = data.events.single;

    final out = toIcs([event], excluded: data.excluded);

    expect(out, contains('EXDATE'));
    // Круг «выгрузил — загрузил» не должен терять отмены.
    final again = parseIcs(out, untitled: 'Без названия');
    expect(again.excluded[again.events.single.id], hasLength(3));
  });
}
