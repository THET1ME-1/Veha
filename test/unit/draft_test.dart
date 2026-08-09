import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/draft.dart';

void main() {
  test('Новый черновик встаёт на ближайший круглый час', () {
    final draft = EventDraft.blank(
      now: DateTime(2026, 7, 27, 9, 41),
      calendarId: 'c-day',
    );

    expect(draft.start, DateTime(2026, 7, 27, 10));
    expect(draft.end, DateTime(2026, 7, 27, 11));
  });

  test('Черновик от тапа по часу берёт этот час', () {
    final draft = EventDraft.at(
      DateTime(2026, 7, 27, 15),
      calendarId: 'c-day',
    );

    expect(draft.start, DateTime(2026, 7, 27, 15));
    expect(draft.end, DateTime(2026, 7, 27, 16));
  });

  test('Смена длительности двигает конец, а не начало', () {
    final draft = EventDraft.at(DateTime(2026, 7, 27, 15), calendarId: 'c-day')
        .withDuration(const Duration(minutes: 30));

    expect(draft.start, DateTime(2026, 7, 27, 15));
    expect(draft.end, DateTime(2026, 7, 27, 15, 30));
  });

  test('Перенос начала сохраняет длительность', () {
    final draft = EventDraft.at(DateTime(2026, 7, 27, 15), calendarId: 'c-day')
        .withDuration(const Duration(minutes: 90))
        .withStart(DateTime(2026, 7, 28, 8));

    expect(draft.end, DateTime(2026, 7, 28, 9, 30));
  });

  test('Пустое название до сохранения не допускается', () {
    final draft = EventDraft.at(DateTime(2026, 7, 27, 15), calendarId: 'c-day');

    expect(draft.isReady, isFalse);
    expect(draft.withTitle('  ').isReady, isFalse);
    expect(draft.withTitle('Бассейн').isReady, isTrue);
  });

  test('Черновик превращается в событие со своим ключом', () {
    final draft = EventDraft.at(DateTime(2026, 7, 27, 15), calendarId: 'c-day')
        .withTitle('Бассейн');

    final event = draft.toEvent(newId: () => 'id-1');

    expect(event.id, 'id-1');
    expect(event.title, 'Бассейн');
    expect(event.calendarId, 'c-day');
    expect(event.rrule, isNull);
  });

  test('Черновик правки помнит, из какого события он вырос', () {
    final source = VEvent(
      id: 'e-eng@1',
      calendarId: 'c-study',
      title: 'Английский',
      start: DateTime(2026, 7, 27, 16),
      end: DateTime(2026, 7, 27, 17),
      rrule: 'FREQ=WEEKLY;BYDAY=MO',
      recurrenceId: 'e-eng',
      originalStart: DateTime(2026, 7, 27, 16),
      isVirtual: true,
    );

    final edited = EventDraft.of(source).withStart(DateTime(2026, 7, 27, 18));
    final event = edited.toEvent(newId: () => 'не понадобится');

    expect(event.id, 'e-eng@1');
    expect(event.isVirtual, isTrue);
    expect(event.recurrenceId, 'e-eng');
    expect(event.originalStart, DateTime(2026, 7, 27, 16));
    expect(event.start, DateTime(2026, 7, 27, 18));
  });
  group('Конец по времени суток', () {
    EventDraft evening() => EventDraft.at(
          DateTime(2026, 8, 9, 22),
          calendarId: 'c1',
        );

    test('Время после начала остаётся в том же дне', () {
      expect(evening().withEndAt(23, 30).end, DateTime(2026, 8, 9, 23, 30));
    });

    test('Время до начала уводит конец за полночь', () {
      expect(evening().withEndAt(6, 0).end, DateTime(2026, 8, 10, 6));
    });

    test('Ровно начало означает событие без окончания', () {
      final draft = evening().withEndAt(22, 0);
      expect(draft.end, draft.start);
    });
  });

}
