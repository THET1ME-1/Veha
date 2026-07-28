import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/features/access/access_screen.dart';

import 'golden_harness.dart';

// Экран календарей переехал на базу, и снимок у него свой —
// `calendars_test.dart`. Здесь остался только доступ для ИИ.
void main() {
  setUpAll(loadAppFonts);

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
