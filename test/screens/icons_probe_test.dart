import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  // Снимок берём с ходового ряда: четыре тысячи глифов в один кадр не лезут,
  // а проверяем мы одно — что глиф рисуется, а не квадрат-заглушка.
  test('В наборе весь Material Symbols', () {
    expect(VehaIcons.names.length, greaterThan(4000));
    expect(VehaIcons.byName('scuba_diving'), isNot(VehaIcons.byName('circle')));
    // Короткие имена старых записей продолжают работать.
    expect(VehaIcons.byName('fitness'), VehaIcons.byName('fitness_center'));
  });

  testWidgets('Реестр иконок', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final n in VehaIcons.pickable)
                SizedBox(
                  width: 80,
                  child: Column(children: [
                    Icon(VehaIcons.byName(n), size: 26),
                    Text(n, style: const TextStyle(fontSize: 9)),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
    await shoot(tester, 'icons_probe');
  });
}
