import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/event/history_sheet.dart';

import 'golden_harness.dart';

/// Вложения и история правок: и то и другое живёт только на устройстве —
/// сервер хранит записи и отдаёт дельты, файлов и журнала у него нет.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Приложенный файл виден в форме события', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
      seed: (repo) async {
        await repo.addFile(VFile(
          id: 'f1',
          eventId: 'e-lunch',
          path: 'files/f1.pdf',
          name: 'Меню.pdf',
          size: 24576,
          addedAt: DateTime(2026, 7, 27, 12),
        ));
      },
    );

    await openEventEditor(tester, find.text('Обед с Ниной'));
    await tester.dragUntilVisible(
      find.text('Меню.pdf'),
      find.byType(ListView).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    expect(find.text('Меню.pdf'), findsOneWidget);
    expect(find.text('ВЛОЖЕНИЯ'), findsOneWidget);
  });

  testWidgets('История показывает, что событие переносили', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
      seed: (repo) async {
        final lunch = await repo.eventById('e-lunch');
        await repo.upsertEvent(lunch!.copyWith(
          start: lunch.start.add(const Duration(hours: 2)),
          end: lunch.end.add(const Duration(hours: 2)),
          title: 'Обед с Ниной и Петей',
        ));
      },
    );

    await openEventEditor(tester, find.text('Обед с Ниной и Петей'));
    await tester.dragUntilVisible(
      find.text('История изменений'),
      find.byType(ListView).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('История изменений'));
    await tester.pumpAndSettle();

    // Демо-события кладутся в базу посевом, а не рукой человека, — записи
    // «заведено» у них нет. Зато обе правки видны с обеими сторонами.
    expect(find.textContaining('Время'), findsWidgets);
    expect(find.textContaining('Название'), findsWidgets);
    expect(find.textContaining('Обед с Ниной → Обед с Ниной и Петей'),
        findsOneWidget);
  });

  testWidgets('Снимок истории', (tester) async {
    // На фиксированных правках, а не на живых: время записи берётся из часов
    // машины, и снимок с ним расходился бы на каждой минуте.
    await pumpScreen(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showEventHistory(context, history: [
              VRevision(
                id: 'r3',
                eventId: 'e1',
                at: DateTime(2026, 7, 27, 9, 15),
                kind: RevisionKind.time,
                before: '2026-07-27T13:00:00|2026-07-27T14:00:00',
                after: '2026-07-27T15:00:00|2026-07-27T16:00:00',
              ),
              VRevision(
                id: 'r2',
                eventId: 'e1',
                at: DateTime(2026, 7, 26, 20, 40),
                kind: RevisionKind.place,
                before: null,
                after: 'Кофейня на Штефана',
              ),
              VRevision(
                id: 'r1',
                eventId: 'e1',
                at: DateTime(2026, 7, 26, 20, 38),
                kind: RevisionKind.created,
                after: 'Обед с Ниной',
              ),
            ]),
            child: const Text('Открыть'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Открыть'));
    await tester.pumpAndSettle();

    await shoot(tester, 'event_history');
  });
}
