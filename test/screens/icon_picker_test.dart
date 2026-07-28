import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/common/icon_picker_sheet.dart';

import 'golden_harness.dart';

/// Выбор иконки из всего набора. Ходовые сразу, остальные — поиском.
void main() {
  setUpAll(loadAppFonts);

  Future<void> open(WidgetTester tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => askIcon(context),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
  }

  testWidgets('Открывается ходовым рядом', (tester) async {
    await open(tester);
    expect(find.text('Ходовые'), findsOneWidget);
    expect(find.byIcon(VehaIcons.byName('school')), findsOneWidget);
  });

  testWidgets('Поиск находит иконку не из ходовых', (tester) async {
    await open(tester);
    expect(find.byIcon(VehaIcons.byName('scuba_diving')), findsNothing);

    await tester.enterText(find.byType(TextField), 'scuba');
    await tester.pumpAndSettle();

    expect(find.byIcon(VehaIcons.byName('scuba_diving')), findsOneWidget);
  });

  testWidgets('Выбранная иконка возвращается', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'rocket');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(VehaIcons.byName('rocket')).first);
    await tester.pumpAndSettle();

    expect(find.text('Ходовые'), findsNothing, reason: 'Лист закрылся');
  });

  testWidgets('Снимок выбора иконки', (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField), 'cat');
    await tester.pumpAndSettle();
    await shoot(tester, 'icon_picker');
  });
}
