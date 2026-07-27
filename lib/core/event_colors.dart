import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

/// Пара «фон и знак» для события.
@immutable
class EventInk {
  const EventInk({
    required this.background,
    required this.foreground,
    required this.soft,
    required this.chip,
    required this.onChip,
  });

  /// Заливка пилюли: тон 90 в светлой теме, 30 в тёмной.
  final Color background;

  /// Текст и иконка на этой заливке: тон 10 и 90 соответственно.
  final Color foreground;

  /// Мягкая заливка под плашку дня: тон 95 и 30.
  final Color soft;

  /// Плотная заливка чипа в ленте дней: тон 40 и 80.
  final Color chip;

  /// Знак на чипе.
  final Color onChip;
}

/// Превращает произвольный цвет в читаемые тона под текущую тему.
///
/// Выбранный пользователем hex никогда не красит напрямую: он подаётся seed'ом
/// в тональную палитру HCT, и приложение берёт нужные тона. Отсюда обещание
/// «любой цвет и всегда читаемо» — тёмно-синий не окажется под чёрным текстом.
class EventColors {
  EventColors._();

  static final Map<int, TonalPalette> _cache = {};

  static TonalPalette _palette(int argb) =>
      _cache.putIfAbsent(argb, () => TonalPalette.fromHct(Hct.fromInt(argb)));

  static EventInk of(Color seed, Brightness brightness) {
    final p = _palette(seed.toARGB32());
    final dark = brightness == Brightness.dark;
    return EventInk(
      background: Color(p.get(dark ? 30 : 90)),
      foreground: Color(p.get(dark ? 90 : 10)),
      soft: Color(p.get(dark ? 30 : 95)),
      chip: Color(p.get(dark ? 80 : 40)),
      onChip: Color(p.get(dark ? 10 : 100)),
    );
  }

  /// Тон палитры напрямую — для мест, где нужен конкретный уровень
  /// (бусины месяца, полоса прогресса).
  static Color tone(Color seed, int tone) =>
      Color(_palette(seed.toARGB32()).get(tone));
}
