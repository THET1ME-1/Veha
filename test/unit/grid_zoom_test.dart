import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veha/data/settings.dart';

/// Масштаб сетки часов.
///
/// Щипок двумя пальцами растягивает час по вертикали: у кого день расписан
/// по четвертям, тому нужен крупный шаг, а кому важна вся картина дня —
/// мелкий. Границы жёсткие: ниже минимума пилюли сливаются в кашу, выше
/// максимума в экран не влезает и половина рабочего дня.
void main() {
  late VehaSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    settings = VehaSettings(await SharedPreferences.getInstance());
  });

  test('По умолчанию масштаб единичный', () {
    expect(settings.gridZoom, 1.0);
  });

  test('Выбранный масштаб переживает перезапуск', () async {
    await settings.setGridZoom(1.6);

    expect(settings.gridZoom, closeTo(1.6, 0.001));
  });

  test('За границы масштаб не уходит', () async {
    await settings.setGridZoom(9);
    expect(settings.gridZoom, VehaSettings.maxZoom);

    await settings.setGridZoom(0.05);
    expect(settings.gridZoom, VehaSettings.minZoom);
  });
}
