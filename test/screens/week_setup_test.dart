import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/calendar/views/week_view.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Неделя из семи колонок нужна не всем: у сменного графика она из трёх дней,
/// у студента — из пяти будних.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openWeek(WidgetTester tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();
  }

  int columnsOf(WidgetTester tester) =>
      tester.widget<WeekView>(find.byType(WeekView)).columns;

  testWidgets('По умолчанию неделя из семи колонок', (tester) async {
    await openWeek(tester);
    expect(columnsOf(tester), 7);
  });

  testWidgets('Будни оставляют пять колонок', (tester) async {
    await openWeek(tester);

    // Настройка вида открывается долгим нажатием на активную пилюлю дока.
    await tester.longPress(find.text('Неделя'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Будни'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(columnsOf(tester), 5);
  });

  testWidgets('Снимок настройки недели', (tester) async {
    await openWeek(tester);

    // Настройка вида открывается долгим нажатием на активную пилюлю дока.
    await tester.longPress(find.text('Неделя'));
    await tester.pumpAndSettle();

    await shoot(tester, 'week_setup');
  });
}
