import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

/// Файл базы. Лежит в каталоге документов приложения — оттуда его забирает
/// бэкап и туда же кладёт восстановление.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'veha.sqlite'));

    if (Platform.isAndroid) {
      // На старых Android системная sqlite бывает без нужных расширений.
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }
    sqlite3.tempDirectory = (await getTemporaryDirectory()).path;

    return NativeDatabase.createInBackground(file);
  });
}

/// База в памяти — для тестов и для сверки экранов без файловой системы.
QueryExecutor openInMemory() => NativeDatabase.memory();
