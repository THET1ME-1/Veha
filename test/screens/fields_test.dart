import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/common/blocks.dart';
import 'package:veha/features/fields/fields_screen.dart';

import 'golden_harness.dart';

/// Свои поля живут в базе: заведение, правка и тумблер «в карточке» идут туда
/// же, откуда карточки события берут определения.
void main() {
  setUpAll(loadAppFonts);

  final study = Seed.calendars.firstWhere((c) => c.id == 'c-study');

  testWidgets('Поля по группам', (tester) async {
    await pumpScreen(tester, const FieldGroupsScreen());
    await shoot(tester, 'fields_groups');
  });

  testWidgets('Поля группы «Учёба»', (tester) async {
    await pumpScreen(tester, FieldsOfGroupScreen(calendar: study));
    await shoot(tester, 'fields_study');
  });

  testWidgets('Снимок листа нового поля', (tester) async {
    await pumpScreen(tester, FieldsOfGroupScreen(calendar: study));

    await tester.tap(find.text('Добавить поле в «Учёба»'));
    await tester.pumpAndSettle();

    await shoot(tester, 'field_editor');
  });

  testWidgets('Заведённое поле появляется в группе', (tester) async {
    await pumpScreen(tester, FieldsOfGroupScreen(calendar: study));

    await tester.tap(find.text('Добавить поле в «Учёба»'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'Аудитория');
    await tester.pumpAndSettle();
    // «Число» есть и в подписях полей за листом — чип выбора идёт последним.
    await tester.tap(find.text('Число').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();

    // Новое поле встаёт последним, а список строит только видимое.
    await tester.scrollUntilVisible(find.text('Аудитория'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Аудитория'), findsOneWidget);
  });

  testWidgets('Тумблер «в карточке» идёт в базу', (tester) async {
    await pumpScreen(tester, FieldsOfGroupScreen(calendar: study));
    expect(find.textContaining('в карточке 4'), findsOneWidget);

    // Строка целиком — это InkWell: ближайший Row держит только имя с плашкой,
    // тумблер лежит уровнем выше.
    final row = find
        .ancestor(of: find.text('Абонемент'), matching: find.byType(InkWell))
        .first;
    await tester.tap(find.descendant(of: row, matching: find.byType(VSwitch)));
    await tester.pumpAndSettle();

    // Счётчик в шапке считается по данным из базы, а не по состоянию экрана:
    // выросло — значит правка дошла до базы и вернулась потоком.
    expect(find.textContaining('в карточке 5'), findsOneWidget);
  });
}
