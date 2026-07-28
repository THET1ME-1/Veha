import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3_dna/theme/app_theme.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../color/color_picker_screen.dart';

/// Карточка «Оформление»: режим темы, чёрный фон, цвет из обоев, палитра
/// акцентов и насыщенность схемы.
///
/// Перенесена из Wickly. Четыре режима видны сразу, а кружок показывает не
/// одну точку, а четыре тона будущей схемы — по нему видно, во что превратится
/// тема, ещё до нажатия.
class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  /// Пресеты акцента. Первый — фирменная мята.
  static const presets = [
    VehaBrand.seed,
    Color(0xFF3B7DD8),
    Color(0xFF8E5CC4),
    Color(0xFF4C9A5B),
    Color(0xFFE0A93B),
    Color(0xFFB4694A),
    Color(0xFFC4485C),
    Color(0xFF00838F),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final look = ref.watch(appearanceProvider);
    final notifier = ref.read(appearanceProvider.notifier);

    return Container(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<VehaThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: VehaThemeMode.light,
                  icon: Icon(VehaIcons.byName('light_mode')),
                ),
                ButtonSegment(
                  value: VehaThemeMode.dark,
                  icon: Icon(VehaIcons.byName('dark_mode')),
                ),
                ButtonSegment(
                  value: VehaThemeMode.system,
                  icon: Icon(VehaIcons.byName('brightness_auto')),
                ),
                ButtonSegment(
                  value: VehaThemeMode.autoTime,
                  icon: Icon(VehaIcons.byName('schedule')),
                ),
              ],
              selected: {look.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            switch (look.themeMode) {
              VehaThemeMode.light => l.settingsLight,
              VehaThemeMode.dark => l.settingsDark,
              VehaThemeMode.system => l.settingsSystem,
              VehaThemeMode.autoTime => l.settingsAutoTime,
            },
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),

          // Чёрный фон имеет смысл только там, где фон вообще тёмный.
          if (look.themeMode != VehaThemeMode.light)
            _Toggle(
              icon: 'contrast',
              title: l.settingsAmoled,
              subtitle: l.settingsAmoledHint,
              value: look.amoled,
              onChanged: notifier.setAmoled,
            ),
          _Toggle(
            icon: 'wand',
            title: l.settingsMaterialYou,
            subtitle: l.settingsMaterialYouHint,
            value: look.dynamicColor,
            onChanged: notifier.setDynamicColor,
          ),

          // Палитру прячем при цвете из обоев: там акцент приходит из системы,
          // и выбор рядом только сбивал бы с толку.
          if (!look.dynamicColor) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final c in presets)
                  SeedSwatch(
                    seed: c,
                    vibrant: look.vibrant,
                    selected: look.seed.toARGB32() == c.toARGB32(),
                    onTap: () => notifier.setSeed(c),
                  ),
                _CustomColor(
                  seed: look.seed,
                  custom: !presets
                      .any((c) => c.toARGB32() == look.seed.toARGB32()),
                  onPicked: notifier.setSeed,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.settingsChroma,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: true,
                    icon: Icon(VehaIcons.byName('wand'), size: 18),
                    label: Text(l.settingsVivid),
                  ),
                  ButtonSegment(
                    value: false,
                    icon: Icon(VehaIcons.byName('gps_fixed'), size: 18),
                    label: Text(l.settingsExact),
                  ),
                ],
                selected: {look.vibrant},
                onSelectionChanged: (s) => notifier.setVibrant(s.first),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Кружок-превью схемы: четыре тона будущей темы вместо одноцветной точки.
///
/// Морфа выбранной формы, как в Wickly, здесь нет намеренно: в Veha морфинг
/// живёт ровно в трёх местах, и размазывать его по настройкам нельзя.
class SeedSwatch extends StatelessWidget {
  const SeedSwatch({
    super.key,
    required this.seed,
    this.selected = false,
    this.size = 44,
    this.vibrant = false,
    this.onTap,
  });

  final Color seed;
  final bool selected;
  final double size;
  final bool vibrant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Схема строится ровно так же, как её строит тема, включая насыщенность:
    // кружок обязан показывать то, что получится, а не похожее.
    final s = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      dynamicSchemeVariant: AppTheme.variantFor(vibrant),
    );

    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _Quadrants([
              s.primaryContainer,
              s.primary,
              s.tertiaryContainer,
              s.tertiary,
            ]),
            child: selected
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.38),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(VehaIcons.byName('check'),
                          color: Colors.white, size: size * 0.34),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class _Quadrants extends CustomPainter {
  _Quadrants(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 4; i++) {
      p.color = colors[i];
      canvas.drawRect(
        Rect.fromLTWH(i.isEven ? 0 : w / 2, i < 2 ? 0 : h / 2, w / 2, h / 2),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Quadrants old) =>
      !identical(old.colors, colors) &&
      List.generate(4, (i) => old.colors[i] != colors[i]).any((x) => x);
}

/// Кружок «свой цвет». Пипетка красится выбранным цветом, когда он не из
/// палитры, — иначе непонятно, откуда взялся текущий акцент.
class _CustomColor extends StatelessWidget {
  const _CustomColor({
    required this.seed,
    required this.custom,
    required this.onPicked,
  });

  final Color seed;
  final bool custom;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () async {
        final picked = await Navigator.of(context).push<Color>(
          MaterialPageRoute(builder: (_) => ColorPickerScreen(initial: seed)),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHighest,
          shape: const CircleBorder(),
        ),
        child: Icon(VehaIcons.byName('dropper'),
            size: 20, color: custom ? seed : scheme.onSurfaceVariant),
      ),
    );
  }
}

/// Компактная строка-тумблер внутри карточки.
class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(VehaIcons.byName(icon), size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
