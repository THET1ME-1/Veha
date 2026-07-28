import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  // Сторож среды, а не экрана. Отписка от стрима drift заводит `Timer.run`,
  // чтобы придержать кеш запроса ещё один оборот цикла событий. В тестах часы
  // поддельные, таймер не тикает, и `db.close()` ждёт его вечно — тест виснет
  // молча, без строчки в логе. Разбирать дерево здесь надо руками: иначе
  // зависание случится уже после тела, когда рассказать о нём некому.
  testWidgets('Разбор экрана не оставляет таймеров drift', (tester) async {
    await pumpScreen(tester, const HomeShell());
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
