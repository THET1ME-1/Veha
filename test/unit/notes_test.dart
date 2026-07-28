import 'package:drift/native.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';

import 'sqlite_for_tests.dart';

/// Заметки внутри события — четвёртый уровень цвета: свой цвет заметки
/// побеждает цвет события, а без него она наследует.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.seedIfEmpty(today: DateTime(2026, 7, 27));
  });

  tearDown(() => db.close());

  test('Заметка заводится и приходит обратно', () async {
    final id = repo.newId();
    await repo.upsertNote(VNote(
      id: id,
      eventId: 'e-exam',
      text: 'Взять паспорт',
      sortOrder: 9,
    ));

    final notes = await repo.notesOf('e-exam');
    expect(notes.where((n) => n.id == id).single.text, 'Взять паспорт');
  });

  test('Правка заметки не плодит вторую', () async {
    final id = repo.newId();
    final note = VNote(id: id, eventId: 'e-exam', text: 'Взять паспорт');

    await repo.upsertNote(note);
    final before = (await repo.notesOf('e-exam')).length;

    await repo.upsertNote(VNote(
      id: id,
      eventId: 'e-exam',
      text: 'Взять паспорт и допуск',
      color: const Color(0xFFB4694A),
    ));

    final notes = await repo.notesOf('e-exam');
    expect(notes, hasLength(before));
    final saved = notes.firstWhere((n) => n.id == id);
    expect(saved.text, 'Взять паспорт и допуск');
    expect(saved.color, const Color(0xFFB4694A));
  });

  test('Удаление мягкое и уносит заметку из списка', () async {
    final id = repo.newId();
    await repo.upsertNote(VNote(id: id, eventId: 'e-exam', text: 'Черновик'));
    await repo.deleteNote(id);

    expect((await repo.notesOf('e-exam')).where((n) => n.id == id), isEmpty);

    final rows = await db.select(db.eventNotes).get();
    expect(rows.firstWhere((r) => r.id == id).deletedAt, isNotNull,
        reason: 'Строка остаётся в базе: иначе сервер вернёт её при синке');
  });

  test('Поток заметок просыпается на правку', () async {
    final seen = <int>[];
    final sub = repo.watchNotes('e-exam').listen((n) => seen.add(n.length));
    await pumpEventQueue();

    await repo.upsertNote(
      VNote(id: repo.newId(), eventId: 'e-exam', text: 'Ещё одна'),
    );
    await pumpEventQueue();
    await sub.cancel();

    expect(seen.length, greaterThanOrEqualTo(2));
    expect(seen.last, seen.first + 1);
  });
}
