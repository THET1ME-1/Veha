import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/ics.dart';

import 'sqlite_for_tests.dart';

/// Загрузка файла обязана донести отмены до базы.
///
/// Разбор `EXDATE` без этого шага бесполезен: пара, отменённая в Google,
/// снова появляется в приложении — расписание расходится с настоящим.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
  });

  tearDown(() => db.close());

  test('Отменённое занятие не появляется после загрузки файла', () async {
    const file = '''
BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
DTSTART;TZID=Europe/Chisinau:20260204T094500
DTEND;TZID=Europe/Chisinau:20260204T111500
RRULE:FREQ=WEEKLY;WKST=MO;UNTIL=20260527T205959Z;BYDAY=WE
EXDATE;TZID=Europe/Chisinau:20260422T094500
UID:backend@google.com
SUMMARY:Backend
END:VEVENT
END:VCALENDAR
''';
    final data = parseIcs(file, untitled: 'Без названия');

    await repo.importEvents(
      data.events,
      calendarId: 'default',
      fields: data.fields,
      excluded: data.excluded,
    );

    final cancelled = await repo.eventsBetween(
      DateTime(2026, 4, 22),
      DateTime(2026, 4, 23),
    );
    expect(cancelled.where((e) => e.title == 'Backend'), isEmpty);

    // Соседняя среда занятие сохраняет: отмена — точечная, а не обрыв ряда.
    final alive = await repo.eventsBetween(
      DateTime(2026, 4, 15),
      DateTime(2026, 4, 16),
    );
    expect(alive.where((e) => e.title == 'Backend'), hasLength(1));
  });
}
