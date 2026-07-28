import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/access/access_screen.dart';

import 'golden_harness.dart';

// Экран календарей переехал на базу, и снимок у него свой —
// `calendars_test.dart`. Здесь остался только доступ для ИИ.
void main() {
  setUpAll(loadAppFonts);

  // Без синхронизации ключей нет и быть не может: календарь, который живёт
  // только на телефоне, снаружи недоступен.
  testWidgets('Доступ для ИИ', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: AccessScreen())),
    );
    await shoot(tester, 'access');
  });
}

