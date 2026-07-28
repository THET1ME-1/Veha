import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:veha/data/models.dart';
import 'package:veha/l10n/app_localizations.dart';
import 'package:veha/services/widget_service.dart';

/// Данные виджета считает приложение: в Kotlin второго счётчика нет и быть не
/// должно. Значит и проверяется счёт здесь.
void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  late L l;

  setUp(() async {
    l = await L.delegate.load(const Locale('ru'));
  });

  final inheritance = Inheritance(
    calendars: {
      'work': const VCalendar(
        id: 'work',
        name: 'Работа',
        iconName: 'groups',
        color: Color(0xFF0369A1),
      ),
      'home': const VCalendar(
        id: 'home',
        name: 'Личное',
        iconName: 'restaurant',
        color: Color(0xFFC2410C),
      ),
    },
    subcategories: const {},
  );

  final now = DateTime(2026, 7, 28, 9);

  test('Дела дня выстраиваются по времени, цвет берётся с календаря', () {
    final snapshot = buildWidgetSnapshot(
      l: l,
      locale: 'ru',
      now: now,
      inheritance: inheritance,
      events: [
        VEvent(
          id: 'e1',
          calendarId: 'work',
          title: 'Планёрка',
          start: DateTime(2026, 7, 28, 10),
          end: DateTime(2026, 7, 28, 11),
        ),
      ],
      tasks: [
        VTask(
          id: 't1',
          calendarId: 'home',
          title: 'Забрать посылку',
          due: DateTime(2026, 7, 28, 8),
          hasTime: true,
        ),
      ],
    );

    expect(snapshot.items.map((i) => i.title), ['Забрать посылку', 'Планёрка']);
    expect(snapshot.items.first.time, '08:00');
    expect(snapshot.items.first.color, 0xFFC2410C);
    expect(snapshot.day, '28');
    expect(snapshot.weekday, 'вторник');
    expect(snapshot.count, '2');
  });

  test('Задача без срока в виджет не идёт', () {
    final snapshot = buildWidgetSnapshot(
      l: l,
      locale: 'ru',
      now: now,
      inheritance: inheritance,
      events: const [],
      tasks: const [
        VTask(id: 't2', calendarId: 'home', title: 'Когда-нибудь'),
      ],
    );

    expect(snapshot.items, isEmpty);
    expect(snapshot.count, '');
    expect(snapshot.empty, isNotEmpty);
  });

  test('Сделанная задача не считается в счётчике, но остаётся в списке', () {
    final snapshot = buildWidgetSnapshot(
      l: l,
      locale: 'ru',
      now: now,
      inheritance: inheritance,
      events: const [],
      tasks: [
        VTask(
          id: 't3',
          calendarId: 'home',
          title: 'Полить цветы',
          due: DateTime(2026, 7, 28, 7),
          completedAt: DateTime(2026, 7, 28, 8),
        ),
      ],
    );

    expect(snapshot.items.single.done, isTrue);
    expect(snapshot.count, '');
  });

  test('Событие на весь день идёт без времени', () {
    final snapshot = buildWidgetSnapshot(
      l: l,
      locale: 'ru',
      now: now,
      inheritance: inheritance,
      events: [
        VEvent(
          id: 'e2',
          calendarId: 'work',
          title: 'Отпуск',
          start: DateTime(2026, 7, 20),
          end: DateTime(2026, 8, 5),
        ),
      ],
      tasks: const [],
    );

    expect(snapshot.items.single.time, '');
  });
}
