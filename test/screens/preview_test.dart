import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/event/event_preview_sheet.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

/// Тап по событию открывал форму правки: посмотреть место человек шёл туда же,
/// куда и менять время, и каждый раз рисковал задеть лишнее. Теперь тап
/// показывает превью с действиями.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Тап по событию открывает превью, а не форму', (tester) async {
    await pumpScreen(tester, const HomeShell());

    await tester.tap(find.text('Планёрка').first);
    await tester.pumpAndSettle();

    // Заголовки блоков в приложении набраны прописными.
    expect(find.text('ПЕРЕНЕСТИ'), findsOneWidget);
    expect(find.text('На завтра'), findsOneWidget);
    expect(find.text('Сделать копию'), findsOneWidget);
    expect(find.text('Изменить'), findsOneWidget);
  });

  testWidgets('Снимок превью события', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showEventPreview(
                context,
                event: Seed.dayEvents.firstWhere((e) => e.id == 'e-eng'),
                inheritance: Seed.inheritance,
              ),
              child: const Text('Открыть'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();
    await shoot(tester, 'event_preview');
  });
}
