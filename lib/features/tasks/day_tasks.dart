import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import 'task_sheet.dart';

/// Задачи со сроком на этот день — полоской над видом дня.
///
/// Внутрь сетки часов они не идут: у задачи срок, а не длительность, и
/// прямоугольник в полосе времени обещал бы занятость, которой нет.
class DayTasks extends ConsumerWidget {
  const DayTasks({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final start = DateTime(day.year, day.month, day.day);
    final tasks = ref
            .watch(tasksInRangeProvider(
                (from: start, to: start.add(const Duration(days: 1)))))
            .valueOrNull ??
        const [];

    if (tasks.isEmpty) return const SizedBox.shrink();

    final inheritance = ref.watch(inheritanceProvider).valueOrNull;
    if (inheritance == null) return const SizedBox.shrink();

    final repo = ref.read(repositoryProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final l = L.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 0, VehaInsets.screen, 6),
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final task in tasks)
            () {
              final ink = EventColors.of(
                  inheritance.colorOfTask(task), theme.brightness);
              return InkWell(
                onTap: () => repo.setTaskDone(task.id, !task.isDone),
                borderRadius: BorderRadius.circular(99),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: ShapeDecoration(
                    color: ink.background,
                    shape: const StadiumBorder(),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        VehaIcons.byName(task.isDone
                            ? 'check'
                            : inheritance.iconOfTask(task)),
                        size: 15,
                        color: ink.foreground,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        task.hasTime
                            ? '${taskDueLabel(l, locale, task, ref.watch(nowProvider)).split(' · ').last} · ${task.title}'
                            : task.title,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ink.foreground,
                          decoration:
                              task.isDone ? TextDecoration.lineThrough : null,
                          decorationColor: ink.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }(),
        ],
      ),
    );
  }
}
