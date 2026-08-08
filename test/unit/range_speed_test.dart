import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/recurrence.dart';

import 'sqlite_for_tests.dart';

/// Скорость главного запроса на календаре живого человека.
///
/// Окно месяца перечитывается на каждую правку события, и от него зависит,
/// подвисает приложение при сохранении или нет. Проверка держит порог: год
/// занятий, полсотни рядов и пятьсот разовых событий должны отдаваться за
/// доли секунды, иначе виноват запрос, а не телефон.
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

  test('Месяц читается быстро на календаре с годовой историей', () async {
    final start = DateTime(2026, 1, 5, 9);

    // Полсотни рядов: расписание занятий, тренировок и созвонов, заведённое
    // в январе и идущее до сих пор. Ряды — самая дорогая часть окна: их
    // разворачивает клиент.
    for (var i = 0; i < 50; i++) {
      await repo.upsertEvent(VEvent(
        id: 'ряд-$i',
        calendarId: 'default',
        title: 'Занятие $i',
        start: start.add(Duration(days: i % 7, hours: i % 8)),
        end: start.add(Duration(days: i % 7, hours: i % 8 + 1)),
        rrule: Recurrence.weekly(interval: 1, weekdays: {(i % 7) + 1}),
      ));
    }

    // Пятьсот разовых событий за год — примерно полтора в день.
    for (var i = 0; i < 500; i++) {
      final at = start.add(Duration(days: i ~/ 2, hours: i % 12));
      await repo.upsertEvent(VEvent(
        id: 'событие-$i',
        calendarId: 'default',
        title: 'Дело $i',
        start: at,
        end: at.add(const Duration(minutes: 45)),
      ));
    }

    final from = DateTime(2026, 7, 1);
    final to = DateTime(2026, 8, 1);

    // Первый прогон прогревает планировщик запросов, меряем следующие.
    await repo.eventsBetween(from, to);

    final watch = Stopwatch()..start();
    for (var i = 0; i < 5; i++) {
      await repo.eventsBetween(from, to);
    }
    watch.stop();

    final perRead = watch.elapsedMilliseconds / 5;
    expect(perRead, lessThan(120),
        reason: 'окно месяца читается $perRead мс — на телефоне это заметное '
            'подвисание при каждом сохранении');
  });
}
