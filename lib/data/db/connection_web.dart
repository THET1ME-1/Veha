import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// База в браузере.
///
/// Тот же SQLite, только собранный в WebAssembly: файл `sqlite3.wasm` и
/// воркер `drift_worker.js` лежат рядом с `index.html`. Хранилище выбирает
/// сам drift — OPFS там, где он есть, IndexedDB на остальных браузерах.
///
/// Это осознанно: веб-клиент остаётся таким же local-first, как телефон.
/// Данные живут у человека, а сервер нужен только чтобы свести устройства.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'veha',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}

/// В браузере памяти под отдельную базу тоже хватает: снимки экранов и
/// тесты гоняются на ней.
QueryExecutor openInMemory() => WasmDatabase.inMemory(null as dynamic);
