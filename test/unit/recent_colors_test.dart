import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veha/data/settings.dart';

/// Последние использованные цвета.
///
/// ТЗ обещает двенадцать последних, которые заполняются сами. Пикер их умел
/// показывать, но список ему никто не передавал — строка «Последние» не
/// появлялась никогда, и человек каждый раз собирал цвет заново.
void main() {
  late VehaSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    settings = VehaSettings(await SharedPreferences.getInstance());
  });

  test('Выбранный цвет встаёт первым', () async {
    await settings.pushRecentColor(0xFF41CCB5);
    await settings.pushRecentColor(0xFFFF7E9B);

    expect(settings.recentColors, [0xFFFF7E9B, 0xFF41CCB5]);
  });

  test('Повтор не плодит копию, а поднимается наверх', () async {
    await settings.pushRecentColor(0xFF41CCB5);
    await settings.pushRecentColor(0xFFFF7E9B);
    await settings.pushRecentColor(0xFF41CCB5);

    expect(settings.recentColors, [0xFF41CCB5, 0xFFFF7E9B]);
  });

  test('Больше двенадцати не хранится: это кеш поведения, а не архив',
      () async {
    for (var i = 0; i < 20; i++) {
      await settings.pushRecentColor(0xFF000000 + i);
    }

    expect(settings.recentColors, hasLength(12));
    expect(settings.recentColors.first, 0xFF000000 + 19);
  });
}
