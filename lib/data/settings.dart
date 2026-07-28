import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/brand.dart';
import '../domain/week_layout.dart';
import '../features/calendar/views/month_view.dart' show MonthMode;
import '../features/calendar/widgets/month_header.dart' show DayReading;

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
  static const _monthChips = 'month_chips';
  static const _themeMode = 'theme_mode';
  static const _vibrant = 'vibrant';
  static const _seed = 'seed';
  static const _locale = 'locale';

  /// 0 — как в системе, 1 — светлая, 2 — тёмная.
  int get themeMode => _prefs.getInt(_themeMode) ?? 0;

  Future<void> setThemeMode(int value) => _prefs.setInt(_themeMode, value);

  /// Режим генерации схемы. На фирменном оттенке 182° «Сочно» выкручивает
  /// `primaryContainer` до кислотной мяты, поэтому по умолчанию «Точь-в-точь».
  bool get vibrant => _prefs.getBool(_vibrant) ?? false;

  Future<void> setVibrant(bool value) => _prefs.setBool(_vibrant, value);

  /// Цвет, из которого строится схема. Ноль — фирменная мята.
  int get seed => _prefs.getInt(_seed) ?? 0;

  Future<void> setSeed(int value) => _prefs.setInt(_seed, value);

  /// Пустая строка — язык системы.
  String get locale => _prefs.getString(_locale) ?? '';

  Future<void> setLocale(String value) => _prefs.setString(_locale, value);

  WeekLayout get weekLayout => WeekLayout.decode(_prefs.getString(_weekLayout));

  Future<void> setWeekLayout(WeekLayout value) =>
      _prefs.setString(_weekLayout, value.encode());

  /// Какое прочтение дня человек оставил открытым: часы или цепочка.
  /// `null` — не выбирал ни разу; умолчание решает не хранилище.
  int? get dayReading => _prefs.getInt(_dayReading);

  Future<void> setDayReading(int value) => _prefs.setInt(_dayReading, value);

  int get monthMode => _prefs.getInt(_monthMode) ?? 0;

  Future<void> setMonthMode(int value) => _prefs.setInt(_monthMode, value);

  /// Сколько событий показывать в ячейке месяца, дальше — «+N».
  int get monthChips => _prefs.getInt(_monthChips) ?? 2;

  Future<void> setMonthChips(int value) => _prefs.setInt(_monthChips, value);
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

/// Вид месяца отдельным состоянием, как и неделя: выбор человека переживает
/// закрытие приложения, иначе настройка бессмысленна.
class MonthModeNotifier extends StateNotifier<MonthMode> {
  MonthModeNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(MonthMode value) async {
    state = value;
    await _settings?.setMonthMode(value.index);
  }
}

final monthModeProvider =
    StateNotifierProvider<MonthModeNotifier, MonthMode>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final saved = settings?.monthMode ?? 0;
  return MonthModeNotifier(
    settings,
    MonthMode.values[saved.clamp(0, MonthMode.values.length - 1)],
  );
});

/// Сколько событий влезает в ячейку месяца до «+N».
class MonthChipsNotifier extends StateNotifier<int> {
  MonthChipsNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(int value) async {
    state = value;
    await _settings?.setMonthChips(value);
  }
}

final monthChipsProvider =
    StateNotifierProvider<MonthChipsNotifier, int>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return MonthChipsNotifier(settings, (settings?.monthChips ?? 2).clamp(1, 5));
});

/// Прочтение дня: часы или цепочка. Тоже запоминается — человек выбирает его
/// один раз и живёт с ним.
class DayReadingNotifier extends StateNotifier<DayReading> {
  DayReadingNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(DayReading value) async {
    state = value;
    await _settings?.setDayReading(value.index);
  }
}

final dayReadingProvider =
    StateNotifierProvider<DayReadingNotifier, DayReading>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final saved = settings?.dayReading;
  return DayReadingNotifier(
    settings,
    // По умолчанию цепочка: она отвечает на вопрос «что у меня сегодня»,
    // с которым день открывают чаще, чем с «когда я свободен».
    saved == null
        ? DayReading.chain
        : DayReading.values[saved.clamp(0, DayReading.values.length - 1)],
  );
});

/// Оформление: тема, режим схемы, фирменный цвет, язык.
@immutable
class Appearance {
  const Appearance({
    this.themeMode = ThemeMode.system,
    this.vibrant = false,
    this.seed = VehaBrand.seed,
    this.locale,
  });

  final ThemeMode themeMode;
  final bool vibrant;
  final Color seed;

  /// `null` — язык системы.
  final Locale? locale;

  Appearance copyWith({
    ThemeMode? themeMode,
    bool? vibrant,
    Color? seed,
    Object? locale = _keepLocale,
  }) =>
      Appearance(
        themeMode: themeMode ?? this.themeMode,
        vibrant: vibrant ?? this.vibrant,
        seed: seed ?? this.seed,
        locale: locale == _keepLocale ? this.locale : locale as Locale?,
      );

  static const Object _keepLocale = Object();
}

class AppearanceNotifier extends StateNotifier<Appearance> {
  AppearanceNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _settings?.setThemeMode(ThemeMode.values.indexOf(mode));
  }

  Future<void> setVibrant(bool value) async {
    state = state.copyWith(vibrant: value);
    await _settings?.setVibrant(value);
  }

  Future<void> setSeed(Color value) async {
    state = state.copyWith(seed: value);
    await _settings?.setSeed(value.toARGB32());
  }

  Future<void> setLocale(Locale? value) async {
    state = state.copyWith(locale: value);
    await _settings?.setLocale(value?.languageCode ?? '');
  }
}

final appearanceProvider =
    StateNotifierProvider<AppearanceNotifier, Appearance>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  if (settings == null) return AppearanceNotifier(null, const Appearance());

  final language = settings.locale;
  return AppearanceNotifier(
    settings,
    Appearance(
      themeMode: ThemeMode.values[settings.themeMode.clamp(0, 2)],
      vibrant: settings.vibrant,
      seed: settings.seed == 0 ? VehaBrand.seed : Color(settings.seed),
      locale: language.isEmpty ? null : Locale(language),
    ),
  );
});
