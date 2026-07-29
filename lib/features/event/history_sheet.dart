import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/file_service.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// История правок события: что меняли и когда.
///
/// Журнал местный — на сервер не уезжает, как и снимки с вложениями. Нужен он
/// ровно для одного вопроса: «я сам это перенёс или оно само?»
Future<void> showEventHistory(
  BuildContext context, {
  required List<VRevision> history,
}) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: _HistorySheet(history: history),
      ),
    );

class _HistorySheet extends StatelessWidget {
  const _HistorySheet({required this.history});

  final List<VRevision> history;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 0, VehaInsets.screen, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.historyTitle,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          if (history.isEmpty)
            Text(
              l.historyEmpty,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            )
          else
            VBlock(children: [
              for (var i = 0; i < history.length; i++) ...[
                if (i > 0) const VSep(),
                VRow(
                  icon: _iconOf(history[i].kind),
                  label: '${_titleOf(l, history[i].kind)} · '
                      '${DateFormat('d MMMM, HH:mm', locale).format(history[i].at)}',
                  value: _valueOf(history[i], locale),
                ),
              ],
            ]),
        ],
      ),
    );
  }

  static String _iconOf(RevisionKind kind) => switch (kind) {
        RevisionKind.created => 'add',
        RevisionKind.title => 'pencil',
        RevisionKind.time => 'clock',
        RevisionKind.calendar => 'calendar_month',
        RevisionKind.place => 'place',
        RevisionKind.look => 'palette',
        RevisionKind.repeat => 'repeat',
        RevisionKind.reminders => 'bell',
      };

  static String _titleOf(L l, RevisionKind kind) => switch (kind) {
        RevisionKind.created => l.historyCreated,
        RevisionKind.title => l.historyName,
        RevisionKind.time => l.historyTime,
        RevisionKind.calendar => l.eventCalendarAndBranch,
        RevisionKind.place => l.eventPlace,
        RevisionKind.look => l.lookTitle,
        RevisionKind.repeat => l.eventRepeat,
        RevisionKind.reminders => l.eventReminder,
      };

  /// «Было → стало». У заведения события стороны пустые: показывать стрелку
  /// в никуда незачем.
  static String _valueOf(VRevision r, String locale) {
    if (r.kind == RevisionKind.created) return r.after ?? '';
    final before = _side(r, r.before, locale);
    final after = _side(r, r.after, locale);
    if (before.isEmpty) return after;
    if (after.isEmpty) return before;
    return '$before → $after';
  }

  /// Время в журнале лежит двумя ISO-датами: подпись строится здесь, по
  /// сегодняшнему языку, а не по тому, каким он был в день правки.
  static String _side(VRevision r, String? raw, String locale) {
    final value = raw?.trim() ?? '';
    if (r.kind != RevisionKind.time || !value.contains('|')) return value;

    final parts = value.split('|');
    final start = DateTime.tryParse(parts.first);
    final end = DateTime.tryParse(parts.last);
    if (start == null || end == null) return value;

    final day = DateFormat('d MMM', locale).format(start);
    final from = DateFormat.Hm(locale).format(start);
    if (end == start) return '$day, $from';
    return '$day, $from – ${DateFormat.Hm(locale).format(end)}';
  }
}

/// Размер вложения по-человечески. Единицы живут в словаре: «КБ» на семи
/// языках пишется по-разному.
String fileSizeLabel(L l, int bytes) {
  if (bytes < 1024) return l.sizeBytes('$bytes');
  if (bytes < 1024 * 1024) return l.sizeKb('${(bytes / 1024).round()}');
  return l.sizeMb((bytes / 1024 / 1024).toStringAsFixed(1));
}

/// Иконка вложения по расширению: документ, картинка, таблица, архив.
String fileIconOf(String name) {
  final ext = name.toLowerCase().split('.').last;
  return switch (ext) {
    'pdf' => 'picture_as_pdf',
    'jpg' || 'jpeg' || 'png' || 'heic' || 'webp' || 'gif' => 'photo',
    'xls' || 'xlsx' || 'csv' => 'table',
    'zip' || 'rar' || '7z' => 'folder_zip',
    'doc' || 'docx' || 'txt' || 'rtf' => 'description',
    _ => 'attach_file',
  };
}

/// Абсолютный путь вложения — экранам не положено знать про папку приложения.
Future<String> attachmentPath(String relative) => FileService.resolve(relative);
