import 'dart:convert';
import 'dart:ffi' show DynamicLibrary;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:m3_dna/theme/app_theme.dart';
import 'package:veha/core/brand.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:veha/data/db/database.dart';
import 'package:veha/data/providers.dart';
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
  for (final family in const ['Unbounded', 'Onest']) {
    final loader = FontLoader(family)
      ..addFont(rootBundle.load('assets/fonts/$family.ttf'));
    await loader.load();
  }
  // Без этого вместо каждой иконки рисуется квадрат-заглушка, и сверять
  // экран с макетом бессмысленно. Ассеты чужого пакета в тестовый бандл не
  // попадают, поэтому файл читается прямо из кеша пакетов.
  final iconFont = _packageFile(
    'material_symbols_icons',
    'lib/fonts/MaterialSymbolsRounded.ttf',
  );
  if (iconFont != null) {
    // У IconData из пакета есть fontPackage, поэтому Flutter ищет семейство
    // под именем «packages/<пакет>/<семейство>» — под ним и регистрируем.
    final icons = FontLoader(
      'packages/material_symbols_icons/MaterialSymbolsRounded',
    )..addFont(Future.value(iconFont.readAsBytesSync().buffer.asByteData()));
    await icons.load();
  }
}

/// Путь к файлу внутри зависимости — через package_config, который pub
/// оставляет рядом с проектом.
File? _packageFile(String package, String relative) {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return null;
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  for (final p in json['packages'] as List) {
    if (p['name'] == package) {
      final root = Uri.parse(p['rootUri'] as String);
      var base = root.isAbsolute ? root : config.parent.uri.resolveUri(root);
      // Без завершающего слэша resolve() съедает последний сегмент пути.
      if (!base.path.endsWith('/')) {
        base = base.replace(path: '${base.path}/');
      }
      return File.fromUri(base.resolve(relative));
    }
  }
  return null;
}

/// Размер экрана телефона из макета: 390×844 логических пикселя.
const Size phoneSize = Size(390, 844);

Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = phoneSize,
  Locale locale = const Locale('ru'),
}) async {
  tester.view
    ..physicalSize = size * 2
    ..devicePixelRatio = 2;
  addTearDown(tester.view.reset);

  // База в памяти вместо файла: экраны в тестах проходят тот же путь
  // «база → репозиторий → виджет», что и в приложении.
  final db = VehaDatabase(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light
            ? AppTheme.light(
                VehaBrand.seed,
                vibrant: VehaBrand.vibrantByDefault,
              )
            : AppTheme.dark(
                VehaBrand.seed,
                vibrant: VehaBrand.vibrantByDefault,
              ),
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
