import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';

import 'sqlite_for_tests.dart';

/// Ключи записей — UUID с клиента, включая самый первый календарь.
///
/// ТЗ ставит это условием офлайна, но цена ошибки выше: пока первый календарь
/// у всех назывался `default`, две базы нельзя было ни свести на одном
/// сервере, ни расшарить друг другу — сервер отвечал пятисоткой на конфликт
/// первичного ключа.
void main() {
  setUpAll(useSystemSqlite);

  VehaDatabase open() => VehaDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );

  Future<String> firstCalendarId(VehaDatabase db) async {
    final repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'));
    final tree = await repo.loadInheritance();
    return tree.calendars.keys.single;
  }

  test('Первый календарь получает свой ключ, а не общее слово', () async {
    final db = open();
    addTearDown(db.close);

    final id = await firstCalendarId(db);

    expect(id, isNot('default'));
    expect(id.length, 36, reason: 'ключ должен быть UUID');
  });

  test('Две базы не сходятся ключом первого календаря', () async {
    final a = open();
    final b = open();
    addTearDown(a.close);
    addTearDown(b.close);

    expect(await firstCalendarId(a), isNot(await firstCalendarId(b)));
  });
}
