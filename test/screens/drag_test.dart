import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/views/clock_view.dart';

import 'golden_harness.dart';

/// Жесты в сетке часов: долгое нажатие отрывает блок, движение переносит его
/// шагом в пятнадцать минут, нижний край тянет длительность. Короткий тап при
/// этом обязан остаться тапом — иначе прокрутка дня превратится в переносы.
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

  testWidgets('Протяжка переносит событие шагом в четверть часа',
      (tester) async {
    Duration? shift;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    // Долгое нажатие: без него жест уходит в прокрутку.
    await tester.pump(const Duration(milliseconds: 700));
    // Высота часа — 60 логических пикселей.
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shift, const Duration(hours: 1));
  });

  testWidgets('Мелкое движение примагничивается к четверти часа',
      (tester) async {
    Duration? shift;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    // Восемнадцать пикселей — это восемнадцать минут; сетка округляет до
    // пятнадцати.
    await gesture.moveBy(const Offset(0, 18));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(shift, const Duration(minutes: 15));
  });

  testWidgets('Блок у нижнего края крутит сетку сам', (tester) async {
    // День от восьми утра до девяти вечера выше экрана: без автоскролла
    // перенести утреннюю встречу на вечер нельзя вовсе — палец упирается
    // в край, а сетка стоит.
    final day = [
      lunch(),
      VEvent(
        id: 'evening',
        calendarId: 'home',
        title: 'Вечерняя тренировка',
        start: DateTime(2026, 7, 27, 20),
        end: DateTime(2026, 7, 27, 21),
      ),
      VEvent(
        id: 'morning',
        calendarId: 'home',
        title: 'Планёрка',
        start: DateTime(2026, 7, 27, 8),
        end: DateTime(2026, 7, 27, 9),
      ),
    ];

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: day,
          inheritance: inheritance,
          onEventMoved: (_, __) {},
        ),
      ),
    );

    final position =
        tester.state<ScrollableState>(find.byType(Scrollable)).position;
    expect(position.maxScrollExtent, greaterThan(0),
        reason: 'день обязан не помещаться на экран, иначе тест бессмыслен');
    final before = position.pixels;

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    // Палец у самого низа экрана: там и начинается разгон.
    await gesture.moveTo(Offset(tester.view.physicalSize.width / 4, 838));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 200));

    expect(position.pixels, greaterThan(before));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('Отпущенный блок сетку не крутит', (tester) async {
    final day = [
      lunch(),
      VEvent(
        id: 'evening',
        calendarId: 'home',
        title: 'Вечерняя тренировка',
        start: DateTime(2026, 7, 27, 20),
        end: DateTime(2026, 7, 27, 21),
      ),
    ];

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: day,
          inheritance: inheritance,
          onEventMoved: (_, __) {},
        ),
      ),
    );

    final position =
        tester.state<ScrollableState>(find.byType(Scrollable)).position;

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveTo(const Offset(120, 838));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    final settled = position.pixels;
    await tester.pump(const Duration(milliseconds: 300));

    expect(position.pixels, settled);
  });

  testWidgets('Соседнее событие подсвечивается, пока блок метит в него',
      (tester) async {
    // Сообщение о накладке приходило после переноса — когда чинить поздно.
    // Пока блок в воздухе, видно, во что он метит.
    final day = [
      lunch(),
      VEvent(
        id: 'call',
        calendarId: 'home',
        title: 'Созвон',
        start: DateTime(2026, 7, 27, 15),
        end: DateTime(2026, 7, 27, 16),
      ),
    ];

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: day,
          inheritance: inheritance,
          onEventMoved: (_, __) {},
        ),
      ),
    );

    final scheme =
        Theme.of(tester.element(find.byType(ClockView))).colorScheme;

    Color? tintOf(String id) {
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byKey(ValueKey('block-$id')),
              matching: find.byType(Container),
            )
            .first,
      );
      return (container.decoration as ShapeDecoration?)?.color;
    }

    expect(tintOf('call'), isNot(scheme.errorContainer));

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    // Два часа вниз — обед метит ровно в созвон.
    await gesture.moveBy(const Offset(0, 120));
    await tester.pump(const Duration(milliseconds: 40));

    expect(tintOf('call'), scheme.errorContainer);

    // Отвели назад — подсветка гаснет, накладки больше нет.
    await gesture.moveBy(const Offset(0, -120));
    await tester.pump(const Duration(milliseconds: 40));

    expect(tintOf('call'), isNot(scheme.errorContainer));

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('Короткий тап остаётся тапом', (tester) async {
    var moved = false;
    VEvent? tapped;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          onEventTap: (e) => tapped = e,
          onEventMoved: (_, __) => moved = true,
        ),
      ),
    );

    await tester.tap(find.text('Обед с Ниной'));
    await tester.pumpAndSettle();

    expect(tapped?.id, 'lunch');
    expect(moved, isFalse);
  });

  testWidgets('Меню долгого нажатия не отбирает жест у перетаскивания',
      (tester) async {
    Duration? shift;
    var menuOpened = false;

    await pumpScreen(
      tester,
      Scaffold(
        body: ClockView(
          events: [lunch()],
          inheritance: inheritance,
          // Ровно как в приложении: у блока есть и меню, и перетаскивание.
          onEventLongPress: (_) => menuOpened = true,
          onEventMoved: (_, value) => shift = value,
        ),
      ),
    );

    final gesture =
        await tester.startGesture(tester.getCenter(find.text('Обед с Ниной')));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveBy(const Offset(0, 60));
    await tester.pump(const Duration(milliseconds: 40));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(menuOpened, isFalse,
        reason: 'меню открылось поверх блока, и тащить стало нечего');
    expect(shift, const Duration(hours: 1));
  });
}
