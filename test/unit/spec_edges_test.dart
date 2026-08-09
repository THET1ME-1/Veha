import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:veha/core/app_timezone.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/recurrence.dart';

import 'sqlite_for_tests.dart';

/// Граничные случаи, названные в ТЗ поимённо.
///
/// Раздел «что проверяем тестами» перечисляет их не для полноты: каждый —
/// место, где календари ломаются тихо. Событие в ночь перевода часов, переезд
/// в другой пояс, событие через границу года.
void main() {
  setUpAll(() {
    useSystemSqlite();
    tzdata.initializeTimeZones();
  });

  group('Перевод часов', () {
    test('Занятие в 02:30 переживает ночь, когда этого часа не существует', () {
      // В Кишинёве 29 марта 2026 стрелки прыгают с 03:00 на 04:00 — 02:30
      // существует, а вот 03:30 нет. Берём ряд на 03:30 и смотрим, что
      // движок не потерял день и не выдал вчерашний вечер.
      final dates = Recurrence.expand(
        rrule: 'FREQ=DAILY',
        start: DateTime(2026, 3, 28, 3, 30),
        windowStart: DateTime(2026, 3, 28),
        windowEnd: DateTime(2026, 3, 31),
        timezone: 'Europe/Chisinau',
      ).toList();

      expect(dates.map((d) => '${d.day}'), ['28', '29', '30']);
      // Занятие остаётся утренним, а не уезжает в ночь предыдущего дня.
      for (final d in dates) {
        expect(d.hour, greaterThanOrEqualTo(3));
        expect(d.hour, lessThan(5));
      }
    });

    test('Одно настенное время даёт разный UTC до и после перевода', () {
      final winter = tz.TZDateTime(
          tz.getLocation('Europe/Chisinau'), 2026, 1, 15, 10);
      final summer = tz.TZDateTime(
          tz.getLocation('Europe/Chisinau'), 2026, 7, 15, 10);

      expect(winter.timeZoneOffset, isNot(summer.timeZoneOffset),
          reason: 'без разницы смещений проверять нечего');
    });
  });

  group('Смена пояса устройства', () {
    tearDown(() => AppTimezone.set('UTC'));

    test('Новое событие берёт пояс устройства, а старое остаётся при своём',
        () async {
      final db = VehaDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      addTearDown(db.close);
      final repo = VehaRepository(db);
      await repo.ensureFirstCalendar(
          words: SeedWords.of('ru'), id: 'default');

      AppTimezone.set('Europe/Chisinau');
      await repo.upsertEvent(VEvent(
        id: 'дома',
        calendarId: 'default',
        title: 'Занятие дома',
        start: DateTime(2026, 7, 27, 10),
        end: DateTime(2026, 7, 27, 11),
      ));

      // Человек улетел: устройство сменило пояс.
      AppTimezone.set('Asia/Tokyo');
      await repo.upsertEvent(VEvent(
        id: 'в поездке',
        calendarId: 'default',
        title: 'Встреча в поездке',
        start: DateTime(2026, 7, 28, 10),
        end: DateTime(2026, 7, 28, 11),
      ));

      final events = await repo
          .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 29))
          .first;
      final home = events.firstWhere((e) => e.id == 'дома');
      final away = events.firstWhere((e) => e.id == 'в поездке');

      expect(home.timezone, 'Europe/Chisinau',
          reason: 'переезд не должен переписывать пояс прошлых событий');
      expect(away.timezone, 'Asia/Tokyo');
    });
  });

  group('Многодневные', () {
    VEvent span(DateTime from, DateTime to) => VEvent(
          id: 'отпуск',
          calendarId: 'default',
          title: 'Отпуск',
          start: from,
          end: to,
        );

    test('Событие через границу года остаётся одним событием', () async {
      final db = VehaDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      addTearDown(db.close);
      final repo = VehaRepository(db);
      await repo.ensureFirstCalendar(
          words: SeedWords.of('ru'), id: 'default');

      await repo.upsertEvent(
          span(DateTime(2026, 12, 28), DateTime(2027, 1, 8)));

      // Видно и в декабре, и в январе — одной записью, а не двумя обрубками.
      final december = await repo
          .watchRange(DateTime(2026, 12, 1), DateTime(2027, 1, 1))
          .first;
      final january = await repo
          .watchRange(DateTime(2027, 1, 1), DateTime(2027, 2, 1))
          .first;

      expect(december.where((e) => e.id == 'отпуск'), hasLength(1));
      expect(january.where((e) => e.id == 'отпуск'), hasLength(1));
      expect(december.single.isSpan, isTrue);
    });
  });
}
