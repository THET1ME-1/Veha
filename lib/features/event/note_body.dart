import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../domain/note_markup.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Тело заметки: списки, галочки и ссылки.
///
/// Галочка отмечается прямо в карточке — открывать правку, чтобы вычеркнуть
/// пункт, значит превращать список покупок в анкету. Ссылка нажимается там
/// же: адрес встречи чаще открывают, чем правят.
class NoteBody extends StatelessWidget {
  const NoteBody({
    super.key,
    required this.text,
    required this.ink,
    this.onToggle,
    this.onLink,
  });

  final String text;

  /// Цвет заметки: фон карточки и знак берутся из него тонами HCT.
  final Color ink;

  /// Номер строки в исходном тексте — по нему заметка и правится.
  final ValueChanged<int>? onToggle;
  final ValueChanged<String>? onLink;

  @override
  Widget build(BuildContext context) {
    final colors = EventColors.of(ink, Theme.of(context).brightness);
    final lines = parseNote(text);

    final style = TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 13.5,
      height: 1.35,
      fontWeight: FontWeight.w500,
      color: colors.foreground,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines.length; i++)
          _Line(
            line: lines[i],
            style: style,
            mark: colors.foreground,
            onToggle: onToggle == null ? null : () => onToggle!(i),
            onLink: onLink,
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.line,
    required this.style,
    required this.mark,
    this.onToggle,
    this.onLink,
  });

  final NoteLine line;
  final TextStyle style;
  final Color mark;
  final VoidCallback? onToggle;
  final ValueChanged<String>? onLink;

  @override
  Widget build(BuildContext context) {
    final body = Text.rich(
      TextSpan(
        children: [
          for (final span in line.spans)
            if (span.link == null)
              TextSpan(text: span.text)
            else
              TextSpan(
                text: span.text,
                style: TextStyle(
                  // Подчёркивание, а не другой цвет: цвет заметки уже занят
                  // её собственной меткой, и второй смысл в него не влезет.
                  decoration: TextDecoration.underline,
                  decorationColor: mark.withValues(alpha: 0.5),
                ),
                recognizer: onLink == null
                    ? null
                    : (TapGestureRecognizer()
                      ..onTap = () => onLink!(span.link!)),
              ),
        ],
      ),
      style: style,
    );

    if (line.kind == NoteLineKind.text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: body,
      );
    }

    final isCheck = line.kind == NoteLineKind.check;
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 7),
            child: Icon(
              VehaIcons.byName(isCheck
                  ? (line.checked ? 'check_box' : 'check_box_outline_blank')
                  : 'circle'),
              size: isCheck ? 17 : 15,
              color: mark.withValues(alpha: line.checked ? 0.6 : 1),
            ),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: line.checked
                  // Сделанный пункт вычеркнут и приглушён: он остаётся на
                  // виду, но перестаёт спорить за внимание с остальными.
                  ? TextStyle(
                      decoration: TextDecoration.lineThrough,
                      decorationColor: mark.withValues(alpha: 0.6),
                      color: mark.withValues(alpha: 0.6),
                    )
                  : null,
              child: body,
            ),
          ),
        ],
      ),
    );

    if (!isCheck || onToggle == null) return row;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: row,
    );
  }
}
