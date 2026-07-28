import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

/// Поиск по всему календарю, а не по видимому окну: «когда был экзамен»
/// спрашивают про прошлое так же часто, как про будущее.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;
  final now = DateTime(2026, 7, 27, 12);

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
  });

  tearDown(() => db.close());

  Future<List<VEvent>> find(String query) =>
      repo.watchSearch(query, now: now).first;

  test('Находит по названию, регистр не важен', () async {
    final found = await find('англ');
    expect(found.map((e) => e.title), contains('Английский'));
  });

  test('Находит по значению своего поля', () async {
    // «204-б» — кабинет экзамена, в названии этой строки нет.
    final found = await find('204-б');
    expect(found.map((e) => e.title), ['Экзамен по грамматике']);
  });

  test('Находит по месту', () async {
    final found = await find('Бэнулеску');
    expect(found.map((e) => e.title), contains('Английский'));
  });

  test('Ряд отдаётся ближайшим занятием, а не строкой ряда', () async {
    final found = await find('Подъём');
    final wake = found.first;

    expect(wake.isVirtual, isTrue, reason: 'Это экземпляр, а не сам ряд');
    expect(wake.start.isAfter(now), isTrue);
    expect(wake.start, DateTime(2026, 7, 28, 7, 30),
        reason: 'Сегодняшний подъём уже прошёл, показываем завтрашний');
  });

  test('Скрытый календарь не отдаёт своих событий', () async {
    expect(await find('Планёрка'), isNotEmpty);

    await repo.setCalendarVisible('c-work', false);
    expect(await find('Планёрка'), isEmpty);
  });

  test('Ближайшее впереди, прошедшее следом', () async {
    final found = await find('Бассейн');
    final future = found.where((e) => e.start.isAfter(now)).toList();
    final past = found.where((e) => !e.start.isAfter(now)).toList();

    expect(future, isNotEmpty);
    expect(found.take(future.length), future,
        reason: 'Сначала то, что ещё будет');
    for (var i = 1; i < future.length; i++) {
      expect(future[i].start.isAfter(future[i - 1].start), isTrue);
    }
    for (var i = 1; i < past.length; i++) {
      expect(past[i].start.isBefore(past[i - 1].start), isTrue,
          reason: 'Прошлое — от недавнего к давнему');
    }
  });

  test('Пустой запрос ничего не ищет', () async {
    expect(await find('   '), isEmpty);
  });
}
