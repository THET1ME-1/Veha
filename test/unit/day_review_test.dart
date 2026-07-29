import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/domain/day_review.dart';
import 'package:veha/domain/free_time.dart';

/// Разбор дня: сколько занято, где окна и что стоит развести.
///
/// Считается без базы и без экрана — календарь уже знает всё, чтобы ответить
/// на «влезет ли ещё одно дело», и переспрашивать человека незачем.
void main() {
  final day = DateTime(2026, 7, 27);

  VEvent at(int hour, int minutes, {String id = 'e', int startMinute = 0}) =>
      VEvent(
        id: id,
        calendarId: 'c',
        title: id,
        start: DateTime(day.year, day.month, day.day, hour, startMinute),
        end: DateTime(day.year, day.month, day.day, hour, startMinute)
            .add(Duration(minutes: minutes)),
      );

  test('Занятое и свободное время считаются по границам дня', () {
    final review = reviewDay(
      [at(10, 60, id: 'a'), at(14, 90, id: 'b')],
      day,
      bounds: const DayBounds(from: 9, to: 18),
    );

    expect(review.busy, const Duration(minutes: 150));
    // Девять часов в границах минус два с половиной занятых.
    expect(review.free, const Duration(minutes: 390));
    expect(review.load, closeTo(150 / 540, 0.001));
  });

  test('Самое длинное занятие названо', () {
    final review = reviewDay([at(10, 30, id: 'короткое'), at(12, 120, id: 'долгое')], day);
    expect(review.longest?.id, 'долгое');
  });

  test('Накладки собраны парами', () {
    final review = reviewDay(
      [at(10, 60, id: 'встреча'), at(10, 60, id: 'звонок', startMinute: 30)],
      day,
    );

    expect(review.clashes, hasLength(1));
    expect(
      {review.clashes.single.first.id, review.clashes.single.second.id},
      {'встреча', 'звонок'},
    );
  });

  test('День без перерывов виден отдельно', () {
    // Четыре занятия встык: перерыва между ними нет ни одного.
    final packed = reviewDay(
      [
        at(9, 120, id: 'a'),
        at(11, 120, id: 'b'),
        at(13, 120, id: 'c'),
        at(15, 180, id: 'd'),
      ],
      day,
      bounds: const DayBounds(from: 9, to: 18),
    );
    expect(packed.hasNoBreaks, isTrue);

    final loose = reviewDay(
      [at(9, 60, id: 'a'), at(14, 60, id: 'b')],
      day,
      bounds: const DayBounds(from: 9, to: 18),
    );
    expect(loose.hasNoBreaks, isFalse);
  });

  test('Многодневная полоса днём не считается', () {
    final pass = VEvent(
      id: 'pass',
      calendarId: 'c',
      title: 'Абонемент',
      start: DateTime(2026, 7, 1),
      end: DateTime(2026, 7, 30),
      color: const Color(0xFF41CCB5),
    );
    final review = reviewDay([pass, at(10, 60, id: 'a')], day);
    expect(review.busy, const Duration(hours: 1));
  });

  test('Пустой день — честный ноль, а не выдуманная загрузка', () {
    final review = reviewDay(const [], day);
    expect(review.busy, Duration.zero);
    expect(review.load, 0);
    expect(review.longest, isNull);
    expect(review.hasNoBreaks, isFalse);
  });
}
