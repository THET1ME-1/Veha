import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/services/sync_api.dart';
import 'package:veha/services/sync_service.dart';

import 'sqlite_for_tests.dart';

/// Сквозная проверка: настоящий сервер, настоящий HTTP, два «устройства».
///
/// Подделка внутри приложения не докажет, что стороны понимают друг друга:
/// имена колонок, формат чисел и правила конфликта живут по обе стороны, и
/// разойтись они могут молча. Поэтому здесь поднимается тот самый сервер.
///
/// Без него тест не падает, а пропускается: на чистой машине без Node
/// клиентские проверки не должны краснеть из-за чужого репозитория.
void main() {
  setUpAll(useSystemSqlite);

  const serverDir = '/home/alelx/Projects/GitHub/veha-server';
  final available = Directory('$serverDir/node_modules').existsSync();

  late Process server;
  late String baseUrl;

  setUpAll(() async {
    if (!available) return;

    // Порт спрашиваем у системы: фиксированный номер занимает сервер,
    // оставшийся от прошлого прогона, и тест стучится в чужую базу — со
    // старой схемой и ответом 500.
    final probe = await ServerSocket.bind('127.0.0.1', 0);
    final port = probe.port;
    await probe.close();

    baseUrl = 'http://127.0.0.1:$port';
    // Напрямую бинарём, а не через `npx`: тот порождает node отдельным
    // процессом, и `kill` гасит обёртку, оставляя сервер держать порт.
    server = await Process.start(
      '$serverDir/node_modules/.bin/tsx',
      ['src/node.ts'],
      workingDirectory: serverDir,
      environment: {
        'PORT': '$port',
        'VEHA_DB': ':memory:',
        'PATH': Platform.environment['PATH'] ?? '',
        'HOME': Platform.environment['HOME'] ?? '',
      },
    );

    // Ждём, пока порт ответит: сервер поднимается за секунду-две.
    for (var i = 0; i < 40; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      try {
        final socket = await Socket.connect('127.0.0.1', port,
            timeout: const Duration(milliseconds: 200));
        socket.destroy();
        break;
      } on SocketException {
        continue;
      }
    }
  });

  tearDownAll(() async {
    if (!available) return;
    server.kill();
    // Ждём фактического выхода: иначе следующий прогон встречает живой
    // процесс на том же порту.
    await server.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        server.kill(ProcessSignal.sigkill);
        return -1;
      },
    );
  });

  /// Устройство с собственным календарём: ключ у каждого свой, как в жизни.
  Future<(VehaDatabase, VehaRepository, SyncService, String)> device(
      String url) async {
    final db = VehaDatabase(NativeDatabase.memory());
    final repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'));
    final tree = await repo.loadInheritance();
    final calendarId = tree.calendars.keys.single;
    // Наверх уходит только общее: устройство, где календарь личный, ничего и
    // не должно отправлять.
    await repo.setCalendarShared(calendarId, true);
    return (db, repo, SyncService(db: db, api: HttpSyncApi(baseUrl: url)), calendarId);
  }

  test('Событие с первого устройства доезжает до второго', () async {
    if (!available) {
      markTestSkipped('Сервер не установлен: npm install в veha-server');
      return;
    }

    final api = HttpSyncApi(baseUrl: baseUrl);
    final first = await api.register('Телефон');

    final (dbA, repoA, syncA, calA) = await device(baseUrl);
    addTearDown(dbA.close);

    await repoA.upsertEvent(VEvent(
      id: 'live-1',
      calendarId: calA,
      title: 'Через сервер',
      start: DateTime(2026, 8, 10, 10),
      end: DateTime(2026, 8, 10, 11),
      reminders: const [30],
    ));

    final sent = await syncA.run(token: first.token, since: 0);
    expect(sent.sent, greaterThan(0));

    // Второе устройство получает свой ключ по коду с первого.
    final code = await api.pairCode(first.token);
    final second = await api.claim(code, 'Планшет');

    final (dbB, repoB, syncB, _) = await device(baseUrl);
    addTearDown(dbB.close);

    final received = await syncB.run(token: second.token, since: 0);
    expect(received.received, greaterThan(0));

    final day = await repoB
        .watchRange(DateTime(2026, 8, 10), DateTime(2026, 8, 11))
        .first;
    final event = day.firstWhere((e) => e.id == 'live-1');
    expect(event.title, 'Через сервер');
    expect(event.reminders, [30], reason: 'Напоминание пережило дорогу');
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('Задача доезжает вместе с отметкой', () async {
    if (!available) {
      markTestSkipped('Сервер не установлен');
      return;
    }

    final api = HttpSyncApi(baseUrl: baseUrl);
    final owner = await api.register('Телефон');

    final (dbA, repoA, syncA, calA) = await device(baseUrl);
    addTearDown(dbA.close);
    await repoA.upsertTask(VTask(
      id: 'live-task',
      calendarId: calA,
      title: 'Продлить абонемент',
      due: DateTime(2026, 8, 12, 18),
      hasTime: true,
    ));
    var cursor = (await syncA.run(token: owner.token, since: 0)).cursor;

    final code = await api.pairCode(owner.token);
    final second = await api.claim(code, 'Планшет');
    final (dbB, repoB, syncB, _) = await device(baseUrl);
    addTearDown(dbB.close);
    var cursorB = (await syncB.run(token: second.token, since: 0)).cursor;

    final arrived = await repoB.watchTasks().first;
    final task = arrived.firstWhere((t) => t.id == 'live-task');
    expect(task.title, 'Продлить абонемент');
    expect(task.hasTime, isTrue, reason: 'Булево значение пережило JSON');
    expect(task.due, DateTime(2026, 8, 12, 18));

    // Отметка выполнения — обычная правка: едет тем же путём.
    await repoA.setTaskDone('live-task', true);
    cursor = (await syncA.run(token: owner.token, since: cursor)).cursor;
    cursorB = (await syncB.run(token: second.token, since: cursorB)).cursor;

    final after = await repoB.watchTasks().first;
    expect(after.firstWhere((t) => t.id == 'live-task').isDone, isTrue);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('Удаление доезжает так же, как заведение', () async {
    if (!available) {
      markTestSkipped('Сервер не установлен');
      return;
    }

    final api = HttpSyncApi(baseUrl: baseUrl);
    final owner = await api.register('Телефон');

    final (dbA, repoA, syncA, calA) = await device(baseUrl);
    addTearDown(dbA.close);
    await repoA.upsertEvent(VEvent(
      id: 'live-2',
      calendarId: calA,
      title: 'Уедет',
      start: DateTime(2026, 8, 11, 10),
      end: DateTime(2026, 8, 11, 11),
    ));
    var cursor = (await syncA.run(token: owner.token, since: 0)).cursor;

    final code = await api.pairCode(owner.token);
    final second = await api.claim(code, 'Планшет');
    final (dbB, repoB, syncB, _) = await device(baseUrl);
    addTearDown(dbB.close);
    var cursorB = (await syncB.run(token: second.token, since: 0)).cursor;

    await repoA.deleteEvent('live-2');
    cursor = (await syncA.run(token: owner.token, since: cursor)).cursor;
    cursorB = (await syncB.run(token: second.token, since: cursorB)).cursor;

    final day = await repoB
        .watchRange(DateTime(2026, 8, 11), DateTime(2026, 8, 12))
        .first;
    expect(day.where((e) => e.id == 'live-2'), isEmpty);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
