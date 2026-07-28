import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';

import 'sqlite_for_tests.dart';

/// Демонстрация первого запуска говорит на языке человека. Русские названия
/// в немецком интерфейсе выглядят поломкой, а не приветствием.
void main() {
  setUpAll(useSystemSqlite);

  Future<List<String>> seedWith(String language) async {
    final db = VehaDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = VehaRepository(db);
    await repo.seedIfEmpty(
      today: DateTime(2026, 7, 27),
      words: SeedWords.of(language),
    );
    final inheritance = await repo.loadInheritance();
    return inheritance.calendars.values.map((c) => c.name).toList();
  }

  test('По-русски демонстрация остаётся как написана', () async {
    expect(await seedWith('ru'), contains('Учёба'));
  });

  test('По-немецки демонстрация переведена', () async {
    final names = await seedWith('de');
    expect(names, contains('Studium'));
    expect(names, isNot(contains('Учёба')));
  });

  test('Незнакомый язык получает английские слова', () async {
    // Латиница читается хоть как-то везде, кириллица — нет.
    expect(await seedWith('fi'), contains('Study'));
  });

  test('Неизвестное слово возвращается как есть', () {
    expect(SeedWords.of('de').t('Тайное слово'), 'Тайное слово');
  });
}
