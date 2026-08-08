import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/db/database.dart';
import 'package:veha/data/models.dart';
import 'package:veha/data/repository.dart';
import 'package:veha/data/seed_words.dart';
import 'package:veha/domain/recurrence.dart';

import 'sqlite_for_tests.dart';

/// Правка ряда. Каждая проверка здесь — жалоба, которую можно повторить
/// руками: снять повтор, передвинуть дату, удалить весь ряд.
void main() {
  setUpAll(useSystemSqlite);

  late VehaDatabase db;
  late VehaRepository repo;

  setUp(() async {
    db = VehaDatabase(NativeDatabase.memory());
    repo = VehaRepository(db);
    await repo.ensureFirstCalendar(words: SeedWords.of('ru'), id: 'default');

    await repo.upsertEvent(VEvent(
      id: 'series',
      calendarId: 'default',
      title: 'Английский',
      start: DateTime(2026, 7, 6, 16),
      end: DateTime(2026, 7, 6, 17),
      rrule: Recurrence.weekly(interval: 1, weekdays: const {1}),
    ));
  });

  tearDown(() => db.close());

  /// Экземпляр ряда, каким его отдаёт развёртка: своего ключа у него нет,
  /// он несёт ключ ряда и своё исходное время.
  Future<VEvent> occurrenceOn(DateTime day) async {
    final events = await repo
        .watchRange(day, day.add(const Duration(days: 1)))
        .first;
    return events.firstWhere((e) => e.recurrenceId == 'series');
  }

  Future<Event> seriesRow() async =>
      (await (db.select(db.events)..where((t) => t.id.equals('series'))))
          .getSingle();

  test('Снятый повтор сохраняется: ряд становится обычным событием', () async {
    final instance = await occurrenceOn(DateTime(2026, 7, 27));

    await repo.updateWholeSeries(VEvent(
      id: instance.id,
      calendarId: instance.calendarId,
      title: instance.title,
      start: instance.start,
      end: instance.end,
      rrule: null, // человек выбрал «Не повторяется»
      recurrenceId: instance.recurrenceId,
      originalStart: instance.originalStart,
      isVirtual: true,
    ));

    expect((await seriesRow()).rrule, isNull,
        reason: 'Повтор снят, а не подставлен обратно из старой записи');

    final week = await repo
        .watchRange(DateTime(2026, 8, 1), DateTime(2026, 8, 31))
        .first;
    expect(week.where((e) => e.recurrenceId == 'series'), isEmpty,
        reason: 'Занятий в августе больше нет');
  });

  test('Перенос даты в правке «весь ряд» двигает весь ряд', () async {
    final instance = await occurrenceOn(DateTime(2026, 7, 27));

    // Занятие переносят с понедельника на вторник.
    await repo.updateWholeSeries(VEvent(
      id: instance.id,
      calendarId: instance.calendarId,
      title: instance.title,
      start: DateTime(2026, 7, 28, 18),
      end: DateTime(2026, 7, 28, 19),
      rrule: instance.rrule,
      recurrenceId: instance.recurrenceId,
      originalStart: instance.originalStart,
      isVirtual: true,
    ));

    final row = await seriesRow();
    final start = DateTime.fromMillisecondsSinceEpoch(row.start);
    expect(start.weekday, DateTime.tuesday,
        reason: 'Ряд сдвинулся на день, а не остался в понедельнике');
    expect(start.hour, 18, reason: 'Время суток тоже переехало');
    expect(start.month, 7, reason: 'Ряд не перепрыгнул в другой месяц');
  });

  test('Ряд удаляется целиком, а не по одному занятию', () async {
    await repo.deleteSeries('series');

    final row = await seriesRow();
    expect(row.deletedAt, isNotNull);

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month.where((e) => e.recurrenceId == 'series'), isEmpty);
  });

  /// Выломанное занятие: человек передвинул один урок, и в базе появилась
  /// отдельная запись с ключом ряда.
  Future<void> breakOut(DateTime day, {required int hour}) async {
    final instance = await occurrenceOn(day);
    await repo.upsertEvent(VEvent(
      id: 'moved-${day.day}',
      calendarId: instance.calendarId,
      title: instance.title,
      start: DateTime(day.year, day.month, day.day, hour),
      end: DateTime(day.year, day.month, day.day, hour + 1),
      recurrenceId: 'series',
      originalStart: instance.originalStart,
    ));
  }

  test('Удаление всего ряда уносит и переставленные занятия', () async {
    // Занятие 13 июля когда-то передвинули на вечер, 27 июля — тоже.
    await breakOut(DateTime(2026, 7, 13), hour: 18);
    await breakOut(DateTime(2026, 7, 27), hour: 19);

    await repo.deleteSeries('series');

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month, isEmpty,
        reason: '«Весь ряд» значит весь: и правило, и выломанные занятия');
  });

  test('«Вернуть» после удаления ряда поднимает и переставленные', () async {
    await breakOut(DateTime(2026, 7, 13), hour: 18);

    final removed = await repo.deleteSeries('series');
    await repo.restoreEvents(removed);

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month.any((e) => e.start.day == 13 && e.start.hour == 18), isTrue,
        reason: 'Переставленное занятие вернулось вместе с рядом');
    expect(month.any((e) => e.recurrenceId == 'series'), isTrue,
        reason: 'Сам ряд тоже на месте');
  });

  test('Занятие, оставшееся от удалённого ряда, всё равно удаляется', () async {
    await breakOut(DateTime(2026, 7, 13), hour: 18);
    // Ряд убит по-старому, одной строкой: так у людей и остались занятия,
    // которые не брало ни одно из трёх «удалить».
    await repo.deleteEvent('series');

    await repo.deleteSeries('series');

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month, isEmpty, reason: 'Сирота ряда удаляется, а не живёт вечно');
  });

  test('Отмена занятия убирает и переставленную запись', () async {
    await breakOut(DateTime(2026, 7, 13), hour: 18);
    final instance = await occurrenceOn(DateTime(2026, 7, 13));

    await repo.cancelOccurrence('series', instance.originalStart!);

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month.any((e) => e.start.day == 13), isFalse,
        reason: 'Отменённое занятие не остаётся в виде переставленной записи');
    expect(month.any((e) => e.start.day == 20), isTrue,
        reason: 'Остальной ряд идёт дальше');
  });

  test('Обрыв ряда уносит переставленные занятия после разреза', () async {
    await breakOut(DateTime(2026, 7, 13), hour: 18);
    await breakOut(DateTime(2026, 7, 27), hour: 19);

    await repo.trimSeriesAt('series', DateTime(2026, 7, 20, 16));

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    expect(month.any((e) => e.start.day == 13), isTrue,
        reason: 'Прошедшее остаётся: человек его прожил');
    expect(month.any((e) => e.start.day == 27), isFalse,
        reason: 'После разреза не остаётся ни занятий, ни их переносов');
  });

  test('Отмена одного занятия ряд не трогает', () async {
    final instance = await occurrenceOn(DateTime(2026, 7, 27));
    await repo.skipOccurrence('series', instance.originalStart!);

    final month = await repo
        .watchRange(DateTime(2026, 7, 1), DateTime(2026, 8, 1))
        .first;
    final left = month.where((e) => e.recurrenceId == 'series').toList();
    expect(left, isNotEmpty, reason: 'Остальные занятия на месте');
    expect(left.any((e) => e.start.day == 27), isFalse);
  });
}
