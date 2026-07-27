import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/seed.dart';
import '../calendar/views/month_view.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Настройки вида месяца.
///
/// Режим меняется в любой момент, а не выбирается раз и навсегда при первом
/// запуске: в разные недели полезен разный ответ.
class MonthSettingsScreen extends StatefulWidget {
  const MonthSettingsScreen({super.key, this.initial = MonthMode.chips});

  final MonthMode initial;

  @override
  State<MonthSettingsScreen> createState() => _MonthSettingsScreenState();
}

class _MonthSettingsScreenState extends State<MonthSettingsScreen> {
  late MonthMode _mode = widget.initial;
  int _density = 0;
  bool _spans = true;
  bool _weekNumbers = false;

  static const _densityLabels = [
    'Иконка и текст',
    'Только иконка',
    'Только текст',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          selected: _mode != MonthMode.tint,
          onTap: () => setState(() => _mode = MonthMode.chips),
        ),
        const SizedBox(height: 8),
        _ModeCard(
          tinted: true,
          title: 'Тонированные ячейки',
          subtitle: 'Видно, чем занят день',
          selected: _mode == MonthMode.tint,
          onTap: () => setState(() => _mode = MonthMode.tint),
        ),
        if (_mode != MonthMode.tint) ...[
          const VBlockCap('Плотность чипа'),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var i = 0; i < _densityLabels.length; i++)
                GestureDetector(
                  onTap: () => setState(() {
                    _density = i;
                    _mode = i == 1 ? MonthMode.icons : MonthMode.chips;
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: ShapeDecoration(
                      color: i == _density
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
                        color: i == _density
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
            trailing: Text(
              '3',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          const VSep(),
          VRow(
            icon: 'ticket',
            value: 'Лента многодневных',
            label: 'Абонементы, отпуска, курсы',
            labelFirst: false,
            trailing: VSwitch(
              value: _spans,
              onChanged: (v) => setState(() => _spans = v),
            ),
          ),
          const VSep(),
          VRow(
            icon: 'calendar',
            value: 'Номера недель',
            label: 'Колонка слева от сетки',
            labelFirst: false,
            trailing: VSwitch(
              value: _weekNumbers,
              onChanged: (v) => setState(() => _weekNumbers = v),
            ),
          ),
        ]),
      ],
    );
  }
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
