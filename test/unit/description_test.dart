import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/ics.dart';

import 'sqlite_for_tests.dart';

/// Описание события.
///
/// Поле было в схеме с первого дня, и поиск по нему уже искал — а заполнить
/// его было нечем: ни модель, ни форма, ни выгрузка о нём не знали. Со стороны
/// это выглядит как поиск, который никогда ничего не находит.
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
  });

  tearDown(() => db.close());

  VEvent event({String? description}) => VEvent(
        id: 'e1',
        calendarId: 'default',
        title: 'Созвон',
        description: description,
        start: DateTime(2026, 7, 27, 10),
        end: DateTime(2026, 7, 27, 11),
      );

  Future<VEvent> readBack() async => (await repo
          .watchRange(DateTime(2026, 7, 27), DateTime(2026, 7, 28))
          .first)
      .single;

  test('Описание доживает от формы до базы и обратно', () async {
    await repo.upsertEvent(event(description: 'Взять договор и паспорт'));

    expect((await readBack()).description, 'Взять договор и паспорт');
  });

  test('Поиск находит по описанию', () async {
    await repo.upsertEvent(event(description: 'Обсудить смету на ремонт'));

    final found = await repo.watchSearch('смету').first;
    expect(found.map((e) => e.id), ['e1']);
  });

  test('Стёртое описание не остаётся в базе прежним', () async {
    await repo.upsertEvent(event(description: 'Черновик'));
    await repo.upsertEvent(event());

    expect((await readBack()).description, isNull);
  });

  test('Описание уезжает в .ics и приезжает обратно', () {
    final text = toIcs(
      [event(description: 'Первая строка\nвторая строка')],
      stamp: DateTime.utc(2026, 7, 27, 9),
    );
    expect(text, contains('DESCRIPTION:'));

    final back = parseIcs(text).events.single;
    expect(back.description, 'Первая строка\nвторая строка');
  });
}
