import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Выбор цвета ветки: наследовать или задать свой.
///
/// Первый пункт — наследование, и он же по умолчанию. Внизу видна вся цепочка:
/// откуда цвет пришёл и что изменится, если сменить его выше.
class BranchColorScreen extends StatefulWidget {
  const BranchColorScreen({
    super.key,
    required this.calendar,
    required this.subcategory,
    required this.presets,
    this.saved = const [],
  });

  final VCalendar calendar;
  final VSubcategory subcategory;
  final List<Color> presets;
  final List<Color> saved;

  @override
  State<BranchColorScreen> createState() => _BranchColorScreenState();
}

class _BranchColorScreenState extends State<BranchColorScreen> {
  late bool _own = widget.subcategory.color != null;
  late Color _color = widget.subcategory.color ?? widget.calendar.color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Text(
          'Цвет ветки',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 27,
            letterSpacing: -0.8,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${widget.calendar.name} · ${widget.subcategory.name}',
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        _Choice(
          color: widget.calendar.color,
          title: 'Как у календаря',
          subtitle: 'Цвет «${widget.calendar.name}»',
          selected: !_own,
          onTap: () => setState(() => _own = false),
        ),
        const SizedBox(height: 8),
        _Choice(
          color: _color,
          title: 'Свой цвет',
          subtitle: 'Задан у этой ветки',
          selected: _own,
          onTap: () => setState(() => _own = true),
        ),
        const SizedBox(height: 12),
        _Swatches(
          colors: widget.presets,
          selected: _own ? _color : null,
          onPick: (c) => setState(() {
            _own = true;
            _color = c;
          }),
        ),
        if (widget.saved.isNotEmpty) ...[
          const VBlockCap('Мои цвета'),
          _Swatches(
            colors: widget.saved,
            selected: _own ? _color : null,
            onPick: (c) => setState(() {
              _own = true;
              _color = c;
            }),
          ),
        ],
        const SizedBox(height: 10),
        VBlock(children: [
          VRow(
            icon: 'dropper',
            value: 'Свой цвет из пикера',
            label: 'Оттенок, насыщенность, hex, пипетка',
            labelFirst: false,
            iconBackground: _color,
            iconColor: EventColors.of(_color, theme.brightness).foreground,
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 18, color: scheme.outline),
          ),
        ]),
        const SizedBox(height: 12),
        _Chain(
          calendar: widget.calendar,
          subcategory: widget.subcategory,
          own: _own,
          color: _color,
          brightness: theme.brightness,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Перекрасите «${widget.calendar.name}» — сменят цвет все ветки и '
            'события, где стоит наследование. Ветки со своим цветом останутся '
            'как есть.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(color, theme.brightness);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: selected ? scheme.secondaryContainer : scheme.surfaceContainerLow,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(22)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const CircleBorder(),
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

class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.colors,
    required this.selected,
    required this.onPick,
  });

  final List<Color> colors;
  final Color? selected;
  final ValueChanged<Color> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < colors.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: GestureDetector(
              onTap: () => onPick(colors[i]),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: colors[i],
                    shape: const CircleBorder(),
                  ),
                  child: colors[i].toARGB32() == selected?.toARGB32()
                      ? FractionallySizedBox(
                          widthFactor: 0.42,
                          heightFactor: 0.42,
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
            ),
          ),
        ],
      ],
    );
  }
}

/// Цепочка наследования: календарь → ветка → событие → заметка.
class _Chain extends StatelessWidget {
  const _Chain({
    required this.calendar,
    required this.subcategory,
    required this.own,
    required this.color,
    required this.brightness,
  });

  final VCalendar calendar;
  final VSubcategory subcategory;
  final bool own;
  final Color color;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final branchColor = own ? color : calendar.color;

    final steps = <(double, Color, String, String)>[
      (0, calendar.color, calendar.name, 'календарь'),
      (18, branchColor, subcategory.name, own ? 'свой' : 'наследует'),
      (36, branchColor, 'Событие ветки', 'наследует'),
      (54, branchColor, '«Заметка внутри»', 'наследует'),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      child: Column(
        children: [
          for (final (indent, c, title, note) in steps)
            Padding(
              padding: EdgeInsets.only(left: indent, top: 5, bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: ShapeDecoration(
                      color: EventColors.of(c, brightness).background,
                      shape: const CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    note,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
