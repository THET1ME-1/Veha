import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/event/event_preview_sheet.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Поле, отмеченное «в карточке», человек отмечает ради того, чтобы видеть его
/// не открывая правку. Отбор жил только в сетке часов: лист события и лента дня
/// про свои поля не знали вовсе, и кабинет, ради которого отметку и ставили,
/// нигде не показывался.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Лист события показывает отмеченное поле', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showEventPreview(
                context,
                event: Seed.dayEvents.firstWhere((e) => e.id == 'e-lesson'),
                inheritance: Seed.inheritance,
                fieldDefs: {for (final f in Seed.fields) f.id: f},
              ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    expect(find.text('Кабинет'), findsOneWidget);
    expect(find.text('312'), findsOneWidget);
  });

  testWidgets('Лента дня показывает отмеченное поле в блоке', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.pumpAndSettle();
    expect(find.text('Урок'), findsWidgets);
    // Кабинет отмечен «в карточке», и лента обязана его показать: ради этого
    // отметку и ставят.
    expect(find.text('312'), findsWidgets);
  });
}
