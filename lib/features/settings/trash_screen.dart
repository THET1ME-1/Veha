import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Что лежит в корзине. Отдельным провайдером, а не потоком: список смотрят
/// раз в полгода, а держать ради этого живую подписку незачем.
final trashProvider = FutureProvider.autoDispose<
    ({List<VEvent> events, List<VTask> tasks})>((ref) async {
  final repo = ref.watch(repositoryProvider);
  return (events: await repo.deletedEvents(), tasks: await repo.deletedTasks());
});

/// Корзина: удалённое, которое ещё можно вернуть.
///
/// Мягкое удаление было в приложении с первого дня — иначе сервер возвращал бы
/// стёртое обратно на ближайшем синке. Корзина просто даёт на него посмотреть:
/// человек знает, что удалил лишнее, обычно на другой день.
class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final inheritance = ref.watch(inheritanceProvider).valueOrNull;
    final trash = ref.watch(trashProvider).valueOrNull;

    final events = trash?.events ?? const <VEvent>[];
    final tasks = trash?.tasks ?? const <VTask>[];
    final empty = events.isEmpty && tasks.isEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 40),
      children: [
        Text(
          l.trashTitle,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            letterSpacing: -1,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 14),
          child: Text(
            l.trashHint,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (empty)
          _Note(text: l.trashEmpty)
        else ...[
          if (events.isNotEmpty)
            VBlock(children: [
              for (var i = 0; i < events.length; i++) ...[
                if (i > 0) const VSep(inset: 62),
                _Row(
                  title: events[i].title,
                  subtitle: DateFormat('d MMMM, HH:mm', locale)
                      .format(events[i].start),
                  color: inheritance?.colorOfEvent(events[i]),
                  icon: inheritance?.iconOfEvent(events[i]) ?? 'calendar',
                  onRestore: () async {
                    await ref
                        .read(repositoryProvider)
                        .restoreEvent(events[i].id);
                    ref.invalidate(trashProvider);
                    if (context.mounted) {
                      _say(context, l.msgRestored(events[i].title));
                    }
                  },
                ),
              ],
            ]),
          if (tasks.isNotEmpty) ...[
            VBlockCap(l.navTasks),
            VBlock(children: [
              for (var i = 0; i < tasks.length; i++) ...[
                if (i > 0) const VSep(inset: 62),
                _Row(
                  title: tasks[i].title,
                  subtitle: tasks[i].due == null
                      ? l.taskNoDue
                      : DateFormat('d MMMM', locale).format(tasks[i].due!),
                  color: inheritance?.colorOfTask(tasks[i]),
                  icon: inheritance?.iconOfTask(tasks[i]) ?? 'check',
                  onRestore: () async {
                    await ref.read(repositoryProvider).restoreTask(tasks[i].id);
                    ref.invalidate(trashProvider);
                    if (context.mounted) {
                      _say(context, l.msgRestored(tasks[i].title));
                    }
                  },
                ),
              ],
            ]),
          ],
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: TextButton.icon(
              onPressed: () => _clear(context, ref),
              icon: Icon(VehaIcons.byName('trash'), size: 18),
              label: Text(l.trashClear),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _clear(BuildContext context, WidgetRef ref) async {
    final l = L.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l.trashClear),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (yes != true) return;

    final count = await ref.read(repositoryProvider).emptyTrash();
    ref.invalidate(trashProvider);
    if (context.mounted) _say(context, l.msgTrashCleared(count));
  }

  static void _say(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onRestore,
  });

  final String title;
  final String subtitle;
  final Color? color;
  final String icon;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = color == null
        ? null
        : EventColors.of(color!, theme.brightness);

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: ink?.background ?? scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName(icon),
                size: 17, color: ink?.foreground ?? scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
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
          TextButton(
            onPressed: onRestore,
            child: Text(L.of(context).trashRestore),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
