import 'package:flutter/material.dart';

/// Фирменные константы Veha.
class VehaBrand {
  VehaBrand._();

  /// Мята. Занято соседями: бирюза 0xFF00B5C7 (Kadr, ScoreMaster), папоротник
  /// 0xFF2E7D5B (Fern), мёд 0xFFC0863E (Wickly), роза 0xFFFF7E9B (Togetherly).
  static const Color seed = Color(0xFF41CCB5);

  /// Схема строится в режиме «Точь-в-точь», а не «Сочно», как в остальных
  /// приложениях ДНК. Причина в оттенке: на 182° `SchemeVibrant` выкручивает
  /// `primaryContainer` светлой темы до #00FEDF — кислотная мята на пилюлях,
  /// индикаторе навбара и FAB. Насыщенностью seed не лечится, вариант схемы —
  /// единственный рычаг. Пользователь переключит в настройках, если захочет.
  static const bool vibrantByDefault = false;
}

/// Отступы, общие для всех экранов: шапка, полосы, таймлайн и лента дней
/// стоят на одной вертикали, иначе края расходятся между разделами.
class VehaInsets {
  VehaInsets._();

  static const double screen = 20;
  static const double timeColumn = 44;
  static const double railColumn = 58;
  static const double pill = 56;
  static const double gap = 11;
}
