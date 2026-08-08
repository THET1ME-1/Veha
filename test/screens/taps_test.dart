import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/calendar/views/chain_view.dart';
import 'package:veha/features/calendar/views/month_view.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Нажимается всё, что выглядит нажимаемым. Молчащий блок человек считает
/// сломанным приложением, а не незаконченной функцией.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openView(WidgetTester tester, String name) async {
    await pumpScreen(tester, const HomeShell());
    await openEventEditor(tester, find.text(name));
  }

  testWidgets('Событие в неделе открывается тапом', (tester) async {
    await openView(tester, 'Неделя');

    // Пилюли недели — одни иконки: у английского это шапочка.
    await openEventEditor(tester, find.byIcon(VehaIcons.byName('school')).first);

    expect(find.text('Сохранить'), findsOneWidget,
        reason: 'Открылась форма события');
  });

  testWidgets('Полоса многодневного события открывается тапом', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await openEventEditor(tester, find.text('Абонемент в бассейн').first);

    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Тап по дню в месяце раскрывает лист, а не уводит из месяца',
      (tester) async {
    await openView(tester, 'Месяц');
    expect(find.byType(MonthView), findsOneWidget);

    await tester.tap(find.text('30').first);
    await tester.pumpAndSettle();

    // Месяц отвечает на «когда»: подробности показывает лист, а картина
    // месяца остаётся под ним.
    expect(find.byType(MonthView), findsOneWidget, reason: 'Месяц на месте');
    expect(find.text('Открыть день'), findsOneWidget, reason: 'Лист открыт');

    await tester.tap(find.text('Открыть день'));
    await tester.pumpAndSettle();
    expect(find.byType(ChainView), findsOneWidget, reason: 'Открыт день');
  });
}
