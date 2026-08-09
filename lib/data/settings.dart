import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/veha_theme.dart';
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
  static const _locale = 'locale';
  static const _labelMode = 'label_mode';
  static const _corner = 'corner';
  static const _lastPurge = 'last_purge';
  static const _recentColors = 'recent_colors';
  static const _gridZoom = 'grid_zoom';

  /// Границы масштаба сетки часов. Ниже минимума пилюли слипаются, выше
  /// максимума в экран не влезает и половина рабочего дня.
  static const double minZoom = 0.6;
  static const double maxZoom = 2.5;

  /// Во сколько раз растянут час по вертикали.
  double get gridZoom => (_prefs.getDouble(_gridZoom) ?? 1).clamp(minZoom, maxZoom);

  Future<void> setGridZoom(double value) =>
      _prefs.setDouble(_gridZoom, value.clamp(minZoom, maxZoom));

  /// Последние использованные цвета, свежий первым.
  ///
  /// Кольцевой буфер в настройках, а не таблица в базе: это кеш поведения —
  /// его не жалко потерять и незачем синхронизировать. «Мои цвета» живут
  /// отдельно, они выбраны человеком осознанно.
  List<int> get recentColors =>
      (_prefs.getStringList(_recentColors) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toList();

  /// Кладёт цвет наверх списка. Повтор поднимается, а не дублируется.
  Future<void> pushRecentColor(int argb) async {
    final next = [argb, ...recentColors.where((c) => c != argb)].take(12);
    await _prefs.setStringList(
      _recentColors,
      [for (final c in next) '$c'],
    );
  }

  /// Когда в последний раз чистили корзину, в миллисекундах эпохи. Ноль —
  /// не чистили ни разу.
  int get lastPurge => _prefs.getInt(_lastPurge) ?? 0;

  Future<void> setLastPurge(int value) => _prefs.setInt(_lastPurge, value);

  /// Индекс в `VehaThemeMode`. `null` — человек не выбирал; умолчание решает
  /// не хранилище.
  int? get themeMode => _prefs.getInt(_themeMode);

  Future<void> setThemeMode(int value) => _prefs.setInt(_themeMode, value);

  /// Индекс в `LabelMode`: чем подписан блок события в сетке.
  int get labelMode => _prefs.getInt(_labelMode) ?? LabelMode.both.index;

  Future<void> setLabelMode(int value) => _prefs.setInt(_labelMode, value);

  /// Скругление углов блоков, точки.
  double get corner =>
      (_prefs.getDouble(_corner) ?? VehaTheme.defaultCorner)
          .clamp(VehaTheme.minCorner, VehaTheme.maxCorner);

  Future<void> setCorner(double value) => _prefs.setDouble(
        _corner,
        value.clamp(VehaTheme.minCorner, VehaTheme.maxCorner),
      );

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

  /// Умолчание — полоски: они читаются на любой ширине ячейки, а чипы с
  /// названиями на телефоне всё равно вырождались в иконки.
  int get monthMode => _prefs.getInt(_monthMode) ?? MonthMode.bars.index;

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

/// Последние использованные цвета. Состояние, а не чтение из хранилища на
/// каждый кадр: пикер обязан обновиться сразу после выбора.
class RecentColorsNotifier extends StateNotifier<List<Color>> {
  RecentColorsNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> push(Color color) async {
    final argb = color.toARGB32();
    state = [color, ...state.where((c) => c.toARGB32() != argb)].take(12).toList();
    await _settings?.pushRecentColor(argb);
  }
}

final recentColorsProvider =
    StateNotifierProvider<RecentColorsNotifier, List<Color>>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return RecentColorsNotifier(
    settings,
    [for (final c in settings?.recentColors ?? const <int>[]) Color(c)],
  );
});

/// Масштаб сетки часов отдельным состоянием: щипок должен отзываться сразу,
/// а запись в хранилище идёт следом и пальцу не мешает.
class GridZoomNotifier extends StateNotifier<double> {
  GridZoomNotifier(this._settings, super.state);

  final VehaSettings? _settings;

  Future<void> set(double value) async {
    final next = value.clamp(VehaSettings.minZoom, VehaSettings.maxZoom);
    if (next == state) return;
    state = next;
    await _settings?.setGridZoom(next);
  }
}

final gridZoomProvider =
    StateNotifierProvider<GridZoomNotifier, double>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return GridZoomNotifier(settings, settings?.gridZoom ?? 1);
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
    // По умолчанию лента: она отвечает на вопрос «что у меня сегодня»,
    // с которым день открывают чаще, чем с «когда я свободен».
    saved == null
        ? DayReading.tape
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

/// Оформление: тема, язык, подпись блоков и скругление.
@immutable
class Appearance {
  const Appearance({
    this.themeMode = VehaThemeMode.system,
    this.locale,
    this.labelMode = LabelMode.both,
    this.corner = VehaTheme.defaultCorner,
  });

  final VehaThemeMode themeMode;

  /// `null` — язык системы.
  final Locale? locale;

  /// Чем подписан блок события в сетке: иконкой, текстом или обоими.
  final LabelMode labelMode;

  /// Скругление углов блоков.
  final double corner;

  Appearance copyWith({
    VehaThemeMode? themeMode,
    Object? locale = _keepLocale,
    LabelMode? labelMode,
    double? corner,
  }) =>
      Appearance(
        themeMode: themeMode ?? this.themeMode,
        locale: locale == _keepLocale ? this.locale : locale as Locale?,
        labelMode: labelMode ?? this.labelMode,
        corner: corner ?? this.corner,
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

  Future<void> setLabelMode(LabelMode mode) async {
    state = state.copyWith(labelMode: mode);
    await _settings?.setLabelMode(mode.index);
  }

  Future<void> setCorner(double value) async {
    state = state.copyWith(corner: value);
    await _settings?.setCorner(value);
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
      locale: language.isEmpty ? null : Locale(language),
      labelMode:
          LabelMode.values[settings.labelMode.clamp(0, LabelMode.values.length - 1)],
      corner: settings.corner,
    ),
  );
});
