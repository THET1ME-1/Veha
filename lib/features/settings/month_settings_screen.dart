import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/seed.dart';
import '../../data/settings.dart';
import '../calendar/views/month_view.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Настройки вида месяца.
///
/// Режим меняется в любой момент, а не выбирается раз и навсегда при первом
/// запуске: в разные недели полезен разный ответ.
class MonthSettingsScreen extends ConsumerWidget {
  const MonthSettingsScreen({super.key});

  /// Плотность чипа — те же режимы, что и в самом виде. Третьего варианта
  /// («только текст») в коде нет, и предлагать его значит врать.
  static const _densityLabels = ['Иконка и текст', 'Только иконка'];
  static const _densityModes = [MonthMode.chips, MonthMode.icons];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final mode = ref.watch(monthModeProvider);
    void set(MonthMode value) =>
        ref.read(monthModeProvider.notifier).set(value);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'Вид месяца',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 27,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        _ModeCard(
          tinted: false,
          title: 'Чипы с названиями',
          subtitle: 'Видно, что именно в этот день',
          selected: mode != MonthMode.tint,
          onTap: () => set(MonthMode.chips),
        ),
        const SizedBox(height: 8),
        _ModeCard(
          tinted: true,
          title: 'Тонированные ячейки',
          subtitle: 'Видно, чем занят день',
          selected: mode == MonthMode.tint,
          onTap: () => set(MonthMode.tint),
        ),
        if (mode != MonthMode.tint) ...[
          const VBlockCap('Плотность чипа'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _densityLabels.length; i++)
                GestureDetector(
                  onTap: () => set(_densityModes[i]),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: ShapeDecoration(
                      color: _densityModes[i] == mode
                          ? scheme.secondaryContainer
                          : scheme.surfaceContainerHigh,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      _densityLabels[i],
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _densityModes[i] == mode
                            ? scheme.onSecondaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 18),
        VBlock(children: [
          VRow(
            icon: 'number',
            value: 'Событий в ячейке',
            label: 'Дальше сворачивать в «+N»',
            labelFirst: false,
            onTap: () => _pickChips(context, ref),
            trailing: Text(
              '${ref.watch(monthChipsProvider)}',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ]),
      ],
    );
  }
}

/// Сколько событий помещать в ячейку. Больше четырёх в ячейку телефона не
/// влезает физически, меньше одного — бессмысленно.
Future<void> _pickChips(BuildContext context, WidgetRef ref) async {
  final current = ref.read(monthChipsProvider);
  final chosen = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 4; i++)
            VOption(
              title: '$i',
              selected: i == current,
              onTap: () => Navigator.pop(context, i),
            ),
        ],
      ),
    ),
  );
  if (chosen == null) return;
  await ref.read(monthChipsProvider.notifier).set(chosen);
}

/// Мини-превью режима: четыре ячейки из тех же цветов, что и в самом месяце.
class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.tinted,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final bool tinted;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const colors = [Seed.ocean, Seed.plum, Seed.moss, Seed.amber];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color:
              selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Wrap(
                spacing: 3,
                runSpacing: 3,
                children: [
                  for (final c in colors)
                    Container(
                      width: 15.5,
                      height: tinted ? 15.5 : 7,
                      decoration: ShapeDecoration(
                        color: EventColors.of(c, theme.brightness).background,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(tinted ? 5 : 99),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? scheme.onSecondaryContainer
                          : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? scheme.onSecondaryContainer.withValues(alpha: 0.8)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: scheme.primary,
                  shape: const CircleBorder(),
                ),
                child: Icon(VehaIcons.byName('exam'),
                    size: 13, color: scheme.onPrimary),
              ),
          ],
        ),
      ),
    );
  }
}
