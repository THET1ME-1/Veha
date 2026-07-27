import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/data/seed.dart';
import 'package:veha/features/access/access_screen.dart';
import 'package:veha/features/calendars/calendars_screen.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Календари и ветки', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(body: SafeArea(child: CalendarsScreen(inheritance: Seed.inheritance))),
    );
    await shoot(tester, 'calendars');
  });

  testWidgets('Доступ для ИИ', (tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: SafeArea(child: AccessScreen(keys: demoAccessKeys))),
    );
    await shoot(tester, 'access');
  });
}

const demoAccessKeys = [
  AccessKey(
    name: 'Claude · планировщик',
    prefix: 'cal_a8f3k2 · · · · · ·',
    scopes: [('Личное', false), ('Учёба', true), ('Спорт', false)],
    lastUsed: 'Работал 12 минут назад',
    expires: 'до 30 сентября',
  ),
  AccessKey(
    name: 'Домашний ассистент',
    prefix: 'cal_7z1qm4 · · · · · ·',
    scopes: [('Дом', false), ('Бессрочно', false)],
    lastUsed: 'Работал вчера в 21:03',
  ),
  AccessKey(
    name: 'Пробный ключ',
    prefix: 'отозван 24 июля',
    scopes: [],
    lastUsed: '',
    revoked: true,
  ),
];
