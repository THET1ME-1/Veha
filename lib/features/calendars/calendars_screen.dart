import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';
import 'calendar_editor_sheet.dart';

/// Календари и их ветки. Плашка справа говорит, откуда взят цвет:
/// наследуется от календаря или задан у ветки.
///
/// Тумблер скрывает календарь из видов, не трогая события: «не показывай
/// сейчас» и «удали» — разные намерения, и путать их дорого.
class CalendarsScreen extends ConsumerWidget {
  const CalendarsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;

    // Пока база отдаёт первую порцию, показываем пустой каркас: крутящийся
    // спиннер на списке из четырёх строк — худшее, что можно сделать.
    if (inheritance == null) return const SizedBox.shrink();

    final calendars = inheritance.calendars.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

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
                  'Календари',
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 30,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () => _createCalendar(context, ref),
                icon: Icon(VehaIcons.byName('add'), size: 18),
                label: const Text('Новый'),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        if (calendars.isEmpty)
          _Empty(onCreate: () => _createCalendar(context, ref))
        else
          for (final c in calendars) ...[
            _Group(
              calendar: c,
              subcategories: inheritance.subcategories.values
                  .where((s) => s.calendarId == c.id)
                  .toList(),
              inheritance: inheritance,
              onToggle: (v) => ref
                  .read(repositoryProvider)
                  .setCalendarVisible(c.id, v),
              onEdit: () => _editCalendar(context, ref, c),
              onAddSub: () => _createSubcategory(context, ref, c),
              onEditSub: (s) => _editSubcategory(context, ref, c, s),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  static Future<void> _createCalendar(
      BuildContext context, WidgetRef ref) async {
    final draft = await askCalendarDraft(
      context,
      title: 'Новый календарь',
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

  static Future<void> _editCalendar(
    BuildContext context,
    WidgetRef ref,
    VCalendar calendar,
  ) async {
    final draft = await askCalendarDraft(
      context,
      title: 'Календарь',
      name: calendar.name,
      iconName: calendar.iconName,
      color: calendar.color,
      inheritedColor: calendar.color,
      canDelete: true,
    );
    if (draft == null) return;

    final repo = ref.read(repositoryProvider);
    if (draft.deleted) {
      await repo.deleteCalendar(calendar.id);
    } else {
      await repo.upsertCalendar(VCalendar(
        id: calendar.id,
        name: draft.name,
        iconName: draft.iconName,
        color: draft.color,
        isVisible: calendar.isVisible,
        sortOrder: calendar.sortOrder,
      ));
    }
  }

  static Future<void> _createSubcategory(
    BuildContext context,
    WidgetRef ref,
    VCalendar parent,
  ) async {
    final draft = await askCalendarDraft(
      context,
      title: 'Ветка «${parent.name}»',
      iconName: parent.iconName,
      inheritedColor: parent.color,
      colorOptional: true,
    );
    if (draft == null || draft.deleted) return;

    final repo = ref.read(repositoryProvider);
    await repo.upsertSubcategory(VSubcategory(
      id: repo.newId(),
      calendarId: parent.id,
      name: draft.name,
      iconName: draft.iconName == parent.iconName ? null : draft.iconName,
      color: draft.color == parent.color ? null : draft.color,
      // Растущий порядок ставит новую ветку в конец списка, как и новый
      // календарь: заведённое сейчас не должно прыгать наверх.
      sortOrder: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ));
  }

  static Future<void> _editSubcategory(
    BuildContext context,
    WidgetRef ref,
    VCalendar parent,
    VSubcategory sub,
  ) async {
    final draft = await askCalendarDraft(
      context,
      title: 'Ветка',
      name: sub.name,
      iconName: sub.iconName ?? parent.iconName,
      color: sub.color,
      inheritedColor: parent.color,
      canDelete: true,
      colorOptional: true,
    );
    if (draft == null) return;

    final repo = ref.read(repositoryProvider);
    if (draft.deleted) {
      await repo.deleteSubcategory(sub.id);
    } else {
      await repo.upsertSubcategory(VSubcategory(
        id: sub.id,
        calendarId: parent.id,
        name: draft.name,
        iconName: draft.iconName == parent.iconName ? null : draft.iconName,
        color: draft.color == parent.color ? null : draft.color,
        sortOrder: sub.sortOrder,
      ));
    }
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ни одного календаря',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Календарь задаёт цвет и иконку всем событиям внутри. Обычно их '
            'три-четыре: дом, работа, учёба, спорт.',
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCreate,
            icon: Icon(VehaIcons.byName('add'), size: 18),
            label: const Text('Завести календарь'),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.calendar,
    required this.subcategories,
    required this.inheritance,
    required this.onToggle,
    required this.onEdit,
    required this.onAddSub,
    required this.onEditSub,
  });

  final VCalendar calendar;
  final List<VSubcategory> subcategories;
  final Inheritance inheritance;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onAddSub;
  final ValueChanged<VSubcategory> onEditSub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(calendar.color, theme.brightness);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
        ),
      ),
      child: Column(
        children: [
          VRow(
            icon: calendar.iconName,
            iconBackground: ink.background,
            iconColor: ink.foreground,
            value: calendar.name,
            label: subcategories.isEmpty
                ? 'Без веток'
                : '${subcategories.length} ${_plural(subcategories.length)}',
            labelFirst: false,
            onTap: onEdit,
            trailing: VSwitch(value: calendar.isVisible, onChanged: onToggle),
          ),
          for (final s in subcategories)
            _SubRow(
              sub: s,
              inheritance: inheritance,
              brightness: theme.brightness,
              onTap: () => onEditSub(s),
            ),
          _AddSub(onTap: onAddSub),
        ],
      ),
    );
  }

  static String _plural(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'ветка';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'ветки';
    }
    return 'веток';
  }
}

class _SubRow extends StatelessWidget {
  const _SubRow({
    required this.sub,
    required this.inheritance,
    required this.brightness,
    required this.onTap,
  });

  final VSubcategory sub;
  final Inheritance inheritance;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = inheritance.colorOfSubcategory(sub);
    final ink = EventColors.of(color, brightness);
    final ownColor = inheritance.subcategoryHasOwnColor(sub);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(52, 8, 15, 8),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const CircleBorder(),
              ),
              child: Icon(
                VehaIcons.byName(
                    sub.iconName ?? inheritance.calendars[sub.calendarId]?.iconName),
                size: 13,
                color: ink.foreground,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sub.name,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            VTag(ownColor ? 'свой цвет' : 'наследует', accent: ownColor),
          ],
        ),
      ),
    );
  }
}

class _AddSub extends StatelessWidget {
  const _AddSub({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(52, 10, 15, 8),
        child: Row(
          children: [
            Icon(VehaIcons.byName('add'), size: 17, color: scheme.primary),
            const SizedBox(width: 9),
            Text(
              'Добавить ветку',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
