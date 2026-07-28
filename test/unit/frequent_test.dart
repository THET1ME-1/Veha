import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';

import 'sqlite_for_tests.dart';

/// Частые события вместо шаблонов: заготовку, которую надо завести руками,
/// заводят один раз и забывают, а история и так знает, что повторяется.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;
  final now = DateTime(2026, 7, 27, 12);

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'));
  });

  tearDown(() => db.close());

  Future<void> add(String id, String title, DateTime start, int hours) =>
      repo.upsertEvent(VEvent(
        id: id,
        calendarId: 'default',
        title: title,
        start: start,
        end: start.add(Duration(hours: hours)),
      ));

  test('Чаще заводимое идёт первым, длительность — средняя', () async {
    await add('a1', 'Планёрка', DateTime(2026, 7, 20, 10), 1);
    await add('a2', 'Планёрка', DateTime(2026, 7, 21, 10), 2);
    await add('a3', 'Планёрка', DateTime(2026, 7, 22, 10), 1);
    await add('b1', 'Бассейн', DateTime(2026, 7, 23, 19), 1);

    final frequent = await repo.frequentEvents(now: now);

    expect(frequent.first.title, 'Планёрка');
    expect(frequent.first.duration.inMinutes, 80, reason: 'Среднее из 1, 2 и 1');
    expect(frequent.map((e) => e.title), contains('Бассейн'));
  });

  test('Старое в подсказки не идёт', () async {
    await add('old', 'Прошлогоднее', DateTime(2025, 7, 20, 10), 1);
    final frequent = await repo.frequentEvents(now: now);
    expect(frequent, isEmpty);
  });

  test('Удалённое не подсказывается', () async {
    await add('x', 'Отменённое', DateTime(2026, 7, 20, 10), 1);
    await repo.deleteEvent('x');
    expect(await repo.frequentEvents(now: now), isEmpty);
  });
}
