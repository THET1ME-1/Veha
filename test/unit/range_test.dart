import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:veha/data/db/database.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/data/providers.dart';

import 'sqlite_for_tests.dart';

void main() {
  setUpAll(() {
    useSystemSqlite();
    tzdata.initializeTimeZones();
  });

  late VehaDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    await VehaRepository(db)
        .seedIfEmpty(today: DateTime(2026, 7, 27), words: SeedWords.of('ru'));
    // Демонстрацию сеет тест: приложение при первом запуске заводит только
    // пустой календарь.
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        // Демо-данные ложатся на «сегодня», поэтому в тестах «сегодня»
        // фиксировано — иначе снимок зависит от календаря машины.
        nowProvider.overrideWithValue(DateTime(2026, 7, 27)),
        // Демонстрация на языке теста, а не машины: иначе названия событий
        // зависят от локали, с которой запущен прогон.
        seedLanguageProvider.overrideWithValue('ru'),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  test('Неделя разложена по дням, ряды развёрнуты', () async {
    final range = await container.read(
      rangeProvider((
        from: DateTime(2026, 7, 27),
        to: DateTime(2026, 8, 3),
      )).future,
    );

    // «Подъём» повторяется каждый день, а своя строка у него одна.
    expect(range.eventsOn(DateTime(2026, 7, 29)).map((e) => e.title),
        contains('Подъём'));
    expect(range.eventsOn(DateTime(2026, 8, 1)).map((e) => e.title),
        contains('Подъём'));
  });

  test('Многодневные события отделены от дневных', () async {
    final range = await container.read(
      rangeProvider((
        from: DateTime(2026, 7, 27),
        to: DateTime(2026, 8, 3),
      )).future,
    );

    expect(range.spans, isNotEmpty);
    expect(range.spans.every((e) => e.isMultiDay), isTrue);
    expect(
      range.eventsOn(DateTime(2026, 7, 29)).any((e) => e.isMultiDay),
      isFalse,
      reason: 'Абонемент на месяц идёт полосой, а не карточкой в сетке часов',
    );
  });

  test('Полоса тянется через каждый свой день', () async {
    final range = await container.read(
      rangeProvider((
        from: DateTime(2026, 7, 27),
        to: DateTime(2026, 8, 3),
      )).future,
    );

    final span = range.spans.first;
    final middle = span.start.add(const Duration(days: 1));

    expect(range.spansOn(middle), contains(span));
    expect(range.spansOn(span.end.add(const Duration(days: 2))), isEmpty);
  });

  test('День внутри многодневного события не считает его своим', () async {
    final range = await container.read(
      rangeProvider((
        from: DateTime(2026, 7, 27),
        to: DateTime(2026, 8, 3),
      )).future,
    );

    final empty = range.eventsOn(DateTime(2026, 8, 2));
    expect(empty.where((e) => e.isMultiDay), isEmpty);
  });
}
