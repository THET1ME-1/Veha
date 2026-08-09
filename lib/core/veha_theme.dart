import 'package:flutter/material.dart';

/// Тема Veha: тёплая бумага, пастельные события, чёрные пилюли.
///
/// Material 3 отсюда убран целиком — ни seed-схемы, ни динамического цвета,
/// ни тональных поверхностей. Палитра задана руками: у бумаги и графита свои
/// пять уровней, и они не выводятся друг из друга.
///
/// Цвет события в эту палитру не входит: он приходит из календаря и красится
/// тонами HCT (`EventColors`) — механику ломать нельзя, на ней держится
/// обещание «любой цвет и всегда читаемо».
class VehaTheme {
  VehaTheme._();

  // ── бумага ───────────────────────────────────────────────────────────

  static const paper = Color(0xFFEDEAE3);
  static const paperCard = Color(0xFFFCFBF8);
  static const paperSunk = Color(0xFFE2DED5);
  static const paperInk = Color(0xFF17161B);
  static const paperInk2 = Color(0xFF6B6862);
  static const paperLine = Color(0xFFD3CDC0);

  // ── графит ───────────────────────────────────────────────────────────

  static const coal = Color(0xFF16160F);
  static const coalCard = Color(0xFF1F1F17);
  static const coalSunk = Color(0xFF2A2A20);
  static const coalInk = Color(0xFFEDE7DA);
  static const coalInk2 = Color(0xFF8B8677);
  static const coalLine = Color(0xFF32322A);

  /// Красная риска «сейчас» и опасные действия. Один цвет на обе темы:
  /// он обязан читаться и на бумаге, и на графите.
  static const alarm = Color(0xFFC2453C);
  static const alarmDark = Color(0xFFE4614F);

  static const String font = 'Manrope';

  /// Скругление блоков. Ноль — прямые углы, `pill` — капсула.
  static const double minCorner = 0;
  static const double maxCorner = 28;

  /// Умолчание взято с макета: восемь точек читаются как «скруглённый
  /// прямоугольник», а не как пилюля, и не съедают подпись у низких блоков.
  static const double defaultCorner = 8;

  static ThemeData light(double corner) => _build(
        brightness: Brightness.light,
        bg: paper,
        card: paperCard,
        sunk: paperSunk,
        ink: paperInk,
        ink2: paperInk2,
        line: paperLine,
        alarmColor: alarm,
        corner: corner,
      );

  static ThemeData dark(double corner) => _build(
        brightness: Brightness.dark,
        bg: coal,
        card: coalCard,
        sunk: coalSunk,
        ink: coalInk,
        ink2: coalInk2,
        line: coalLine,
        alarmColor: alarmDark,
        corner: corner,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color sunk,
    required Color ink,
    required Color ink2,
    required Color line,
    required Color alarmColor,
    required double corner,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      // Чернила и есть акцент: чёрная пилюля выбранного вида, чёрная кнопка.
      primary: ink,
      onPrimary: bg,
      primaryContainer: sunk,
      onPrimaryContainer: ink,
      secondary: ink2,
      onSecondary: card,
      secondaryContainer: sunk,
      onSecondaryContainer: ink,
      tertiary: ink2,
      onTertiary: card,
      tertiaryContainer: sunk,
      onTertiaryContainer: ink,
      error: alarmColor,
      onError: brightness == Brightness.light ? Colors.white : coal,
      errorContainer: brightness == Brightness.light
          ? const Color(0xFFF2C0BA)
          : const Color(0xFF5A1F19),
      onErrorContainer: brightness == Brightness.light
          ? const Color(0xFF6B1F17)
          : const Color(0xFFFFD9D2),
      surface: bg,
      onSurface: ink,
      surfaceContainerLowest: brightness == Brightness.light ? card : coal,
      surfaceContainerLow: card,
      surfaceContainer: brightness == Brightness.light ? bg : card,
      surfaceContainerHigh: sunk,
      surfaceContainerHighest: sunk,
      onSurfaceVariant: ink2,
      outline: line,
      outlineVariant: line,
      inverseSurface: ink,
      onInverseSurface: bg,
      inversePrimary: bg,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    );

    final text = _text(ink, ink2);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(corner),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      fontFamily: font,
      textTheme: text,
      // Теней в приложении нет нигде: глубину держат заливка и рамка.
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(corner + 10),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: shape,
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: ink2,
        textColor: ink,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
        shape: shape,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: bg,
          elevation: 0,
          minimumSize: const Size(0, 46),
          textStyle: text.labelLarge,
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          textStyle: text.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: ink),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? bg : card,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? ink : sunk,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: ink,
        inactiveTrackColor: sunk,
        thumbColor: ink,
        overlayColor: ink.withValues(alpha: .1),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: text.bodyMedium?.copyWith(color: bg),
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: ink, size: 22),
      extensions: [VehaShape(corner: corner)],
    );
  }

  /// Одна гарнитура на всё приложение, разница только в весе и кегле.
  static TextTheme _text(Color ink, Color ink2) => TextTheme(
        displayLarge: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.2,
          height: .88,
          color: ink,
        ),
        displayMedium: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
          height: .95,
          color: ink,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -.8,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          letterSpacing: -.6,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -.3,
          color: ink,
        ),
        titleSmall: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -.2,
          color: ink,
        ),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ink),
        bodyMedium:
            TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: ink),
        bodySmall:
            TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink2),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: -.2,
          color: ink,
        ),
        labelMedium: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: ink2,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
          color: ink2,
        ),
      );
}

/// Скругление, выбранное человеком в настройках.
///
/// Живёт расширением темы, а не константой: ползунок должен менять углы у
/// всего сразу, а виды берут значение через `VehaShape.of(context)`.
@immutable
class VehaShape extends ThemeExtension<VehaShape> {
  const VehaShape({required this.corner});

  final double corner;

  static VehaShape of(BuildContext context) =>
      Theme.of(context).extension<VehaShape>() ??
      const VehaShape(corner: VehaTheme.defaultCorner);

  /// Радиус блока события. У низких блоков он ужимается, иначе капсула
  /// съедает подпись: у полоски высотой 20 точек углы в 28 не помещаются.
  BorderRadius forHeight(double height) {
    final r = corner.clamp(0.0, height / 2);
    return BorderRadius.circular(r);
  }

  BorderRadius get all => BorderRadius.circular(corner);

  @override
  VehaShape copyWith({double? corner}) =>
      VehaShape(corner: corner ?? this.corner);

  @override
  VehaShape lerp(VehaShape? other, double t) => other == null
      ? this
      : VehaShape(corner: corner + (other.corner - corner) * t);
}

/// Как подписан блок события в сетке.
enum LabelMode {
  /// Только глиф календаря. Плотнее всего: в недельной колонке шириной в
  /// сорок точек текст всё равно режется, а иконка читается целиком.
  icon,

  /// Только название. Так работала Veha до этого захода.
  text,

  /// Иконка и название рядом.
  both;

  bool get showsIcon => this != LabelMode.text;
  bool get showsText => this != LabelMode.icon;
}
