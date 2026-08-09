import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/domain/ics.dart';

import 'sqlite_for_tests.dart';

/// Повторная загрузка того же файла.
///
/// Загрузка раздавала каждому событию новый ключ, поэтому второй заход по тем
/// же двенадцати файлам расписания удваивал календарь. Это же и закрывало
/// единственный путь починки: события, разобранные старым кодом, лежали в
/// базе с чужим концом, а перезалить файл значило получить двойников.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
  });

  tearDown(() => db.close());

  /// Запись из настоящей выгрузки: праздник на один день, конец в формате
  /// исключающий.
  const holidays = 'BEGIN:VCALENDAR\r\n'
      'VERSION:2.0\r\n'
      'X-WR-CALNAME:Праздники\r\n'
      'BEGIN:VEVENT\r\n'
      'UID:ee60cae7-20f5-534c-800a-a153a3a25e71@veha\r\n'
      'SUMMARY:Парад планет\r\n'
      'DTSTART;VALUE=DATE:20260812\r\n'
      'DTEND;VALUE=DATE:20260813\r\n'
      'TRANSP:OPAQUE\r\n'
      'END:VEVENT\r\n'
      'END:VCALENDAR\r\n';

  Future<void> makeCalendar() => repo.upsertCalendar(const VCalendar(
        id: 'hol',
        name: 'Праздники',
        iconName: 'calendar',
        color: Color(0xFF41CCB5),
      ));

  Future<List<Event>> rows() => db.select(db.events).get();

  test('Тот же файл вторым заходом не плодит двойников', () async {
    await makeCalendar();
    await repo.importEvents(parseIcs(holidays).events, calendarId: 'hol');
    await repo.importEvents(parseIcs(holidays).events, calendarId: 'hol');

    expect((await rows()).length, 1);
  });

  test('Повторная загрузка чинит конец, испорченный старым разбором',
      () async {
    await makeCalendar();
    // Так событие легло в базу до починки: конец на сутки дальше, и праздник
    // занимал в календаре две клетки вместо одной.
    await repo.upsertEvent(VEvent(
      id: 'old',
      calendarId: 'hol',
      title: 'Парад планет',
      start: DateTime(2026, 8, 12),
      end: DateTime(2026, 8, 13),
      isAllDay: true,
    ));

    await repo.importEvents(parseIcs(holidays).events, calendarId: 'hol');

    final all = await rows();
    expect(all.length, 1, reason: 'Событие то же самое, а не второе такое же');
    expect(
      DateTime.fromMillisecondsSinceEpoch(all.single.end),
      DateTime(2026, 8, 12),
      reason: 'Конец переписан разбором нового кода',
    );
  });

  test('Событие с тем же названием в другое время остаётся своим', () async {
    await makeCalendar();
    await repo.importEvents(parseIcs(holidays).events, calendarId: 'hol');
    await repo.importEvents(
      parseIcs(holidays.replaceAll('20260812', '20270812'))
          .events,
      calendarId: 'hol',
    );

    expect((await rows()).length, 2);
  });
}
