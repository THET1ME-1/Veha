import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';
import 'task_sheet.dart';

/// Задачи списком: в работе сверху, сделанные под чертой.
///
/// Задача отличается от события отметкой и необязательным сроком. Событие
/// либо состоялось, либо нет — галочка ему ничего не сообщает; задачу же
/// закрывают, и это главное, что с ней делают.
class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;
    final tasks = ref.watch(tasksProvider).valueOrNull;

    if (inheritance == null || tasks == null) return const SizedBox.shrink();

    final open = [for (final t in tasks) if (!t.isDone) t];
    final done = [for (final t in tasks) if (t.isDone) t];
    final now = ref.watch(nowProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  l.navTasks,
                  style: TextStyle(
                    fontFamily: AppFonts.display,
                    fontSize: 30,
                    letterSpacing: -1,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (open.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    l.tasksOpenCount(open.length),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (tasks.isEmpty)
          const _Empty()
        else ...[
          if (open.isNotEmpty)
            VBlock(children: [
              for (var i = 0; i < open.length; i++) ...[
                if (i > 0) const VSep(inset: 62),
                _TaskRow(
                  task: open[i],
                  inheritance: inheritance,
                  locale: locale,
                  now: now,
                  onToggle: () => ref
                      .read(repositoryProvider)
                      .setTaskDone(open[i].id, true),
                  onTap: () => _edit(context, ref, open[i], inheritance),
                ),
              ],
            ]),
          if (done.isNotEmpty) ...[
            VBlockCap(l.tasksDoneSection),
            VBlock(children: [
              for (var i = 0; i < done.length; i++) ...[
                if (i > 0) const VSep(inset: 62),
                _TaskRow(
                  task: done[i],
                  inheritance: inheritance,
                  locale: locale,
                  now: now,
                  onToggle: () => ref
                      .read(repositoryProvider)
                      .setTaskDone(done[i].id, false),
                  onTap: () => _edit(context, ref, done[i], inheritance),
                ),
              ],
            ]),
          ],
        ],
      ],
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    VTask task,
    Inheritance inheritance,
  ) async {
    final outcome = await askTask(
      context,
      task: task,
      inheritance: inheritance,
      canDelete: true,
    );
    if (outcome == null) return;

    final repo = ref.read(repositoryProvider);
    if (outcome.deleted) {
      await repo.deleteTask(task.id);
      if (!context.mounted) return;
      // Полоска с возвратом: удаление мягкое, и несколько секунд строка ещё
      // лежит в базе — успеть передумать можно.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(L.of(context).msgTaskDeleted),
        action: SnackBarAction(
          label: L.of(context).actionUndo,
          onPressed: () => repo.restoreTask(task.id),
        ),
      ));
    } else {
      await repo.upsertTask(outcome.task);
    }
  }
}

/// Заведение задачи. Вынесено наружу: кнопку держит оболочка приложения.
Future<void> createTask(
  BuildContext context,
  WidgetRef ref,
  Inheritance inheritance, {
  DateTime? due,
}) async {
  final repo = ref.read(repositoryProvider);
  final first = inheritance.calendars.values.toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  if (first.isEmpty) return;

  final outcome = await askTask(
    context,
    task: VTask(
      id: repo.newId(),
      calendarId: first.first.id,
      title: '',
      due: due,
    ),
    inheritance: inheritance,
  );
  if (outcome == null) return;
  await repo.upsertTask(outcome.task);
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.inheritance,
    required this.locale,
    required this.now,
    required this.onToggle,
    required this.onTap,
  });

  final VTask task;
  final Inheritance inheritance;
  final String locale;
  final DateTime now;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final color = inheritance.colorOfTask(task);
    final ink = EventColors.of(color, theme.brightness);
    final overdue = task.isOverdue(now);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        child: Row(
          children: [
            // Отметка — самое частое действие, поэтому у неё своя область
            // нажатия: попасть в кружок проще, чем открыть лист и закрыть.
            InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(99),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: ink.background,
                  shape: const CircleBorder(),
                ),
                child: Icon(
                  VehaIcons.byName(
                      task.isDone ? 'check' : inheritance.iconOfTask(task)),
                  size: 17,
                  color: ink.foreground,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: task.isDone
                          ? scheme.onSurfaceVariant
                          : scheme.onSurface,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                      decorationColor: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (task.due != null || task.notes != null)
                    Text(
                      [
                        if (task.due != null) taskDueLabel(l, locale, task, now),
                        if (task.notes != null) task.notes!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: overdue ? scheme.error : scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (overdue) ...[
              const SizedBox(width: 8),
              VTag(l.taskOverdue, accent: false),
            ],
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(VehaIcons.byName('task_alt'), size: 26, color: scheme.primary),
          const SizedBox(height: 12),
          Text(
            l.tasksEmpty,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 19,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l.tasksEmptyHint,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
