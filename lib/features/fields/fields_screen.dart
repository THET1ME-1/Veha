import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/seed.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

/// Верхний уровень редактора полей: группы и их наборы.
///
/// Поле принадлежит группе, а не всем событиям сразу: номер карты нужен
/// абонементу и не нужен уроку английского.
class FieldGroupsScreen extends StatelessWidget {
  const FieldGroupsScreen({super.key, required this.inheritance});

  final Inheritance inheritance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shared = Seed.fields.where((f) => f.calendarId == null).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 14, VehaInsets.screen, 120),
      children: [
        const VBlockCap('Общие для всех'),
        VBlock(children: [
          VRow(
            icon: 'text',
            value: 'Общие поля',
            label: shared.map((f) => f.name.toLowerCase()).join(', '),
            labelFirst: false,
            trailing: _Count(shared.length),
          ),
        ]),
        const VBlockCap('Группы'),
        VBlock(children: [
          for (var i = 0; i < Seed.calendars.length; i++) ...[
            if (i > 0) const VSep(),
            _GroupRow(
              calendar: Seed.calendars[i],
              fields: Seed.fields
                  .where((f) => f.calendarId == Seed.calendars[i].id)
                  .toList(),
              brightness: theme.brightness,
            ),
          ],
        ]),
        const SizedBox(height: 10),
        VBlock(
          color: Theme.of(context).colorScheme.surfaceContainer,
          children: const [
            _AddRow(text: 'Создать группу полей'),
          ],
        ),
      ],
    );
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.calendar,
    required this.fields,
    required this.brightness,
  });

  final VCalendar calendar;
  final List<VFieldDef> fields;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final ink = EventColors.of(calendar.color, brightness);
    return VRow(
      icon: calendar.iconName,
      iconBackground: ink.background,
      iconColor: ink.foreground,
      value: calendar.name,
      label: fields.isEmpty
          ? 'Без своих полей'
          : fields.map((f) => f.name.toLowerCase()).join(', '),
      labelFirst: false,
      trailing: fields.isEmpty
          ? Icon(VehaIcons.byName('chevron'),
              size: 20, color: Theme.of(context).colorScheme.outline)
          : _Count(fields.length),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count(this.value);

  final int value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$value',
      style: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Поля одной группы с тумблерами видимости в свёрнутой карточке.
class FieldsOfGroupScreen extends StatefulWidget {
  const FieldsOfGroupScreen({super.key, required this.calendar});

  final VCalendar calendar;

  @override
  State<FieldsOfGroupScreen> createState() => _FieldsOfGroupScreenState();
}

class _FieldsOfGroupScreenState extends State<FieldsOfGroupScreen> {
  late final Map<String, bool> _shown = {
    for (final f in _fields) f.id: f.showInCard,
  };

  List<VFieldDef> get _fields => [
        ...Seed.fields.where((f) => f.isBuiltIn),
        ...Seed.fields.where((f) => f.calendarId == widget.calendar.id),
      ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final own = _fields.where((f) => !f.isBuiltIn).length;
    final inCard = _shown.values.where((v) => v).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.calendar.name,
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
                '$own своих поля · в карточке $inCard',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        VBlock(children: [
          for (var i = 0; i < _fields.length; i++) ...[
            if (i > 0) const VSep(),
            _FieldRow(
              def: _fields[i],
              value: _shown[_fields[i].id] ?? false,
              onChanged: (v) => setState(() => _shown[_fields[i].id] = v),
            ),
          ],
          const VSep(),
          _AddRow(text: 'Добавить поле в «${widget.calendar.name}»'),
        ]),
        const VBlockCap('Тип данных нового поля'),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final t in VFieldType.values.take(8))
              _TypeChip(label: t.label, selected: t == VFieldType.text),
          ],
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.def,
    required this.value,
    required this.onChanged,
  });

  final VFieldDef def;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName(def.iconName),
                size: 17, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        def.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (def.isBuiltIn) ...[
                      const SizedBox(width: 7),
                      const VTag('общее', accent: false),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  def.type.label,
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
          const SizedBox(width: 10),
          VSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName('add'), size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: selected
            ? scheme.secondaryContainer
            : scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: selected
              ? scheme.onSecondaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
