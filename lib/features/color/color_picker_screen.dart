import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart' show vBack;
import 'eyedropper_screen.dart';

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
class ColorPickerScreen extends ConsumerStatefulWidget {
  const ColorPickerScreen({
    super.key,
    required this.initial,
    this.saved = const [],
    this.recent = const [],
  });

  final Color initial;

  /// Заранее заданные образцы. Обычно пусто: «мои цвета» экран берёт из базы
  /// сам, а параметр остался для снимков экрана.
  final List<Color> saved;
  final List<Color> recent;

  @override
  ConsumerState<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends ConsumerState<ColorPickerScreen> {
  late Color _color = widget.initial;

  /// Поле кода живёт своим состоянием: пока человек печатает, экран не должен
  /// подставлять ему курсор в конец на каждую букву.
  late final TextEditingController _hex = TextEditingController(text: _hexOf(_color));

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _apply(Color color, {bool syncField = true}) {
    setState(() => _color = color);
    if (syncField) _hex.text = _hexOf(color);
  }

  static String _hexOf(Color c) =>
      (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  /// Разбор введённого кода: шесть знаков или три сокращённых («f0a»).
  static Color? _parseHex(String value) {
    final text = value.replaceAll('#', '').trim();
    if (text.length == 3) {
      final full = text.split('').map((c) => '$c$c').join();
      final parsed = int.tryParse(full, radix: 16);
      return parsed == null ? null : Color(0xFF000000 | parsed);
    }
    if (text.length != 6) return null;
    final parsed = int.tryParse(text, radix: 16);
    return parsed == null ? null : Color(0xFF000000 | parsed);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mine = ref.watch(savedColorsProvider).valueOrNull ?? widget.saved;
    // Последние собираются сами: параметр остаётся для проверок, где
    // хранилища нет.
    final recent = widget.recent.isNotEmpty
        ? widget.recent
        : ref.watch(recentColorsProvider);
    final isSaved = mine.any((c) => c.toARGB32() == _color.toARGB32());
    final scales = PickerScales.forColor(_color);
    final hct = Hct.fromInt(_color.toARGB32());
    final ink = EventColors.of(_color, Theme.of(context).brightness);

    // Свой Scaffold обязателен: экран открывается маршрутом, а `Text` без
    // `Material` над собой рисуется жёлтым подчёркиванием на чёрном.
    return Scaffold(
      appBar: AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  L.of(context).colorPickerOwn,
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
                onPressed: () {
                  // Список последних пополняется на подтверждении, а не на
                  // каждом касании плитки: иначе он забьётся оттенками,
                  // мимо которых человек просто прошёл.
                  ref.read(recentColorsProvider.notifier).push(_color);
                  Navigator.of(context).maybePop(_color);
                },
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(L.of(context).actionDone),
              ),
            ],
          ),
        ),
        _Preview(
          color: _color,
          hct: hct,
          foreground: ink.foreground,
          saved: isSaved,
          onSave: _toggleSaved,
        ),
        const SizedBox(height: 14),
        _Scale(
          label: L.of(context).colorHue,
          colors: scales.hues,
          columns: 12,
          selectedIndex: (hct.hue / 15).round() % 24,
          onPick: (i) => setState(() {
            _color = Color(Hct.from(i * 15.0, hct.chroma, hct.tone).toInt());
          }),
        ),
        _Scale(
          label: L.of(context).colorChroma,
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
          label: L.of(context).colorTone,
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
        _HexRow(
          controller: _hex,
          onChanged: (value) {
            final parsed = _parseHex(value);
            // Пока код недописан, цвет не трогаем: иначе экран мигает на
            // каждой букве и норовит подставить чёрный.
            if (parsed != null) _apply(parsed, syncField: false);
          },
          onCopy: _copy,
          onDropper: _pickFromImage,
        ),
        if (mine.isNotEmpty)
          _Swatches(L.of(context).colorMine, mine, onPick: _apply),
        if (recent.isNotEmpty)
          _Swatches(L.of(context).colorRecent, recent, onPick: _apply),
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            L.of(context).colorPickerHint,
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
    ),
    );
  }

  Future<void> _toggleSaved() async {
    final repo = ref.read(repositoryProvider);
    final mine = ref.read(savedColorsProvider).valueOrNull ?? const <Color>[];
    final l = L.of(context);

    if (mine.any((c) => c.toARGB32() == _color.toARGB32())) {
      await repo.removeSavedColor(_color);
      _say(l.colorRemovedFromMine);
      return;
    }
    final added = await repo.addSavedColor(_color);
    _say(added ? l.colorSaved : l.colorAlreadySaved);
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: '#${_hexOf(_color)}'));
    if (mounted) _say(L.of(context).colorCopied);
  }

  /// Пипетка: снимок или фотография, дальше касание по нужному месту.
  Future<void> _pickFromImage() async {
    final l = L.of(context);
    final service = ref.read(photoServiceProvider);

    try {
      final path = await service.pickForReading();
      if (path == null || !mounted) return;

      final picked = await Navigator.of(context).push<Color>(
        MaterialPageRoute(builder: (_) => EyedropperScreen(file: File(path))),
      );
      if (picked != null) _apply(picked);
    } catch (e) {
      if (mounted) _say('${l.msgSaveFailed}: $e');
    }
  }

  void _say(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

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
    required this.saved,
    required this.onSave,
  });

  final Color color;
  final Hct hct;
  final Color foreground;
  final bool saved;
  final VoidCallback onSave;

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
                  L.of(context).colorReadout(hct.hue.round(), hct.chroma.round(), hct.tone.round()),
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
          // Повторное нажатие убирает цвет из «Моих»: отдельная кнопка
          // удаления на том же месте была бы лишней.
          InkWell(
            onTap: onSave,
            borderRadius: BorderRadius.circular(99),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: ShapeDecoration(
                color: foreground.withValues(alpha: saved ? 0.28 : 0.16),
                shape: const StadiumBorder(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(VehaIcons.byName(saved ? 'check' : 'add'),
                      size: 15, color: foreground),
                  const SizedBox(width: 6),
                  Text(
                    saved ? L.of(context).colorSaved : L.of(context).colorSaveMine,
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
  const _HexRow({
    required this.controller,
    required this.onChanged,
    required this.onCopy,
    required this.onDropper,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCopy;
  final VoidCallback onDropper;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                        // Строчные буквы в коде читаются хуже, а вводят их
                        // чаще: приводим сразу.
                        TextInputFormatter.withFunction(
                          (_, next) => next.copyWith(text: next.text.toUpperCase()),
                        ),
                      ],
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: scheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                        hintText: L.of(context).colorHexHint,
                        hintStyle: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCopy,
                    tooltip: L.of(context).colorCopy,
                    icon: Icon(VehaIcons.byName('content_copy'), size: 18),
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 9),
          InkWell(
            onTap: onDropper,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: scheme.secondaryContainer,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18)),
                ),
              ),
              child: Tooltip(
                message: L.of(context).colorPickFromImage,
                child: Icon(VehaIcons.byName('dropper'),
                    size: 21, color: scheme.onSecondaryContainer),
              ),
            ),
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
