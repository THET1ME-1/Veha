import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

void main() {
  setUpAll(useSystemSqlite);

  test('Поток наследования не шлёт бесконечных обновлений', () async {
    final db = VehaDatabase(NativeDatabase.memory());
    final repo = VehaRepository(db);
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));

    var events = 0;
    final sub = repo.watchInheritance().listen((_) => events++);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    await sub.cancel();
    await db.close();

    expect(events, lessThan(5), reason: 'Поток обновляется без причины');
  });
}
