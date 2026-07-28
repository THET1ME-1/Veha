import 'package:flutter_test/flutter_test.dart';
import 'package:veha/core/icon_registry.dart';
import 'package:veha/features/shell/home_shell.dart';

import 'golden_harness.dart';

void main() {
  setUpAll(loadAppFonts);

  testWidgets('День · часы, светлая', (tester) async {
    await pumpScreen(tester, const HomeShell());
    // Переключатель прочтения дня: вторая иконка — цепочка, первая — часы.
    await tester.tap(find.byIcon(VehaIcons.byName('clock')).first);
    await tester.pumpAndSettle();
    await shoot(tester, 'day_clock_light');
  });
}
