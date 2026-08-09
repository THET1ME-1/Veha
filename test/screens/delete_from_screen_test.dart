import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Удаление события так, как его делает человек: из ленты дня, а не вызовом
/// репозитория. Между тапом и базой лежат превью, лист действий и поток
/// правки — сломаться может любой из них, а выглядит это одинаково: «пишет,
/// что удалено, а событие на месте».
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Разовое событие уходит с экрана', (tester) async {
    await pumpScreen(
      tester,
      const HomeShell(),
    );

    expect(find.text('Урок'), findsWidgets);

    await tester.longPress(find.text('Урок').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Удалить событие').last);
    await tester.pumpAndSettle();

    expect(find.text('Урок'), findsNothing);
  });

  testWidgets('Занятие ряда отменяется из меню', (tester) async {
    await pumpScreen(tester, const HomeShell());

    expect(find.text('Планёрка'), findsWidgets);

    await tester.longPress(find.text('Планёрка').first);
    await tester.pumpAndSettle();

    // У занятия ряда своё действие: отменить именно этот день.
    await tester.tap(find.textContaining('Отменить').last);
    await tester.pumpAndSettle();

    expect(find.text('Планёрка'), findsNothing);
  });

  testWidgets('Ряд удаляется целиком из меню', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.longPress(find.text('Планёрка').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Удалить весь ряд').last);
    await tester.pumpAndSettle();

    expect(find.text('Планёрка'), findsNothing);
  });
}
