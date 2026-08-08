import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';

import 'sqlite_for_tests.dart';

/// Ручной порядок задач.
///
/// Задачи со сроком выстраивает срок — тут спорить не о чем. А у бессрочных
/// порядок задаёт человек: «сначала позвонить, потом всё остальное» — это и
/// есть список дел. Перетаскивать их было нельзя вовсе.
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

    for (final title in const ['первая', 'вторая', 'третья']) {
      await repo.upsertTask(VTask(
        id: title,
        calendarId: 'default',
        title: title,
        sortOrder: const ['первая', 'вторая', 'третья'].indexOf(title),
      ));
    }
  });

  tearDown(() => db.close());

  Future<List<String>> order() async =>
      (await repo.watchTasks().first).map((t) => t.id).toList();

  test('Порядок сохраняется таким, каким его собрали', () async {
    await repo.reorderTasks(const ['третья', 'первая', 'вторая']);

    expect(await order(), ['третья', 'первая', 'вторая']);
  });

  test('Перестановка переживает перечитывание из базы', () async {
    await repo.reorderTasks(const ['вторая', 'третья', 'первая']);
    await repo.reorderTasks(const ['первая', 'вторая', 'третья']);

    expect(await order(), ['первая', 'вторая', 'третья']);
  });
}
