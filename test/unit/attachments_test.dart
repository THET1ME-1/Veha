import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

/// Вложения события. Как и снимки, живут только на устройстве: сервер хранит
/// записи и отдаёт дельты, файлового хранилища у него нет.
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
    await repo.upsertEvent(VEvent(
      id: 'e1',
      calendarId: 'c',
      title: 'Экзамен',
      start: DateTime(2026, 7, 28, 11),
      end: DateTime(2026, 7, 28, 13),
    ));
  });

  tearDown(() => db.close());

  VFile file(String id, String name) => VFile(
        id: id,
        eventId: 'e1',
        path: 'files/$id.pdf',
        name: name,
        size: 1024,
        addedAt: DateTime(2026, 7, 27, 12),
      );

  test('Приложенный файл виден у события', () async {
    await repo.addFile(file('f1', 'Билет.pdf'));

    final files = await repo.filesOf('e1');
    expect(files.single.name, 'Билет.pdf');
    expect(files.single.path, 'files/f1.pdf');
  });

  test('Удаление возвращает путь, чтобы убрать файл с диска', () async {
    await repo.addFile(file('f1', 'Билет.pdf'));

    expect(await repo.deleteFile('f1'), 'files/f1.pdf');
    expect(await repo.filesOf('e1'), isEmpty);
    // Второй раз убирать нечего — и честнее сказать об этом пустотой.
    expect(await repo.deleteFile('f1'), isNull);
  });

  test('Вложения не попадают в очередь синхронизации', () async {
    await repo.addFile(file('f1', 'Билет.pdf'));

    final queue = await db.select(db.syncQueue).get();
    expect(queue.where((q) => q.entityType == 'file'), isEmpty);
  });

  test('Событие уносит вложения из базы вместе с собой', () async {
    await repo.addFile(file('f1', 'Билет.pdf'));
    await repo.deleteEvent('e1');
    await repo.purgeDeleted(olderThan: const Duration());

    expect(await repo.filesOf('e1'), isEmpty);
  });
}
