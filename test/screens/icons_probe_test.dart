import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('реестр иконок', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final n in VehaIcons.names)
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
