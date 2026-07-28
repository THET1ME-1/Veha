import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/access/key_log_screen.dart';
import 'package:veha/features/color/color_picker_screen.dart';
import 'package:veha/features/color/branch_color_screen.dart';
import 'package:veha/features/repeat/repeat_advanced_screen.dart';
import 'package:veha/features/settings/month_settings_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  // Журнал приходит с сервера, а сервера в снимке нет: экран показывает пустое
  // состояние. Оно и проверяется — оно же и видно человеку без синхронизации.
  testWidgets('Журнал ключа', (tester) async {
    await pumpScreen(
      tester,
      const KeyLogScreen(keyId: 'k1', keyName: 'Claude'),
    );
    await shoot(tester, 'key_log');
  });

  testWidgets('Повторение · месяц и исключения', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: RepeatAdvancedScreen())),
    );
    await shoot(tester, 'repeat_advanced');
  });

  testWidgets('Пикер цвета', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: ColorPickerScreen(
            initial: Seed.mint,
            saved: const [
              Color(0xFF0F7B6C), Color(0xFFC2410C), Color(0xFF7C3AED),
              Color(0xFFBE123C), Color(0xFF0369A1), Color(0xFF4D7C0F),
              Color(0xFFA16207),
            ],
            recent: const [
              Seed.mint, Color(0xFF0F7B6C), Color(0xFFC2410C), Color(0xFF7C3AED),
              Color(0xFFBE123C), Color(0xFF0369A1), Color(0xFF4D7C0F),
              Color(0xFFA16207),
            ],
          ),
        ),
      ),
    );
    await shoot(tester, 'color_picker');
  });

  testWidgets('Цвет ветки', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SafeArea(
          child: BranchColorScreen(
            calendar: Seed.calendars.firstWhere((c) => c.id == 'c-study'),
            subcategory:
                Seed.subcategories.firstWhere((s) => s.id == 's-exam'),
            presets: const [
              Seed.mint, Seed.ocean, Seed.moss, Seed.amber, Seed.plum, Seed.clay,
            ],
            saved: const [
              Color(0xFF0F7B6C), Color(0xFFC2410C), Color(0xFF7C3AED),
              Color(0xFFBE123C), Color(0xFF0369A1), Color(0xFF4D7C0F),
            ],
          ),
        ),
      ),
    );
    await shoot(tester, 'branch_color');
  });

  testWidgets('Вид месяца', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: MonthSettingsScreen())),
    );
    await shoot(tester, 'month_settings');
  });
}
