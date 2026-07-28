import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/event/event_cover.dart';
import 'package:veha/features/event/event_screen.dart';

import 'golden_harness.dart';

/// Снимок фоном карточки: сквозь заливку он должен читаться, а буквы поверх
/// него — оставаться читаемыми. Проверяется картинкой, потому что глазами
/// такое и ловится.
///
/// Картинка подставляется из памяти: `FileImage` в `flutter_test` до декодера
/// не доходит, и снимок выходит с пустой обложкой — проверять было бы нечего.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('Событие со снимком на обложке', (tester) async {
    final event = Seed.dayEvents.firstWhere((e) => e.id == 'e-eng');

    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: EventScreen(event: event, inheritance: Seed.inheritance),
        ),
      ),
      overrides: [
        coverProvider(event.id).overrideWithValue(
          MemoryImage(
            File('test/screens/fixtures/cover.png').readAsBytesSync(),
          ),
        ),
      ],
    );
    await shoot(tester, 'event_cover');
  });
}
