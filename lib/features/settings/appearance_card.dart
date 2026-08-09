import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../core/veha_theme.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';

/// Карточка «Оформление»: тема, подпись событий и скругление углов.
///
/// Палитра акцентов, «сочность» схемы и цвет из обоев отсюда убраны вместе с
/// Material: цвета приложения заданы руками и не выводятся из seed. Цвет
/// события по-прежнему выбирает человек, но в самом событии, а не здесь.
class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final look = ref.watch(appearanceProvider);
    final notifier = ref.read(appearanceProvider.notifier);

    return Container(
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(VehaShape.of(context).corner + 8),
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
                  value: VehaThemeMode.system,
                  icon: Icon(VehaIcons.byName('brightness_auto')),
                ),
                ButtonSegment(
                  value: VehaThemeMode.dark,
                  icon: Icon(VehaIcons.byName('dark_mode')),
                ),
              ],
              selected: {look.themeMode},
              onSelectionChanged: (s) => notifier.setThemeMode(s.first),
            ),
          ),
          const SizedBox(height: 22),
          _Title(l.labelsTitle),
          const SizedBox(height: 10),
          _LabelChoice(
            value: look.labelMode,
            onPick: notifier.setLabelMode,
          ),
          const SizedBox(height: 22),
          _Title(l.cornerTitle),
          const SizedBox(height: 10),
          CornerPicker(
            corner: look.corner,
            labelMode: look.labelMode,
            onChanged: notifier.setCorner,
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      );
}

/// Три способа подписать блок: иконка, текст, оба.
///
/// Выбор показан не списком, а тремя образцами: человек видит, во что
/// превратится сетка, до того как закроет настройки.
class _LabelChoice extends StatelessWidget {
  const _LabelChoice({required this.value, required this.onPick});

  final LabelMode value;
  final ValueChanged<LabelMode> onPick;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final names = {
      LabelMode.icon: l.labelsIcon,
      LabelMode.text: l.labelsText,
      LabelMode.both: l.labelsBoth,
    };

    return Row(
      children: [
        for (final mode in LabelMode.values) ...[
          Expanded(
            child: _LabelSample(
              mode: mode,
              name: names[mode]!,
              selected: mode == value,
              onTap: () => onPick(mode),
            ),
          ),
          if (mode != LabelMode.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _LabelSample extends StatelessWidget {
  const _LabelSample({
    required this.mode,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final LabelMode mode;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = VehaShape.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Образец красится тем же способом, что и настоящее событие: заливка
    // тоном 90, знак тоном 10.
    final fill = dark ? const Color(0xFF3E4778) : const Color(0xFFC9CCE8);
    final ink = dark ? const Color(0xFFD9DCF4) : const Color(0xFF232A5C);

    return Semantics(
      selected: selected,
      button: true,
      label: name,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(shape.corner),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: ShapeDecoration(
            color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(shape.corner),
              side: BorderSide(
                color: selected ? scheme.onSurface : scheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: EventBlockSample(
                  mode: mode,
                  fill: fill,
                  ink: ink,
                  corner: shape.corner,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ползунок скругления с живым образцом события над ним.
class CornerPicker extends StatelessWidget {
  const CornerPicker({
    super.key,
    required this.corner,
    required this.labelMode,
    required this.onChanged,
  });

  final double corner;
  final LabelMode labelMode;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final fill = dark ? const Color(0xFF3F5A2E) : const Color(0xFFCBDCC6);
    final ink = dark ? const Color(0xFFD8E8CF) : const Color(0xFF23401A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: EventBlockSample(
            mode: labelMode,
            fill: fill,
            ink: ink,
            corner: corner,
            title: l.cornerPreview,
          ),
        ),
        Slider(
          value: corner,
          min: VehaTheme.minCorner,
          max: VehaTheme.maxCorner,
          divisions: (VehaTheme.maxCorner - VehaTheme.minCorner) ~/ 2,
          onChanged: onChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.cornerSquare, style: Theme.of(context).textTheme.labelSmall),
            Text(
              '${corner.round()}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurface,
                  ),
            ),
            Text(l.cornerRound, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

/// Образец блока события: тот же вид, что в сетке недели.
class EventBlockSample extends StatelessWidget {
  const EventBlockSample({
    super.key,
    required this.mode,
    required this.fill,
    required this.ink,
    required this.corner,
    this.title,
  });

  final LabelMode mode;
  final Color fill;
  final Color ink;
  final double corner;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final radius = corner.clamp(0.0, box.maxHeight / 2);
        final icon = Icon(VehaIcons.byName('school'), size: 18, color: ink);
        final name = Text(
          title ?? L.of(context).viewDay,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: ink, fontWeight: FontWeight.w800),
        );

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: mode == LabelMode.icon ? 0 : 9,
            vertical: 6,
          ),
          decoration: ShapeDecoration(
            color: fill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: switch (mode) {
            LabelMode.icon => Center(child: icon),
            LabelMode.text => Align(
                alignment: Alignment.centerLeft,
                child: name,
              ),
            LabelMode.both => Row(
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Flexible(child: name),
                ],
              ),
          },
        );
      },
    );
  }
}
