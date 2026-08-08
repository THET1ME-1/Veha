import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';

import 'sqlite_for_tests.dart';

/// Личное не уезжает с устройства.
///
/// Первый из необсуждаемых принципов ТЗ: наверх уходит только то, что человек
/// пометил общим. Проверяется на очереди отправки — она единственная дверь
/// наружу, и всё, что в неё попало, рано или поздно окажется на сервере.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');
    // Первый календарь заводится молча, его строка в очереди нам не мешает.
    await db.delete(db.syncQueue).go();
  });

  tearDown(() => db.close());

  Future<List<String>> queued() async {
    final rows = await db.select(db.syncQueue).get();
    return [for (final r in rows) '${r.entityType}:${r.entityId}'];
  }

  VEvent event(String id, {String calendarId = 'default'}) => VEvent(
        id: id,
        calendarId: calendarId,
        title: 'Приём у врача',
        start: DateTime(2026, 7, 27, 10),
        end: DateTime(2026, 7, 27, 11),
      );

  test('Событие личного календаря наверх не собирается', () async {
    await repo.upsertEvent(event('личное'));

    expect(await queued(), isEmpty,
        reason: 'запись личного календаря попала в очередь на сервер');
  });

  test('Событие общего календаря уходит в очередь', () async {
    await repo.setCalendarShared('default', true);
    await db.delete(db.syncQueue).go();

    await repo.upsertEvent(event('общее'));

    expect(await queued(), contains('event:общее'));
  });

  test('Календарь стал общим — его прошлое едет следом', () async {
    await repo.upsertEvent(event('заведено-до'));
    expect(await queued(), isEmpty);

    await repo.setCalendarShared('default', true);

    // Иначе на сервер уедет только то, что правили после переключателя, а
    // остальное останется невидимым для второго устройства.
    expect(await queued(), containsAll(['calendar:default', 'event:заведено-до']));
  });

  test('Календарь снова личный — очередь его записей забывает', () async {
    await repo.setCalendarShared('default', true);
    await repo.upsertEvent(event('передумал'));

    await repo.setCalendarShared('default', false);

    expect(await queued(), isEmpty,
        reason: 'снятая пометка не отменила отправку уже накопленного');
  });
}
