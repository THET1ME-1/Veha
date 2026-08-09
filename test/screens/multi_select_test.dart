import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/calendar/views/clock_view.dart';
import 'package:veha/features/calendar/views/week_view.dart';

import 'golden_harness.dart';

/// Мультивыбор: пачку событий переносят и удаляют разом, а не по одному.
/// Отмеченный блок обязан отличаться заливкой — обводок в приложении нет.
void main() {
  setUpAll(loadAppFonts);

  const inheritance = Inheritance(
    calendars: {
      'home': VCalendar(
        id: 'home',
        name: 'Личное',
        iconName: 'restaurant',
        color: Color(0xFFC2410C),
      ),
    },
    subcategories: {},
  );

  VEvent lunch() => VEvent(
        id: 'lunch',
        calendarId: 'home',
        title: 'Обед с Ниной',
        start: DateTime(2026, 7, 27, 13),
        end: DateTime(2026, 7, 27, 14),
      );

  VEvent call() => VEvent(
        id: 'call',
        calendarId: 'home',
        title: 'Созвон',
        start: DateTime(2026, 7, 27, 15),
        end: DateTime(2026, 7, 27, 16),
      );

  Color? tintOf(WidgetTester tester, String key) {
    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byKey(ValueKey(key)),
            matching: find.byType(Container),
          )
          .first,
    );
    return (container.decoration as ShapeDecoration?)?.color;
  }

  testWidgets('Отмеченный блок часов красится заливкой выбора',
      (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch(), call()],
          inheritance: inheritance,
          selected: const {'call'},
          onEventTap: (_) {},
        ),
      ),
    );

    final scheme =
        Theme.of(tester.element(find.byType(ClockView))).colorScheme;

    expect(tintOf(tester, 'block-call'), scheme.primaryContainer);
    expect(tintOf(tester, 'block-lunch'), isNot(scheme.primaryContainer));
  });

  testWidgets('Отмеченная пилюля недели красится заливкой выбора',
      (tester) async {
    final week = [for (var i = 0; i < 7; i++) DateTime(2026, 7, 27 + i)];

    await pumpScreen(
      tester,
      Scaffold(
        body: WeekView(
          anchor: week.first,
          columns: week.length,
          eventsOf: (day) => day.day == 27 ? [lunch(), call()] : const [],
          spans: const [],
          inheritance: inheritance,
          today: DateTime(2026, 7, 27),
          selected: const {'lunch'},
          onEventTap: (_) {},
        ),
      ),
    );

    final scheme = Theme.of(tester.element(find.byType(WeekView))).colorScheme;

    expect(tintOf(tester, 'pill-lunch'), scheme.primaryContainer);
    expect(tintOf(tester, 'pill-call'), isNot(scheme.primaryContainer));
  });

  testWidgets('Пачка событий удаляется разом', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );

    // Английский стоит вечером и в кадр не попадает: лента лежит одной
    // колонкой, поэтому блок построен, но ниже экрана.
    await tester.ensureVisible(find.text('Английский').first);
    await tester.pumpAndSettle();

    // Вход в режим — из меню долгого нажатия: долгий жест в сетке уже занят
    // перетаскиванием, а тап открывает превью.
    await tester.longPress(find.text('Английский').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выбрать несколько'));
    await tester.pumpAndSettle();

    expect(find.text('Выбрано: 1'), findsOneWidget);

    // Второе событие дня отмечается обычным тапом. Планёрка идёт утром,
    // поэтому возвращаемся к началу ленты.
    await tester.ensureVisible(find.text('Планёрка').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Планёрка').first);
    await tester.pumpAndSettle();

    expect(find.text('Выбрано: 2'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bulk-delete')));
    await tester.pumpAndSettle();

    expect(find.text('Удалено событий: 2'), findsOneWidget);
    expect(find.text('Планёрка'), findsNothing);
    // Панель ушла вместе с выбором: удалять больше нечего.
    expect(find.textContaining('Выбрано:'), findsNothing);
  });

  testWidgets('Пачка переносится на завтра одним действием', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
    );

    await tester.longPress(find.text('Планёрка').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выбрать несколько'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('bulk-move')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('На завтра'));
    await tester.pumpAndSettle();

    expect(find.text('Перенесено событий: 1'), findsOneWidget);
    expect(find.text('Планёрка'), findsNothing,
        reason: 'Событие уехало с сегодняшнего дня');
  });
}
