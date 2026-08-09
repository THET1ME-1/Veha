import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/ics.dart';

/// Файлы из чужих календарей.
///
/// ТЗ называет три источника поимённо: Google, Apple и Etar. Каждый пишет
/// по-своему — свои переносы строк, свои параметры, свои расширения, — и
/// импорт, проверенный только на своих же выгрузках, ломается на первом
/// настоящем файле.
void main() {
  /// Google складывает даты в UTC с суффиксом Z, длинные строки переносит с
  /// одним пробелом в начале продолжения и вставляет свой блок VTIMEZONE.
  const google = '''
BEGIN:VCALENDAR
PRODID:-//Google Inc//Google Calendar 70.9054//EN
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:PUBLISH
BEGIN:VTIMEZONE
TZID:Europe/Chisinau
BEGIN:STANDARD
TZOFFSETFROM:+0300
TZOFFSETTO:+0200
TZNAME:EET
DTSTART:19701025T040000
END:STANDARD
END:VTIMEZONE
BEGIN:VEVENT
DTSTART:20260727T070000Z
DTEND:20260727T083000Z
DTSTAMP:20260720T101500Z
UID:4kj2h3g4@google.com
CREATED:20260701T120000Z
DESCRIPTION:Повестка\\, отчёт и планы. Ссылка на встречу: https://meet.googl
 e.com/abc-defg-hij
LAST-MODIFIED:20260701T120000Z
LOCATION:Кишинёв\\, ул. Штефан чел Маре 1
SEQUENCE:0
STATUS:CONFIRMED
SUMMARY:Планёрка отдела
TRANSP:OPAQUE
END:VEVENT
END:VCALENDAR
''';

  /// Apple пишет DTSTART с указанием пояса, всегда добавляет X-APPLE-свойства
  /// и разбивает строки по 75 октетов.
  const apple = '''
BEGIN:VCALENDAR
CALSCALE:GREGORIAN
PRODID:-//Apple Inc.//macOS 15.4//EN
VERSION:2.0
BEGIN:VEVENT
CREATED:20260701T090000Z
UID:0F6A1B2C-3D4E-5F60-A1B2-C3D4E5F60718
DTEND;TZID=Europe/Chisinau:20260727T190000
TRANSP:TRANSPARENT
X-APPLE-TRAVEL-ADVISORY-BEHAVIOR:AUTOMATIC
SUMMARY:День рождения Нины
DTSTART;TZID=Europe/Chisinau:20260727T180000
DTSTAMP:20260701T090000Z
SEQUENCE:0
END:VEVENT
END:VCALENDAR
''';

  /// Etar выгружает события на весь день значением DATE и не пишет ни пояса,
  /// ни лишних свойств.
  const etar = '''
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Etar//Etar Calendar//EN
BEGIN:VEVENT
DTSTART;VALUE=DATE:20260801
DTEND;VALUE=DATE:20260809
SUMMARY:Отпуск
UID:etar-1754000000000
RRULE:FREQ=YEARLY
END:VEVENT
END:VCALENDAR
''';

  test('Google: время, описание с переносом строки и место', () {
    final e = parseIcs(google).events.single;

    expect(e.title, 'Планёрка отдела');
    expect(e.location, 'Кишинёв, ул. Штефан чел Маре 1');
    // Перенос строки в файле не должен разрывать ссылку.
    expect(e.description, contains('https://meet.google.com/abc-defg-hij'));
    expect(e.availability, Availability.busy);
    expect(e.start.toUtc().hour, 7);
    expect(e.end.toUtc().hour, 8);
  });

  test('Apple: пояс в параметре и «не занимает время»', () {
    final e = parseIcs(apple).events.single;

    expect(e.title, 'День рождения Нины');
    expect(e.timezone, 'Europe/Chisinau');
    expect(e.availability, Availability.free,
        reason: 'TRANSPARENT означает отметку, а не занятость');
  });

  test('Etar: событие на весь день и годовой повтор', () {
    final e = parseIcs(etar).events.single;

    expect(e.title, 'Отпуск');
    expect(e.isAllDay, isTrue);
    expect(e.rrule, 'FREQ=YEARLY');
    expect(e.start.day, 1);
    // DTEND в формате исключающий: отпуск занимает по восьмое включительно.
    expect(e.end.day, 8);
    expect(e.isMultiDay, isTrue);
  });

  test('Свои поля переживают круг через файл', () {
    final defs = {
      'f-room': const VFieldDef(
        id: 'f-room',
        name: 'Кабинет',
        type: VFieldType.text,
        iconName: 'door',
      ),
    };
    final source = VEvent(
      id: 'e1',
      calendarId: 'c1',
      title: 'Английский',
      start: DateTime(2026, 7, 27, 16),
      end: DateTime(2026, 7, 27, 17),
      fields: const [VFieldValue(fieldId: 'f-room', value: '312')],
    );

    final back = parseIcs(
      toIcs([source], defs: defs, stamp: DateTime.utc(2026, 7, 27, 9)),
    );

    expect(back.events.single.fields.single.value, '312');
    // Вместе со значением приезжает определение: «312» без подписи «Кабинет»
    // показать негде.
    expect(back.fields.single.name, 'Кабинет');
  });
}
