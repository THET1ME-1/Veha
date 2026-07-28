import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/week_layout.dart';

/// Пользовательские настройки вида.
///
/// Живут в `SharedPreferences`, а не в базе: они принадлежат устройству, а не
/// календарю, и на сервер не уезжают — на чужом телефоне у человека может быть
/// другая привычная неделя.
class VehaSettings {
  VehaSettings(this._prefs);

  final SharedPreferences _prefs;

  static const _weekLayout = 'week_layout';
  static const _dayReading = 'day_reading';
  static const _monthMode = 'month_mode';

  WeekLayout get weekLayout => WeekLayout.decode(_prefs.getString(_weekLayout));

  Future<void> setWeekLayout(WeekLayout value) =>
      _prefs.setString(_weekLayout, value.encode());

  /// Какое прочтение дня человек оставил открытым: часы или цепочка.
  int get dayReading => _prefs.getInt(_dayReading) ?? 0;

  Future<void> setDayReading(int value) => _prefs.setInt(_dayReading, value);

  int get monthMode => _prefs.getInt(_monthMode) ?? 0;

  Future<void> setMonthMode(int value) => _prefs.setInt(_monthMode, value);
}

/// Настройки читаются один раз при запуске: дальше синхронный доступ.
final settingsProvider = FutureProvider<VehaSettings>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return VehaSettings(prefs);
});

/// Раскладка недели отдельным состоянием: вид перерисовывается сразу, а запись
/// в хранилище идёт следом и экрану не мешает.
class WeekLayoutNotifier extends StateNotifier<WeekLayout> {
  WeekLayoutNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(WeekLayout value) async {
    state = value;
    await _settings?.setWeekLayout(value);
  }
}

final weekLayoutProvider =
    StateNotifierProvider<WeekLayoutNotifier, WeekLayout>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return WeekLayoutNotifier(settings, settings?.weekLayout ?? WeekLayout.full);
});
