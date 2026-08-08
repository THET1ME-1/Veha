import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/free_time.dart';
import 'package:veha/domain/ics.dart';

import 'sqlite_for_tests.dart';

/// Занятость события: держит ли оно время.
///
/// День рождения, напоминание о платеже и «в городе с 5 по 9» стоят в
/// календаре, но не занимают часы. Пока приложение считало занятым всё
/// подряд, свободных окон у человека с такими записями не оставалось —
/// и подсказка «ближайшее окно» отправляла встречу на послезавтра.
void main() {
  setUpAll(useSystemSqlite);

  final day = DateTime(2026, 7, 27);

  VEvent event(
    String id,
    int fromHour,
    int toHour, {
    Availability availability = Availability.busy,
  }) =>
      VEvent(
        id: id,
        calendarId: 'default',
        title: id,
        start: DateTime(2026, 7, 27, fromHour),
        end: DateTime(2026, 7, 27, toHour),
        availability: availability,
      );

  test('Событие «свободен» не режет день на куски', () {
    final slots = freeSlots(
      [event('день рождения', 10, 18, availability: Availability.free)],
      day,
    );

    expect(slots, hasLength(1));
    expect(slots.single.start.hour, 8);
    expect(slots.single.end.hour, 22);
  });

  test('Обычное событие день режет', () {
    final slots = freeSlots([event('планёрка', 10, 11)], day);

    expect(slots.map((s) => '${s.start.hour}–${s.end.hour}'), ['8–10', '11–22']);
  });

  test('Занятость доживает до базы и обратно', () async {
    final db = VehaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    addTearDown(db.close);

    final repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
    await repo.upsertEvent(
        event('e1', 10, 11, availability: Availability.free));

    final back = (await repo
            .watchRange(day, day.add(const Duration(days: 1)))
            .first)
        .single;
    expect(back.availability, Availability.free);
  });

  test('В .ics занятость едет как TRANSP и читается обратно', () {
    final text = toIcs(
      [event('e1', 10, 11, availability: Availability.free)],
      stamp: DateTime.utc(2026, 7, 27, 9),
    );
    expect(text, contains('TRANSP:TRANSPARENT'));

    expect(parseIcs(text).events.single.availability, Availability.free);
  });

  test('Занятое событие пишет TRANSP:OPAQUE — так его поймёт чужой календарь',
      () {
    final text = toIcs([event('e1', 10, 11)], stamp: DateTime.utc(2026, 7, 27, 9));

    expect(text, contains('TRANSP:OPAQUE'));
    expect(parseIcs(text).events.single.availability, Availability.busy);
  });
}
