import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/calendar/views/month_view.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Вид месяца настраивается с самого вида. Раньше режим был зашит константой,
/// а экран настройки не открывался ниоткуда.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openMonth(WidgetTester tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Месяц'));
    await tester.pumpAndSettle();
  }

  /// Настройка вида открывается долгим нажатием на активную пилюлю дока:
  /// отдельной кнопки внизу нет, там только переключатель и настройки.
  Future<void> openSetup(WidgetTester tester) async {
    await tester.longPress(find.text('Месяц'));
    await tester.pumpAndSettle();
  }

  MonthView monthOf(WidgetTester tester) =>
      tester.widget<MonthView>(find.byType(MonthView));

  testWidgets('По умолчанию полоски по числу дел', (tester) async {
    await openMonth(tester);
    expect(monthOf(tester).mode, MonthMode.bars);
  });

  testWidgets('Тонированные ячейки выбираются и доезжают до вида',
      (tester) async {
    await openMonth(tester);

    await openSetup(tester);
    await tester.tap(find.text('Тонированные ячейки'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(VehaIcons.byName('back')));
    await tester.pumpAndSettle();

    expect(monthOf(tester).mode, MonthMode.tint);
  });

  testWidgets('Событий в ячейке — настоящая настройка', (tester) async {
    await openMonth(tester);
    expect(monthOf(tester).maxChips, 2);

    await openSetup(tester);
    await tester.tap(find.text('Событий в ячейке'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(VehaIcons.byName('back')));
    await tester.pumpAndSettle();

    expect(monthOf(tester).maxChips, 4);
  });
}
