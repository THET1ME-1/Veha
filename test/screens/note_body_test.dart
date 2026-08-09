import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/calendar/calendar_screen.dart';
import 'package:veha/features/event/note_body.dart';

import 'golden_harness.dart';

/// Заметка со списками и ссылками: галочка отмечается прямо в карточке,
/// не открывая правку, а адрес — нажимаемый.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Галочка отмечается тапом по своей строке', (tester) async {
    int? toggled;

    await pumpScreen(
      tester,
      Scaffold(
        body: NoteBody(
          text: '[ ] Позвонить\nЗаехать за тортом\n[x] Купить билет',
          ink: const Color(0xFFC2410C),
          onToggle: (index) => toggled = index,
        ),
      ),
    );

    // Отмеченный пункт нарисован галочкой, неотмеченный — пустой рамкой.
    expect(find.byIcon(VehaIcons.byName('check_box')), findsOneWidget);
    expect(find.byIcon(VehaIcons.byName('check_box_outline_blank')), findsOneWidget);

    await tester.tap(find.text('Купить билет'));
    await tester.pumpAndSettle();

    expect(toggled, 2, reason: 'Номер строки в исходном тексте');
  });

  testWidgets('Обычная строка галочку не переключает', (tester) async {
    var toggles = 0;

    await pumpScreen(
      tester,
      Scaffold(
        body: NoteBody(
          text: '[ ] Позвонить\nЗаехать за тортом',
          ink: const Color(0xFFC2410C),
          onToggle: (_) => toggles++,
        ),
      ),
    );

    await tester.tap(find.text('Заехать за тортом'));
    await tester.pumpAndSettle();

    expect(toggles, 0);
  });

  testWidgets('Ссылка открывается тапом', (tester) async {
    String? opened;

    await pumpScreen(
      tester,
      Scaffold(
        body: NoteBody(
          text: 'Созвон тут https://meet.example/room-7 в 15:00',
          ink: const Color(0xFFC2410C),
          onLink: (url) => opened = url,
        ),
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('meet.example'));
    await tester.pumpAndSettle();

    expect(opened, 'https://meet.example/room-7');
  });

  testWidgets('Отметка пункта уходит в базу из формы события',
      (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: CalendarScreen())),
      seed: (repo) async {
        await repo.upsertNote(const VNote(
          id: 'n-cake',
          eventId: 'e-lunch',
          text: '[ ] Купить торт\n[ ] Забрать заказ',
        ));
      },
    );

    await openEventEditor(tester, find.text('Обед с Ниной'));

    // Заметки лежат ниже описания и своих полей — до них надо доскроллить.
    await tester.dragUntilVisible(
      find.text('Купить торт'),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Купить торт'));
    await tester.pumpAndSettle();

    // Карточка перерисовалась из базы: не сохранись отметка, стрим бы
    // ничего не принёс и галочка осталась бы пустой.
    expect(find.byIcon(VehaIcons.byName('check_box')), findsOneWidget);
    expect(find.byIcon(VehaIcons.byName('check_box_outline_blank')),
        findsOneWidget);
  });
}
