import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

/// В тестах drift ищет `libsqlite3.so`, а в дистрибутивах лежит версионированный
/// `libsqlite3.so.0` без симлинка. Пакета `sqlite3_flutter_libs` тут нет — он
/// работает только внутри приложения, — поэтому библиотеку указываем явно.
void useSystemSqlite() {
  if (!Platform.isLinux) return;
  open.overrideFor(OperatingSystem.linux, () {
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
