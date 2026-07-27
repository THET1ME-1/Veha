import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../calendar/widgets/month_header.dart';

/// Чем закончился вызов инструмента.
enum LogResult { ok, denied, needsConfirm }

class LogEntry {
  const LogEntry({
    required this.time,
    required this.tool,
    required this.detail,
    required this.result,
  });

  final String time;

  /// Имя MCP-инструмента: `list_events`, `create_event`.
  final String tool;
  final String detail;
  final LogResult result;
}

/// Журнал ключа: что и когда агент делал.
///
/// То, что превращает опасную фичу в аргумент. В Google Calendar не видно,
/// что именно творило стороннее приложение, — здесь видно, включая отказы.
class KeyLogScreen extends StatelessWidget {
  const KeyLogScreen({
    super.key,
    required this.keyName,
    required this.keyPrefix,
    required this.days,
  });

  final String keyName;
  final String keyPrefix;

  /// Записи, сгруппированные по дню: «Сегодня», «Вчера» и так далее.
  final List<(String, List<LogEntry>)> days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Text(
          keyName,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 28,
            letterSpacing: -0.9,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          keyPrefix,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: scheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        for (final (title, entries) in days) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final e in entries) ...[
            _Entry(entry: e),
            const SizedBox(height: 6),
          ],
        ],
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.entry});

  final LogEntry entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Text(
              entry.time,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.tool,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.detail,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _Pin(result: entry.result),
        ],
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({required this.result});

  final LogResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, bg, fg) = switch (result) {
      LogResult.ok => (
          'ок',
          scheme.secondaryContainer,
          scheme.onSecondaryContainer
        ),
      LogResult.denied => (
          'отказ',
          scheme.errorContainer,
          scheme.onErrorContainer
        ),
      // Удаление требует подтверждения: первый вызов только показывает,
      // что будет удалено, и ждёт второго.
      LogResult.needsConfirm => (
          'стоп',
          scheme.errorContainer,
          scheme.onErrorContainer
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: ShapeDecoration(color: bg, shape: const StadiumBorder()),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}
