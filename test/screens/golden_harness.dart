import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veha/core/veha_theme.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:veha/data/db/database.dart';
import 'package:veha/data/providers.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/l10n/app_localizations.dart';

/// Снимок экрана без эмулятора.
///
/// Golden-тесты рендерят дерево виджетов в PNG прямо в `flutter test`, поэтому
/// сверять вёрстку с макетом можно на каждом шаге, а не после сборки APK.
/// Файлы кладутся в `test/screens/shots/` и в репозиторий не едут.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  _useSystemSqlite();
  // Иконки лежат в своём шрифте рядом с текстовыми: без него вместо каждой
  // иконки рисуется квадрат-заглушка, и сверять экран с макетом бессмысленно.
  for (final family in const ['Manrope', 'VehaSymbols']) {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
    await loader.load();
  }
}

/// База в памяти вместо файла: экраны в тестах проходят тот же путь
/// «база → репозиторий → виджет», что и в приложении.
///
/// `closeStreamsSynchronously` обязателен. Отписавшись от последнего слушателя,
/// drift придерживает кеш запроса ещё один оборот цикла событий и заводит ради
/// этого `Timer.run`. Отписка случается при разборе дерева — тогда Riverpod
/// гасит `ProviderScope`. Часы в `flutter_test` поддельные и двигаются только
/// `pump`, поэтому таймер не тикает, а `db.close()` ждёт его вечно: тест виснет
/// молча, без единой строчки в логе. С этим флагом стрим закрывается сразу и
/// таймера не заводит. Сторож — `harness_timers_test.dart`.
VehaDatabase testDatabase() => VehaDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );

/// Размер экрана телефона из макета: 390×844 логических пикселя.
const Size phoneSize = Size(390, 844);

/// Момент, на который собраны демо-данные: снимки не должны зависеть от
/// календаря машины, а сид ложится на «сегодня».
final DateTime testNow = DateTime(2026, 7, 27, 9, 41);

Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = phoneSize,
  Locale locale = const Locale('ru'),
  List<Override> overrides = const [],
  Future<void> Function(VehaRepository repo)? seed,
}) async {
  tester.view
    ..physicalSize = size * 2
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  // Настройки вида живут в SharedPreferences, а плагина в тестах нет: без
  // подмены экран ждёт первый ответ хранилища вечно. Подменять надо на каждом
  // экране, а не разом в `setUpAll`: иначе «Будни», выбранные одним тестом,
  // приезжают в снимок следующего — соседние тесты перестают быть
  // независимыми.
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final db = testDatabase();
  addTearDown(db.close);

  // Демонстрацию сеют тесты, а не приложение: человеку при первом запуске
  // чужие дела не нужны, а снимкам экрана нужен полный календарь.
  final repo = VehaRepository(db);
  await repo.seedIfEmpty(today: testNow, words: SeedWords.of('ru'));
  // Своё содержимое поверх общего сева: задачи и снимки нужны не каждому
  // снимку экрана, а держать их в общем посеве значит менять все остальные.
  if (seed != null) await seed(repo);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        nowProvider.overrideWithValue(testNow),
        // Демонстрация всегда по-русски: снимки сверяются с русским макетом,
        // а язык интерфейса задаётся отдельно параметром `locale`.
        seedLanguageProvider.overrideWithValue('ru'),
        ...overrides,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light
            ? VehaTheme.light(VehaTheme.defaultCorner)
            : VehaTheme.dark(VehaTheme.defaultCorner),
        locale: locale,
        supportedLocales: L.supportedLocales,
        localizationsDelegates: const [
          L.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    ),
  );
  await tester.pumpAndSettle();

  await _warmImages(tester);
}

/// Прогрев картинок с диска.
///
/// Сам по себе снимок в тестах не появляется: декодер работает в настоящем
/// цикле событий, а `flutter_test` держит поддельные часы. Внутри `runAsync`
/// цикл настоящий, но кадры оттуда не идут сами — поэтому `pump` вызывается
/// руками после каждой картинки. Без этого обложка выходит пустой, и глазами
/// это читается как поломка вёрстки.
///
/// Ожидание с потолком: `precacheImage` завершается на кадре, и стоит цепочке
/// разойтись — тест виснет молча и навсегда. Полсекунды на картинку хватает
/// с запасом, а зависнуть уже не даёт.
Future<void> _warmImages(WidgetTester tester) async {
  final images = find.byType(Image).evaluate().toList();
  if (images.isEmpty) return;

  await tester.runAsync(() async {
    for (final element in images) {
      await precacheImage((element.widget as Image).image, element)
          .timeout(const Duration(milliseconds: 500), onTimeout: () {});
      await tester.pump();
    }
  });
  await tester.pumpAndSettle();
}

/// Открывает форму правки события.
///
/// Тап по блоку показывает превью — форма живёт за кнопкой «Изменить».
/// Помощник нужен, чтобы этот порядок был записан в одном месте: иначе
/// каждый тест правки повторяет его своими руками и разъезжается.
Future<void> openEventEditor(WidgetTester tester, Finder target) async {
  // Лента дня держит масштаб времени: вечернее занятие лежит ниже экрана и
  // само в кадр не попадает. Крутим до него руками — `dragUntilVisible`
  // спотыкается о финдер с `.first`, когда цель ещё не построена.
  // Крутим именно ленту дня: первый Scrollable на экране — горизонтальная
  // полоска дней недели, и тянуть её вверх бессмысленно.
  for (var i = 0; i < 12 && target.evaluate().isEmpty; i++) {
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -180));
    await tester.pumpAndSettle();
  }

  await tester.tap(target.first);
  await tester.pumpAndSettle();

  final edit = find.text('Изменить');
  if (edit.evaluate().isNotEmpty) {
    await tester.tap(edit.first);
    await tester.pumpAndSettle();
  }
}

/// Пишет PNG рядом с тестами, чтобы картинку можно было открыть глазами.
Future<void> shoot(WidgetTester tester, String name) async {
  final dir = Directory('test/screens/shots');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('shots/$name.png'),
  );
}

/// drift ищет `libsqlite3.so`, а в дистрибутивах лежит `libsqlite3.so.0`
/// без симлинка. Пакет `sqlite3_flutter_libs` работает только внутри
/// приложения, поэтому в тестах указываем библиотеку явно.
void _useSystemSqlite() {
  if (!Platform.isLinux) return;
  sqlite_open.open.overrideFor(sqlite_open.OperatingSystem.linux, () {
    for (final name in const [
      'libsqlite3.so',
      'libsqlite3.so.0',
      '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    ]) {
      try {
        return DynamicLibrary.open(name);
      } on ArgumentError {
        continue;
      }
    }
    throw StateError('libsqlite3 не найдена');
  });
}
