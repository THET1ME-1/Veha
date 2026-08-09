import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/ics.dart';

/// Обмен с чужими календарями. Формат придирчив: переносы строк, экранирование
/// и часовой пояс ломаются тихо, а замечают это уже на чужом устройстве.
void main() {
  VEvent event({
    String id = 'e1',
    String title = 'Английский',
    DateTime? start,
    DateTime? end,
    String? rrule,
    String? location,
    bool isAllDay = false,
    List<VFieldValue> fields = const [],
  }) =>
      VEvent(
        id: id,
        calendarId: 'c-study',
        title: title,
        start: start ?? DateTime(2026, 7, 27, 16),
        end: end ?? DateTime(2026, 7, 27, 17),
        rrule: rrule,
        location: location,
        isAllDay: isAllDay,
        timezone: 'Europe/Chisinau',
        fields: fields,
      );

  group('Выгрузка', () {
    test('Обязательный каркас на месте', () {
      final ics = toIcs([event()]);

      expect(ics, startsWith('BEGIN:VCALENDAR\r\n'));
      expect(ics, endsWith('END:VCALENDAR\r\n'));
      expect(ics, contains('VERSION:2.0'));
      expect(ics, contains('BEGIN:VEVENT'));
      expect(ics, contains('SUMMARY:Английский'));
    });

    test('Время уходит со своим поясом, а не в UTC', () {
      final ics = toIcs([event()]);

      expect(ics, contains('DTSTART;TZID=Europe/Chisinau:20260727T160000'));
      expect(ics, contains('DTEND;TZID=Europe/Chisinau:20260727T170000'));
    });

    test('Событие на весь день уходит датой без времени', () {
      // Внутри приложения конец — последний день события, в формате он
      // исключающий: занятый один день 27 июля уезжает как 27 → 28.
      final ics = toIcs([
        event(
          start: DateTime(2026, 7, 27),
          end: DateTime(2026, 7, 27),
          isAllDay: true,
        )
      ]);

      expect(ics, contains('DTSTART;VALUE=DATE:20260727'));
      expect(ics, contains('DTEND;VALUE=DATE:20260728'));
    });

    test('Запятые и переводы строк экранируются', () {
      final ics = toIcs([event(title: 'Обед, потом\nкино')]);
      expect(ics, contains(r'SUMMARY:Обед\, потом\nкино'));
    });

    test('Длинная строка складывается по 75 октетов', () {
      final ics = toIcs([event(title: 'я' * 200)]);

      for (final line in ics.split('\r\n')) {
        expect(line.codeUnits.length, lessThanOrEqualTo(75),
            reason: 'Строка длиннее 75 октетов ломает чужие разборщики');
      }
      // Продолжение начинается с пробела — по нему разборщик и склеивает.
      expect(ics, contains('\r\n '));
    });

    test('Свои поля уходят своими свойствами', () {
      final ics = toIcs([
        event(fields: const [VFieldValue(fieldId: 'f-room', value: '312')])
      ]);

      expect(ics, contains('X-VEHA-FIELD;X-VEHA-ID=f-room:312'));
    });

    test('Правило повторения уходит как есть', () {
      final ics = toIcs([event(rrule: 'FREQ=WEEKLY;BYDAY=MO,TH')]);
      expect(ics, contains('RRULE:FREQ=WEEKLY;BYDAY=MO,TH'));
    });
  });

  group('Разбор', () {
    test('Своя же выгрузка читается обратно без потерь', () {
      final source = event(
        rrule: 'FREQ=WEEKLY;BYDAY=MO,TH',
        location: 'Языковой центр, дом 45',
        fields: const [VFieldValue(fieldId: 'f-room', value: '312')],
      );

      final back = parseIcs(toIcs([source])).events.single;

      expect(back.title, source.title);
      expect(back.start, source.start);
      expect(back.end, source.end);
      expect(back.rrule, source.rrule);
      expect(back.location, source.location);
      expect(back.timezone, source.timezone);
      expect(back.fields.single.fieldId, 'f-room');
      expect(back.fields.single.value, '312');
    });

    test('Имя календаря из файла достаётся разбором', () {
      // Файлы Google, Proton и наша же выгрузка подписывают календарь
      // `X-WR-CALNAME`. Спрашивать человека, куда класть «Учёбу», когда это
      // написано в первой строке файла, незачем.
      const source = 'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'X-WR-CALNAME:Учёба\r\n'
          'BEGIN:VEVENT\r\n'
          'UID:1@veha\r\n'
          'SUMMARY:Линейка\r\n'
          'DTSTART;TZID=Europe/Chisinau:20260901T083000\r\n'
          'DTEND;TZID=Europe/Chisinau:20260901T120000\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n';

      final data = parseIcs(source);

      expect(data.calendarName, 'Учёба');
      expect(data.events.single.title, 'Линейка');
    });

    test('Файл без подписи календаря имени не выдумывает', () {
      final data = parseIcs(toIcs([event()]));
      expect(data.calendarName, isNull);
    });

    test('Длинное название склеивается обратно', () {
      final source = event(title: 'я' * 200);
      expect(parseIcs(toIcs([source])).events.single.title, 'я' * 200);
    });

    test('Событие на весь день читается датой', () {
      final source = event(
        start: DateTime(2026, 7, 27),
        end: DateTime(2026, 7, 27),
        isAllDay: true,
      );
      final back = parseIcs(toIcs([source])).events.single;

      expect(back.isAllDay, isTrue);
      expect(back.start, DateTime(2026, 7, 27));
      expect(back.end, DateTime(2026, 7, 27));
    });

    test('Чужой однодневный праздник занимает один день', () {
      // Google и Apple пишут однодневный праздник как 13 → 14 августа:
      // конец в формате исключающий. Читая его как есть, приложение рисовало
      // полосу на две клетки — «День левши» висел и над 13-м, и над 14-м.
      const source = 'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'BEGIN:VEVENT\r\n'
          'UID:holiday@google\r\n'
          'SUMMARY:День левши\r\n'
          'DTSTART;VALUE=DATE:20260813\r\n'
          'DTEND;VALUE=DATE:20260814\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n';

      final back = parseIcs(source).events.single;

      expect(back.isAllDay, isTrue);
      expect(back.start, DateTime(2026, 8, 13));
      expect(back.end, DateTime(2026, 8, 13));
      // Один день, но всё равно полоса: часа у праздника нет.
      expect(back.isSpan, isTrue);
    });

    test('Чужой многодневный отпуск теряет лишний день', () {
      const source = 'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'BEGIN:VEVENT\r\n'
          'UID:trip@google\r\n'
          'SUMMARY:Море\r\n'
          'DTSTART;VALUE=DATE:20260801\r\n'
          'DTEND;VALUE=DATE:20260810\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n';

      final back = parseIcs(source).events.single;

      expect(back.start, DateTime(2026, 8, 1));
      expect(back.end, DateTime(2026, 8, 9));
    });

    test('Чужой файл с временем в UTC читается', () {
      const ics = 'BEGIN:VCALENDAR\r\n'
          'VERSION:2.0\r\n'
          'BEGIN:VEVENT\r\n'
          'UID:foreign-1\r\n'
          'SUMMARY:Совещание\r\n'
          'DTSTART:20260727T130000Z\r\n'
          'DTEND:20260727T140000Z\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n';

      final back = parseIcs(ics).events.single;
      expect(back.title, 'Совещание');
      expect(back.start.toUtc(), DateTime.utc(2026, 7, 27, 13));
    });

    test('Событие без конца читается открытым', () {
      // По RFC 5545 отсутствие DTEND у события со временем означает нулевую
      // длительность, а не час: в приложении это «без окончания».
      const ics = 'BEGIN:VCALENDAR\r\n'
          'BEGIN:VEVENT\r\n'
          'SUMMARY:Без конца\r\n'
          'DTSTART:20260727T130000Z\r\n'
          'END:VEVENT\r\n'
          'END:VCALENDAR\r\n';

      final back = parseIcs(ics).events.single;
      expect(back.isOpenEnded, isTrue);
    });

    test('Определение своего поля восстанавливается из файла', () {
      const def = VFieldDef(
        id: 'f-room',
        name: 'Кабинет',
        type: VFieldType.number,
        iconName: 'door',
      );
      final ics = toIcs(
        [event(fields: const [VFieldValue(fieldId: 'f-room', value: '312')])],
        defs: const {'f-room': def},
      );

      final back = parseIcs(ics).fields.single;
      expect(back.id, 'f-room');
      expect(back.name, 'Кабинет');
      expect(back.type, VFieldType.number);
      expect(back.iconName, 'door');
    });

    test('Мусор вместо файла даёт пустой список, а не исключение', () {
      expect(parseIcs('это не календарь').events, isEmpty);
    });
  });
}
