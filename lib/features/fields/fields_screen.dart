import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'field_types.dart';
import '../calendar/widgets/month_header.dart';
import '../calendars/calendar_editor_sheet.dart';
import '../common/blocks.dart';
import 'field_editor_sheet.dart';

/// Верхний уровень редактора полей: группы и их наборы.
///
/// Поле принадлежит группе, а не всем событиям сразу: номер карты нужен
/// абонементу и не нужен уроку английского. Группа — это календарь, поэтому
/// «создать группу» заводит календарь, а не вторую сущность рядом.
class FieldGroupsScreen extends ConsumerWidget {
  const FieldGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = L.of(context);
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;
    final fields = ref.watch(fieldDefsProvider).valueOrNull;
    if (inheritance == null || fields == null) return const SizedBox.shrink();

    final calendars = inheritance.calendars.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final shared = fields.where((f) => f.calendarId == null).toList();

    return Scaffold(
      // Заголовок крупный и слева, как на остальных экранах: в шапке остаётся
      // только стрелка назад.
      appBar: AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            VehaInsets.screen, 0, VehaInsets.screen, 120),
        children: [
          Text(
            l.fieldsTitle,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.9,
              color: theme.colorScheme.onSurface,
            ),
          ),
          VBlockCap(l.fieldsShared),
          VBlock(children: [
            VRow(
              icon: 'text',
              value: l.fieldsSharedRow,
              label: shared.isEmpty
                  ? l.fieldsNoneYet
                  : shared.map((f) => f.name.toLowerCase()).join(', '),
              labelFirst: false,
              trailing: _Count(shared.length),
            ),
          ]),
          VBlockCap(l.fieldsGroups),
          VBlock(children: [
            for (var i = 0; i < calendars.length; i++) ...[
              if (i > 0) const VSep(),
              _GroupRow(
                calendar: calendars[i],
                fields: fields
                    .where((f) => f.calendarId == calendars[i].id)
                    .toList(),
                brightness: theme.brightness,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FieldsOfGroupScreen(calendar: calendars[i]),
                  ),
                ),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          VBlock(
            color: theme.colorScheme.surfaceContainer,
            children: [
              _AddRow(
                text: l.fieldsGroupCreate,
                onTap: () => _createGroup(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Группа полей и календарь — одно и то же: у каждого календаря свой набор.
  /// Отдельной сущности «группа» нет, иначе человеку пришлось бы держать в
  /// голове две пересекающиеся иерархии.
  static Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final draft = await askCalendarDraft(
      context,
      title: L.of(context).fieldsGroupNew,
      inheritedColor: VehaBrand.seed,
    );
    if (draft == null || draft.deleted) return;

    final repo = ref.read(repositoryProvider);
    await repo.upsertCalendar(VCalendar(
      id: repo.newId(),
      name: draft.name,
      iconName: draft.iconName,
      color: draft.color,
      sortOrder: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ));
  }
}

class _GroupRow extends StatelessWidget {
  const _GroupRow({
    required this.calendar,
    required this.fields,
    required this.brightness,
    required this.onTap,
  });

  final VCalendar calendar;
  final List<VFieldDef> fields;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final ink = EventColors.of(calendar.color, brightness);
    return VRow(
      icon: calendar.iconName,
      iconBackground: ink.background,
      iconColor: ink.foreground,
      value: calendar.name,
      label: fields.isEmpty
          ? l.fieldsGroupEmpty
          : fields.map((f) => f.name.toLowerCase()).join(', '),
      labelFirst: false,
      onTap: onTap,
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
///
/// Общие поля показаны здесь же: человек не должен различать, что зашито в
/// приложение, а что он завёл сам. Отличие одно — общее поле нельзя удалить
/// из группы, оно принадлежит всем.
class FieldsOfGroupScreen extends ConsumerWidget {
  const FieldsOfGroupScreen({super.key, required this.calendar});

  final VCalendar calendar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final all = ref.watch(fieldDefsProvider).valueOrNull;
    if (all == null) return const SizedBox.shrink();

    final fields = [
      ...all.where((f) => f.calendarId == null),
      ...all.where((f) => f.calendarId == calendar.id),
    ];
    final own = fields.where((f) => !f.isBuiltIn).length;
    final inCard = fields.where((f) => f.showInCard).length;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            VehaInsets.screen, 0, VehaInsets.screen, 120),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  calendar.name,
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
                  '${l.fieldsOwnCount(own)} · ${l.fieldsInCard(inCard)}',
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
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) const VSep(),
              _FieldRow(
                def: fields[i],
                onChanged: (v) => ref
                    .read(repositoryProvider)
                    .setFieldShownInCard(fields[i].id, v),
                onTap: fields[i].isBuiltIn
                    ? null
                    : () => _editField(context, ref, fields[i]),
              ),
            ],
            const VSep(),
            _AddRow(
              text: l.fieldAddTo(calendar.name),
              onTap: () => _addField(context, ref),
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _addField(BuildContext context, WidgetRef ref) async {
    final draft = await askFieldDraft(
      context,
      title: L.of(context).fieldNewIn(calendar.name),
    );
    if (draft == null || draft.deleted) return;

    final repo = ref.read(repositoryProvider);
    await repo.upsertFieldDef(VFieldDef(
      id: repo.newId(),
      name: draft.name,
      type: draft.type,
      iconName: draft.iconName,
      calendarId: calendar.id,
      // Растущий порядок ставит новое поле в конец списка.
      sortOrder: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ));
  }

  Future<void> _editField(
    BuildContext context,
    WidgetRef ref,
    VFieldDef def,
  ) async {
    final draft = await askFieldDraft(
      context,
      title: L.of(context).fieldOne,
      name: def.name,
      type: def.type,
      iconName: def.iconName,
      canDelete: true,
    );
    if (draft == null) return;

    final repo = ref.read(repositoryProvider);
    if (draft.deleted) {
      await repo.deleteFieldDef(def.id);
    } else {
      await repo.upsertFieldDef(VFieldDef(
        id: def.id,
        name: draft.name,
        type: draft.type,
        iconName: draft.iconName,
        calendarId: def.calendarId,
        showInCard: def.showInCard,
        sortOrder: def.sortOrder,
      ));
    }
  }

}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.def,
    required this.onChanged,
    required this.onTap,
  });

  final VFieldDef def;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                        VTag(l.fieldShared, accent: false),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    fieldTypeLabel(l, def.type),
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
            VSwitch(value: def.showInCard, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _AddRow extends StatelessWidget {
  const _AddRow({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
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
              child:
                  Icon(VehaIcons.byName('add'), size: 18, color: scheme.primary),
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
      ),
    );
  }
}
