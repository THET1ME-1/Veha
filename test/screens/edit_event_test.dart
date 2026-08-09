import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Правка существующего события: открыл, поменял, сохранил — изменение
/// осталось. Проверяем и разовое событие, и занятие ряда.
void main() {
  setUpAll(loadAppFonts);

  Future<void> openEvent(WidgetTester tester, String title) async {
    await pumpScreen(tester, const HomeShell());
    await openEventEditor(tester, find.text(title));
  }

  testWidgets('Новое название разового события сохраняется', (tester) async {
    await openEvent(tester, 'Завтрак');

    await tester.enterText(find.byType(TextField).first, 'Поздний завтрак');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Поздний завтрак'), findsWidgets,
        reason: 'Новое название видно в дне');
    expect(find.text('Завтрак'), findsNothing, reason: 'Старого больше нет');
  });

  testWidgets('Правка переживает переоткрытие карточки', (tester) async {
    await openEvent(tester, 'Завтрак');

    await tester.enterText(find.byType(TextField).first, 'Поздний завтрак');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    await openEventEditor(tester, find.text('Поздний завтрак'));

    expect(find.text('Поздний завтрак'), findsWidgets,
        reason: 'Название приехало из базы, а не осталось на экране');
  });

  testWidgets('Отменённый выбор области не пропадает молча', (tester) async {
    await openEvent(tester, 'Подъём');

    await tester.enterText(find.byType(TextField).first, 'Подъём другой');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // Закрываем лист области, ничего не выбрав.
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    expect(find.text('Изменения не сохранены'), findsOneWidget);
  });

  testWidgets('Правка из вида «Неделя» сохраняется', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    // В узкой колонке недели знак уступает место названию, поэтому ищем
    // блок по имени занятия.
    await openEventEditor(tester, find.text('Завтрак'));

    await tester.enterText(find.byType(TextField).first, 'Кофе с Ниной');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Что изменить'), findsNothing,
        reason: 'Завтрак не повторяется, спрашивать нечего');
    expect(find.text('Кофе с Ниной'), findsWidgets);
  });

  testWidgets('Занятие ряда правится по выбранной области', (tester) async {
    await openEvent(tester, 'Подъём');

    await tester.enterText(find.byType(TextField).first, 'Подъём пораньше');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    // У занятия ряда спрашивают, что менять.
    expect(find.text('Что изменить'), findsOneWidget);
    await tester.tap(find.text('Только это занятие'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить').last);
    await tester.pumpAndSettle();

    expect(find.text('Подъём пораньше'), findsWidgets);
  });
}
