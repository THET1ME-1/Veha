import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Путь события целиком: кнопка → лист → база → карточка в дне.
///
/// Проверять по частям бессмысленно: ломается обычно связка, а не отдельный
/// виджет.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Событие из быстрого листа появляется в дне', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Название'), findsOneWidget,
        reason: 'Лист открылся с пустым названием');

    await tester.enterText(find.byType(TextField), 'Стрижка');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Стрижка'), findsWidgets,
        reason: 'Событие сохранено и видно в дне');
  });

  testWidgets('Быстрый лист отдаёт черновик полной форме', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Экзамен');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    expect(find.text('Экзамен'), findsWidgets,
        reason: 'Набранное название доехало до полной формы');
    expect(find.text('Сохранить'), findsOneWidget);
  });

  testWidgets('Выбранное напоминание доезжает до карточки', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Приём у врача');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    // По умолчанию событие предупреждает за полчаса.
    expect(find.text('За 30 минут'), findsOneWidget);

    await tester.tap(find.text('Напоминание'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('За день'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('За день · за 30 минут'), findsOneWidget,
        reason: 'Оба срока показаны от дальнего к ближнему');

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Приём у врача').first);
    await tester.pumpAndSettle();

    expect(find.text('За день · за 30 минут'), findsOneWidget,
        reason: 'Напоминания дошли до базы и вернулись в карточку события');
  });

  testWidgets('Своё поле заполняется и доезжает до базы', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Пересдача');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    // «Кабинет» — своё поле группы «Учёба», куда попадает новое событие.
    await tester.scrollUntilVisible(find.text('Кабинет'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Кабинет'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '415');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('415'), findsOneWidget);

    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Пересдача').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('415'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('415'), findsOneWidget,
        reason: 'Значение дошло до базы и вернулось в форму');
  });

  testWidgets('Заметка заводится и остаётся у события', (tester) async {
    await pumpScreen(tester, const HomeShell());

    // Правка существующего события: у нового ключа ещё нет, и заметке не к
    // чему привязаться.
    await tester.tap(find.text('Завтрак').first);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Добавить заметку'), 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Добавить заметку'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Купить кофе');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    expect(find.text('Купить кофе'), findsOneWidget,
        reason: 'Заметка ушла в базу и вернулась потоком');
  });

  testWidgets('Снимок быстрого листа', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Английский');
    await tester.pumpAndSettle();

    await shoot(tester, 'quick_add');
  });

  testWidgets('Снимок полной формы', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Английский');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Подробнее'));
    await tester.pumpAndSettle();

    await shoot(tester, 'event_form');
  });
}
