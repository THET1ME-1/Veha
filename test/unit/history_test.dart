import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

/// История изменений события: кто когда что подвинул.
///
/// Живёт только на устройстве, как и снимки: сервер хранит записи и отдаёт
/// дельты, а журнал правок — местная память, и гнать её по сети незачем.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.upsertCalendar(const VCalendar(
      id: 'c',
      name: 'Личное',
      iconName: 'home',
      color: Color(0xFF41CCB5),
    ));
  });

  tearDown(() => db.close());

  VEvent event({
    String title = 'Планёрка',
    int hour = 10,
    String calendarId = 'c',
    String? place,
  }) =>
      VEvent(
        id: 'e1',
        calendarId: calendarId,
        title: title,
        start: DateTime(2026, 7, 27, hour),
        end: DateTime(2026, 7, 27, hour + 1),
        location: place,
      );

  test('Заведённое событие открывает историю', () async {
    await repo.upsertEvent(event());

    final history = await repo.historyOf('e1');
    expect(history.single.kind, RevisionKind.created);
  });

  test('Переименование записано с обеими сторонами', () async {
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(title: 'Летучка'));

    final history = await repo.historyOf('e1');
    final rename = history.firstWhere((r) => r.kind == RevisionKind.title);
    expect(rename.before, 'Планёрка');
    expect(rename.after, 'Летучка');
  });

  test('Перенос — одна запись, а не две', () async {
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(hour: 15));

    final moves = (await repo.historyOf('e1'))
        .where((r) => r.kind == RevisionKind.time);
    expect(moves, hasLength(1));
  });

  test('Время в журнале хранится разбираемым, а не готовой подписью', () async {
    // Подпись зависит от языка и от того, какой формат человек выберет
    // завтра; сохранённая строка пережила бы и то и другое, начав врать.
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(hour: 15));

    final move = (await repo.historyOf('e1'))
        .firstWhere((r) => r.kind == RevisionKind.time);
    final was = move.before!.split('|');
    expect(DateTime.parse(was.first), DateTime(2026, 7, 27, 10));
    expect(DateTime.parse(was.last), DateTime(2026, 7, 27, 11));
  });

  test('Сохранение без правок историю не плодит', () async {
    await repo.upsertEvent(event());
    await repo.upsertEvent(event());
    await repo.upsertEvent(event());

    expect(await repo.historyOf('e1'), hasLength(1));
  });

  test('Место и календарь пишутся своими строками', () async {
    await repo.upsertCalendar(const VCalendar(
      id: 'c2',
      name: 'Работа',
      iconName: 'work',
      color: Color(0xFF0369A1),
    ));
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(place: 'Кофейня'));
    await repo.upsertEvent(event(place: 'Кофейня', calendarId: 'c2'));

    final kinds = (await repo.historyOf('e1')).map((r) => r.kind);
    expect(kinds, containsAll([RevisionKind.place, RevisionKind.calendar]));
  });

  test('История идёт от свежего к старому', () async {
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(title: 'Летучка'));

    final history = await repo.historyOf('e1');
    expect(history.first.kind, RevisionKind.title);
    expect(history.last.kind, RevisionKind.created);
  });

  test('Удалённое событие уносит свою историю', () async {
    await repo.upsertEvent(event());
    await repo.upsertEvent(event(title: 'Летучка'));
    await repo.deleteEvent('e1');
    await repo.purgeDeleted(olderThan: const Duration());

    expect(await repo.historyOf('e1'), isEmpty);
  });
}
