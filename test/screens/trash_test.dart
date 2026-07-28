import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/models.dart';
import 'package:veha/features/settings/trash_screen.dart';

import 'golden_harness.dart';

/// Корзина: удалённое видно и возвращается одним нажатием.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Удалённое лежит в корзине и возвращается', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: TrashScreen())),
      seed: (repo) async {
        await repo.upsertEvent(VEvent(
          id: 'gone',
          calendarId: 'c-home',
          title: 'Ужин у Нины',
          start: testNow.add(const Duration(days: 1, hours: 9)),
          end: testNow.add(const Duration(days: 1, hours: 11)),
        ));
        await repo.deleteEvent('gone');

        await repo.upsertTask(const VTask(
          id: 'gone-task',
          calendarId: 'c-work',
          title: 'Отменённая задача',
        ));
        await repo.deleteTask('gone-task');
      },
    );

    expect(find.text('Ужин у Нины'), findsOneWidget);
    expect(find.text('Отменённая задача'), findsOneWidget);

    await tester.tap(find.text('Вернуть').first);
    await tester.pumpAndSettle();

    expect(find.text('Ужин у Нины'), findsNothing,
        reason: 'Вернулось на своё место и из корзины исчезло');

    await shoot(tester, 'trash');
  });
}
