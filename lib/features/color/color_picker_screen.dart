import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart';

/// Ряды плиток пикера, посчитанные в HCT.
///
/// Именно HCT, а не HSV: у выбранного оттенка недостижимая хрома обрезается
/// по факту, иначе половина ряда схлопывается в одинаковые квадраты — на
/// бирюзе это уже случалось.
class PickerScales {
  const PickerScales({
    required this.hues,
    required this.chromas,
    required this.tones,
    required this.maxChroma,
  });

  final List<Color> hues;
  final List<Color> chromas;
  final List<Color> tones;
  final double maxChroma;

  static PickerScales forColor(Color color) {
    final hct = Hct.fromInt(color.toARGB32());
    final maxC = _maxChroma(hct.hue, hct.tone);

    return PickerScales(
      hues: [
        for (var i = 0; i < 24; i++)
          Color(Hct.from(i * 15.0, 52, 58).toInt()),
      ],
      chromas: [
        for (var i = 0; i < 8; i++)
          Color(Hct.from(hct.hue, 4 + (maxC - 4) * i / 7, hct.tone).toInt()),
      ],
      tones: [
        for (final t in const [22, 32, 42, 52, 62, 72, 84, 94])
          Color(Hct.from(hct.hue, hct.chroma, t.toDouble()).toInt()),
      ],
      maxChroma: maxC,
    );
  }

  /// Достижимая хрома для оттенка и тона: выше неё цвет начинает повторяться.
  static double _maxChroma(double hue, double tone) {
    for (var c = 100.0; c >= 0; c -= 2) {
      final produced = Hct.fromInt(Hct.from(hue, c, tone).toInt());
      if ((produced.chroma - c).abs() < 2) return c;
    }
    return 40;
  }
}

/// Пикер произвольного цвета: плитки, hex и пипетка.
///
/// Радуги-градиента здесь нет — правило «заливка или ничего» действует и тут,
/// а в плитку ещё и проще попасть пальцем. Бесконечность даёт поле hex.
class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({
    super.key,
    required this.initial,
    this.saved = const [],
    this.recent = const [],
  });

  final Color initial;
  final List<Color> saved;
  final List<Color> recent;

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  late Color _color = widget.initial;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scales = PickerScales.forColor(_color);
    final hct = Hct.fromInt(_color.toARGB32());
    final ink = EventColors.of(_color, Theme.of(context).brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Свой цвет',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 27,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              // Экран открывают, чтобы выбрать цвет, — значит он обязан его
              // вернуть. Без этой кнопки пикер был витриной.
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(_color),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Готово'),
              ),
            ],
          ),
        ),
        _Preview(color: _color, hct: hct, foreground: ink.foreground),
        const SizedBox(height: 14),
        _Scale(
          label: 'Оттенок',
          colors: scales.hues,
          columns: 12,
          selectedIndex: (hct.hue / 15).round() % 24,
          onPick: (i) => setState(() {
            _color = Color(Hct.from(i * 15.0, hct.chroma, hct.tone).toInt());
          }),
        ),
        _Scale(
          label: 'Насыщенность',
          colors: scales.chromas,
          columns: 8,
          selectedIndex:
              ((hct.chroma - 4) / (scales.maxChroma - 4) * 7).round().clamp(0, 7),
          onPick: (i) => setState(() {
            final c = 4 + (scales.maxChroma - 4) * i / 7;
            _color = Color(Hct.from(hct.hue, c, hct.tone).toInt());
          }),
        ),
        _Scale(
          label: 'Светлота',
          colors: scales.tones,
          columns: 8,
          selectedIndex: _closestToneIndex(hct.tone),
          onPick: (i) => setState(() {
            const tones = [22, 32, 42, 52, 62, 72, 84, 94];
            _color =
                Color(Hct.from(hct.hue, hct.chroma, tones[i].toDouble()).toInt());
          }),
        ),
        const SizedBox(height: 4),
        _HexRow(color: _color),
        if (widget.saved.isNotEmpty) _Swatches('Мои цвета', widget.saved, onPick: _pick),
        if (widget.recent.isNotEmpty)
          _Swatches('Последние', widget.recent, onPick: _pick),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            'Пипетка берёт цвет с обоев или скриншота. Сохранённые живут '
            'в «Моих цветах» и доступны из любого пикера в приложении.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  void _pick(Color c) => setState(() => _color = c);

  static int _closestToneIndex(double tone) {
    const tones = [22, 32, 42, 52, 62, 72, 84, 94];
    var best = 0;
    for (var i = 1; i < tones.length; i++) {
      if ((tones[i] - tone).abs() < (tones[best] - tone).abs()) best = i;
    }
    return best;
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.color,
    required this.hct,
    required this.foreground,
  });

  final Color color;
  final Hct hct;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hex(color),
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Оттенок ${hct.hue.round()}° · насыщенность ${hct.chroma.round()} · светлота ${hct.tone.round()}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: foreground.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: ShapeDecoration(
              color: foreground.withValues(alpha: 0.16),
              shape: const StadiumBorder(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(VehaIcons.byName('add'), size: 15, color: foreground),
                const SizedBox(width: 6),
                Text(
                  'В мои',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _hex(Color c) =>
      '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

class _Scale extends StatelessWidget {
  const _Scale({
    required this.label,
    required this.colors,
    required this.columns,
    required this.selectedIndex,
    required this.onPick,
  });

  final String label;
  final List<Color> colors;
  final int columns;
  final int selectedIndex;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = (colors.length / columns).ceil();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (var r = 0; r < rows; r++) ...[
            if (r > 0) const SizedBox(height: 5),
            Row(
              children: [
                for (var c = 0; c < columns; c++) ...[
                  if (c > 0) const SizedBox(width: 5),
                  Expanded(
                    child: _Tile(
                      color: colors[(r * columns + c) % colors.length],
                      selected: r * columns + c == selectedIndex,
                      onTap: () => onPick(r * columns + c),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          alignment: Alignment.center,
          decoration: ShapeDecoration(color: color, shape: const CircleBorder()),
          // Выбранная плитка отмечена точкой внутри, а не обводкой.
          child: selected
              ? FractionallySizedBox(
                  widthFactor: 0.4,
                  heightFactor: 0.4,
                  child: Container(
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: CircleBorder(),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

class _HexRow extends StatelessWidget {
  const _HexRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hex =
        (color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: ShapeDecoration(
                color: scheme.surfaceContainerHigh,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '#',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    hex,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: scheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 9),
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.secondaryContainer,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
            ),
            child: Icon(VehaIcons.byName('dropper'),
                size: 21, color: scheme.onSecondaryContainer),
          ),
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches(this.label, this.colors, {required this.onPick});

  final String label;
  final List<Color> colors;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 8; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: i < colors.length
                      ? _Tile(
                          color: colors[i],
                          selected: false,
                          onTap: () => onPick(colors[i]),
                        )
                      : AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: scheme.surfaceContainerHigh,
                              shape: const CircleBorder(),
                            ),
                            child: Icon(VehaIcons.byName('add'),
                                size: 16, color: scheme.primary),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
