import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/brand.dart';
import '../domain/week_layout.dart';
import '../features/calendar/views/month_view.dart' show MonthMode;
import '../features/calendar/widgets/month_header.dart' show DayReading;
import '../features/calendar/widgets/view_switcher.dart' show CalendarView;

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
  static const _startTab = 'start_tab';
  static const _startView = 'start_view';
  static const _syncUrl = 'sync_url';
  static const _syncToken = 'sync_token';
  static const _syncCursor = 'sync_cursor';
  static const _themeMode = 'theme_mode';
  static const _vibrant = 'vibrant';
  static const _seed = 'seed';
  static const _locale = 'locale';
  static const _amoled = 'amoled';
  static const _dynamicColor = 'dynamic_color';

  /// Индекс в `VehaThemeMode`. `null` — человек не выбирал; умолчание решает
  /// не хранилище.
  int? get themeMode => _prefs.getInt(_themeMode);

  Future<void> setThemeMode(int value) => _prefs.setInt(_themeMode, value);

  /// Режим генерации схемы. На фирменном оттенке 182° «Сочно» выкручивает
  /// `primaryContainer` до кислотной мяты, поэтому по умолчанию «Точь-в-точь».
  bool get vibrant => _prefs.getBool(_vibrant) ?? false;

  Future<void> setVibrant(bool value) => _prefs.setBool(_vibrant, value);

  /// Цвет, из которого строится схема. Ноль — фирменная мята.
  int get seed => _prefs.getInt(_seed) ?? 0;

  Future<void> setSeed(int value) => _prefs.setInt(_seed, value);

  /// Чисто чёрный фон в тёмной теме: на OLED он не светится и не ест батарею.
  bool get amoled => _prefs.getBool(_amoled) ?? false;

  Future<void> setAmoled(bool value) => _prefs.setBool(_amoled, value);

  /// Цвет из обоев системы (Android 12+).
  bool get dynamicColor => _prefs.getBool(_dynamicColor) ?? false;

  Future<void> setDynamicColor(bool value) =>
      _prefs.setBool(_dynamicColor, value);

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

  /// С какого раздела открывается приложение.
  int get startTab => _prefs.getInt(_startTab) ?? 0;

  Future<void> setStartTab(int value) => _prefs.setInt(_startTab, value);

  /// Каким видом открывается календарь: день, дни лентами, неделя, месяц.
  int get startView => _prefs.getInt(_startView) ?? 0;

  Future<void> setStartView(int value) => _prefs.setInt(_startView, value);

  /// Адрес сервера. Пустой — синхронизации нет, календарь чисто локальный.
  String get syncUrl => _prefs.getString(_syncUrl) ?? '';

  Future<void> setSyncUrl(String value) => _prefs.setString(_syncUrl, value);

  /// Ключ устройства. Живёт рядом с адресом: сменил сервер — ключ не годится.
  String get syncToken => _prefs.getString(_syncToken) ?? '';

  Future<void> setSyncToken(String value) => _prefs.setString(_syncToken, value);

  /// Докуда дошли в прошлый раз.
  int get syncCursor => _prefs.getInt(_syncCursor) ?? 0;

  Future<void> setSyncCursor(int value) => _prefs.setInt(_syncCursor, value);
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

/// Синхронизация: адрес, ключ и курсор одним состоянием — по отдельности они
/// не значат ничего.
@immutable
class SyncSettings {
  const SyncSettings({this.url = '', this.token = '', this.cursor = 0});

  final String url;
  final String token;
  final int cursor;

  bool get connected => url.isNotEmpty && token.isNotEmpty;
}

class SyncSettingsNotifier extends StateNotifier<SyncSettings> {
  SyncSettingsNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> connect({required String url, required String token}) async {
    state = SyncSettings(url: url, token: token);
    await _settings?.setSyncUrl(url);
    await _settings?.setSyncToken(token);
    await _settings?.setSyncCursor(0);
  }

  Future<void> setCursor(int value) async {
    state = SyncSettings(url: state.url, token: state.token, cursor: value);
    await _settings?.setSyncCursor(value);
  }

  /// Отключение: ключ и курсор забываются, данные остаются. Локальный
  /// календарь — это норма, а не поломка.
  Future<void> disconnect() async {
    state = const SyncSettings();
    await _settings?.setSyncUrl('');
    await _settings?.setSyncToken('');
    await _settings?.setSyncCursor(0);
  }
}

final syncSettingsProvider =
    StateNotifierProvider<SyncSettingsNotifier, SyncSettings>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return SyncSettingsNotifier(
    settings,
    SyncSettings(
      url: settings?.syncUrl ?? '',
      token: settings?.syncToken ?? '',
      cursor: settings?.syncCursor ?? 0,
    ),
  );
});

/// Стартовый раздел: с него открывается приложение. Человек, живущий в
/// списке календарей, не должен каждый раз проходить через день.
class StartTabNotifier extends StateNotifier<int> {
  StartTabNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(int value) async {
    state = value;
    await _settings?.setStartTab(value);
  }
}

final startTabProvider = StateNotifierProvider<StartTabNotifier, int>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return StartTabNotifier(settings, (settings?.startTab ?? 0).clamp(0, 3));
});

/// Каким видом открывается календарь.
class StartViewNotifier extends StateNotifier<CalendarView> {
  StartViewNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(CalendarView value) async {
    state = value;
    await _settings?.setStartView(value.index);
  }
}

final startViewProvider =
    StateNotifierProvider<StartViewNotifier, CalendarView>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  final saved = (settings?.startView ?? 0).clamp(0, CalendarView.values.length - 1);
  return StartViewNotifier(settings, CalendarView.values[saved]);
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

/// Режим темы. Четвёртый, «по времени суток», системному не равен: система
/// переключается по своему расписанию, а человеку бывает нужно ровно «после
/// заката — тёмная».
enum VehaThemeMode { light, dark, system, autoTime }

extension VehaThemeModeX on VehaThemeMode {
  /// Во что превращается для Flutter. «По времени суток» решается здесь и
  /// сейчас: с восьми вечера до семи утра — тёмная.
  ThemeMode get flutter => switch (this) {
        VehaThemeMode.light => ThemeMode.light,
        VehaThemeMode.dark => ThemeMode.dark,
        VehaThemeMode.system => ThemeMode.system,
        VehaThemeMode.autoTime =>
          _isNight ? ThemeMode.dark : ThemeMode.light,
      };

  static bool get _isNight {
    final hour = DateTime.now().hour;
    return hour >= 20 || hour < 7;
  }
}

/// Оформление: тема, режим схемы, фирменный цвет, язык.
@immutable
class Appearance {
  const Appearance({
    this.themeMode = VehaThemeMode.system,
    this.vibrant = false,
    this.seed = VehaBrand.seed,
    this.amoled = false,
    this.dynamicColor = false,
    this.locale,
  });

  final VehaThemeMode themeMode;
  final bool vibrant;
  final Color seed;

  /// Чисто чёрный фон в тёмной теме.
  final bool amoled;

  /// Цвет из обоев системы вместо выбранного.
  final bool dynamicColor;

  /// `null` — язык системы.
  final Locale? locale;

  Appearance copyWith({
    VehaThemeMode? themeMode,
    bool? vibrant,
    Color? seed,
    bool? amoled,
    bool? dynamicColor,
    Object? locale = _keepLocale,
  }) =>
      Appearance(
        themeMode: themeMode ?? this.themeMode,
        vibrant: vibrant ?? this.vibrant,
        seed: seed ?? this.seed,
        amoled: amoled ?? this.amoled,
        dynamicColor: dynamicColor ?? this.dynamicColor,
        locale: locale == _keepLocale ? this.locale : locale as Locale?,
      );

  static const Object _keepLocale = Object();
}

class AppearanceNotifier extends StateNotifier<Appearance> {
  AppearanceNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> setThemeMode(VehaThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _settings?.setThemeMode(mode.index);
  }

  Future<void> setAmoled(bool value) async {
    state = state.copyWith(amoled: value);
    await _settings?.setAmoled(value);
  }

  Future<void> setDynamicColor(bool value) async {
    state = state.copyWith(dynamicColor: value);
    await _settings?.setDynamicColor(value);
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
      // По умолчанию системная: приложение подстраивается под телефон, пока
      // человек не сказал иначе.
      themeMode: settings.themeMode == null
          ? VehaThemeMode.system
          : VehaThemeMode.values[settings.themeMode!.clamp(0, 3)],
      vibrant: settings.vibrant,
      seed: settings.seed == 0 ? VehaBrand.seed : Color(settings.seed),
      amoled: settings.amoled,
      dynamicColor: settings.dynamicColor,
      locale: language.isEmpty ? null : Locale(language),
    ),
  );
});
