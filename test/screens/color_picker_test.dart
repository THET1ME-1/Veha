import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/brand.dart';
import 'package:veha/features/color/color_picker_screen.dart';

import 'golden_harness.dart';

/// Экран «Свой цвет» был витриной: кнопка «В мои» ничего не сохраняла, код
/// нельзя было ни ввести, ни скопировать, пипетка не открывалась. Сторож
/// проверяет ровно это — три нажатия, которые раньше не делали ничего.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Кнопка «В мои» кладёт цвет в базу', (tester) async {
    await pumpScreen(tester, const ColorPickerScreen(initial: VehaBrand.seed));

    expect(find.text('В мои'), findsOneWidget);
    await tester.tap(find.text('В мои'));
    await tester.pumpAndSettle();

    // Кнопка на том же месте докладывает, что цвет уже сохранён, а внизу
    // появился блок «Мои цвета».
    expect(find.text('Цвет в «Моих»'), findsWidgets);
    expect(find.text('МОИ ЦВЕТА'), findsOneWidget);

    // Повторное нажатие убирает: отдельной кнопки удаления нет.
    await tester.tap(find.text('Цвет в «Моих»').first);
    await tester.pumpAndSettle();
    expect(find.text('В мои'), findsOneWidget);
  });

  testWidgets('Свой код вписывается и меняет цвет', (tester) async {
    await pumpScreen(tester, const ColorPickerScreen(initial: VehaBrand.seed));

    final field = find.byType(TextField);
    expect(field, findsOneWidget, reason: 'Код вводится, а не только читается');

    await tester.enterText(field, 'C2410C');
    await tester.pumpAndSettle();

    // Читаемая подпись сверху пересчиталась под новый цвет.
    expect(find.text('#C2410C'), findsOneWidget);
  });

  testWidgets('Код уходит в буфер обмена', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await pumpScreen(tester, const ColorPickerScreen(initial: VehaBrand.seed));

    await tester.tap(find.byTooltip('Скопировать код'));
    await tester.pumpAndSettle();

    expect(copied, ['#41CCB5']);
  });

  testWidgets('Снимок экрана «Свой цвет»', (tester) async {
    await pumpScreen(tester, const ColorPickerScreen(initial: VehaBrand.seed));
    await shoot(tester, 'color_picker_live');
  });
}
