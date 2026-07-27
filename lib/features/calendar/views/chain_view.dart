import 'package:flutter/material.dart';

import '../../../core/brand.dart';
import '../../../core/event_colors.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../data/seed.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/month_header.dart';

/// Цепочка дня: пилюли, соединённые нитью.
///
/// Отвечает на вопрос «что у меня сегодня»: пустые часы места не занимают,
/// события идут подряд. Масштаб времени здесь не соблюдается — за него
/// отвечает второе прочтение, часы.
class ChainView extends StatelessWidget {
  const ChainView({
    super.key,
    required this.events,
    required this.inheritance,
    this.now,
  });

  final List<VEvent> events;
  final Inheritance inheritance;

  /// Время линии «сейчас». `null` — линию не рисуем (день не сегодняшний).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var i = 0; i < events.length; i++) {
      final e = events[i];
      final isLast = i == events.length - 1;

      if (now != null &&
          i > 0 &&
          events[i - 1].start.isBefore(now!) &&
          e.start.isAfter(now!)) {
        rows.add(_NowLine(now: now!));
      }

      rows.add(_ChainRow(
        event: e,
        color: inheritance.colorOfEvent(e),
        icon: inheritance.iconOfEvent(e),
        isLast: isLast,
      ));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 8, VehaInsets.screen, 120),
      children: rows,
    );
  }
}

class _ChainRow extends StatelessWidget {
  const _ChainRow({
    required this.event,
    required this.color,
    required this.icon,
    required this.isLast,
  });

  final VEvent event;
  final Color color;
  final String icon;
  final bool isLast;

  static const double _tail = 12;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(color, theme.brightness);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: VehaInsets.timeColumn,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _hhmm(event.start),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(width: VehaInsets.gap),
          SizedBox(
            width: VehaInsets.railColumn,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: VehaInsets.pill,
                      decoration: ShapeDecoration(
                        color: ink.background,
                        shape: const StadiumBorder(),
                      ),
                      // Иконка по центру пилюли, а не прижата к верху.
                      child: Center(
                        child: Icon(VehaIcons.byName(icon),
                            size: 26, color: ink.foreground),
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  SizedBox(
                    height: _tail,
                    child: Center(
                      child: Container(width: 2, color: scheme.outlineVariant),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: VehaInsets.gap),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: _tail),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _When(event: event, scheme: scheme),
                  const SizedBox(height: 3),
                  Text(
                    event.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17.5,
                      height: 1.2,
                      letterSpacing: -0.26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _Fields(event: event, scheme: scheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _When extends StatelessWidget {
  const _When({required this.event, required this.scheme});

  final VEvent event;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: scheme.onSurfaceVariant,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final l = L.of(context);
    final parts = <String>[];
    final start = _hhmm(event.start);
    if (event.duration.inMinutes <= 15) {
      parts.add(start);
    } else {
      parts.add('$start – ${_hhmm(event.end)}');
      parts.add(_human(l, event.duration));
    }
    if (event.recurrenceLabel != null) parts.add(event.recurrenceLabel!);

    return Row(
      children: [
        Flexible(
          child: Text(parts.join(' · '), style: style, overflow: TextOverflow.ellipsis),
        ),
        if (event.recurrenceLabel != null && event.duration.inMinutes <= 15) ...[
          const SizedBox(width: 5),
          Icon(VehaIcons.byName('repeat'), size: 13, color: scheme.onSurfaceVariant),
        ],
      ],
    );
  }

  static String _hhmm(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  static String _human(L l, Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h == 0) return l.durationMinutes(m);
    if (m == 0) return l.durationHours(h);
    return l.durationHoursMinutes(h, m);
  }
}

/// Поля, отмеченные «в карточке». Максимум три: на четырёх строках таймлайн
/// теряет плотность, ради которой его и делали.
class _Fields extends StatelessWidget {
  const _Fields({required this.event, required this.scheme});

  final VEvent event;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    for (final v in event.fields) {
      final def = Seed.fields.where((f) => f.id == v.fieldId).firstOrNull;
      chips.add(_Chip(
        icon: def?.iconName ?? _fallbackIcon(v.fieldId),
        prefix: def == null ? null : _prefixFor(def),
        value: v.value,
        scheme: scheme,
      ));
    }
    // Адрес занимает всю строку, поэтому в цепочку он попадает, только если
    // своих полей у события почти нет.
    if (event.location != null && chips.length < 2) {
      chips.add(_Chip(icon: 'place', value: event.location!, scheme: scheme));
    }

    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Wrap(spacing: 7, runSpacing: 6, children: chips.take(2).toList()),
    );
  }

  static String _fallbackIcon(String fieldId) => switch (fieldId) {
        'f-people' => 'person',
        'f-calendar' => 'cloud',
        _ => 'text',
      };

  /// Подпись поля в чипе не дублируем: её несёт иконка, а в колонке таймлайна
  /// «Кабинет 312» уже не помещается. Полное название видно на экране события.
  static String? _prefixFor(VFieldDef def) => null;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.value,
    required this.scheme,
    this.prefix,
  });

  final String icon;
  final String value;
  final String? prefix;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainer,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(VehaIcons.byName(icon), size: 13, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4.5),
          // Адрес места бывает длиннее экрана, поэтому чип ужимается, а не
          // ломает строку таймлайна.
          Flexible(
            child: Text.rich(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            TextSpan(children: [
              if (prefix != null)
                TextSpan(
                  text: '$prefix ',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              TextSpan(
                text: value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ]),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: scheme.onSurfaceVariant,
            ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Линия «сейчас».
class _NowLine extends StatelessWidget {
  const _NowLine({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: VehaInsets.timeColumn,
            child: Text(
              '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: scheme.error,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: VehaInsets.gap),
          Container(
            width: 8,
            height: 8,
            decoration: ShapeDecoration(color: scheme.error, shape: const CircleBorder()),
          ),
          Expanded(
            child: Container(
              height: 2,
              decoration: ShapeDecoration(
                color: scheme.error,
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
