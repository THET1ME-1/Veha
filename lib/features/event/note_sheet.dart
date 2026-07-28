import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../color/color_picker_screen.dart';

/// Что вернул лист заметки: текст со своим цветом либо просьба удалить.
class NoteDraft {
  const NoteDraft({required this.text, this.color, this.deleted = false});

  const NoteDraft.deleted()
      : text = '',
        color = null,
        deleted = true;

  final String text;

  /// `null` — «как у события». Именно отсутствие цвета, а не скопированный
  /// сверху: перекрасили событие — перекрасились и такие заметки.
  final Color? color;
  final bool deleted;
}

/// Заметка внутри события. Текст и цвет в одном листе: заметка короткая, и
/// разводить их по разным шагам значит делать из записки анкету.
Future<NoteDraft?> askNote(
  BuildContext context, {
  String text = '',
  Color? color,
  required Color inheritedColor,
  bool canDelete = false,
}) {
  return showModalBottomSheet<NoteDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _NoteSheet(
        text: text,
        color: color,
        inheritedColor: inheritedColor,
        canDelete: canDelete,
      ),
    ),
  );
}

class _NoteSheet extends StatefulWidget {
  const _NoteSheet({
    required this.text,
    required this.color,
    required this.inheritedColor,
    required this.canDelete,
  });

  final String text;
  final Color? color;
  final Color inheritedColor;
  final bool canDelete;

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final TextEditingController _text =
      TextEditingController(text: widget.text);
  late Color? _color = widget.color;

  /// Готовые цвета заметок. Свой цвет тут нужен как метка («это важное»),
  /// а не как палитра, поэтому шести хватает — остальное за пипеткой.
  static const _quick = [
    Color(0xFFB4694A),
    Color(0xFFE0A93B),
    Color(0xFF4C9A5B),
    Color(0xFF3B7DD8),
    Color(0xFF8E5CC4),
    Color(0xFFC4485C),
  ];

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ink = EventColors.of(_color ?? widget.inheritedColor, theme.brightness);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 12),
            child: Text(
              'Заметка',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(22)),
                ),
              ),
              child: TextField(
                controller: _text,
                autofocus: widget.text.isEmpty,
                maxLines: null,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: ink.foreground,
                ),
                cursorColor: ink.foreground,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Что не забыть',
                  hintStyle: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: ink.foreground.withValues(alpha: 0.5),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Row(
              children: [
                _Swatch(
                  color: widget.inheritedColor,
                  selected: _color == null,
                  inherited: true,
                  onTap: () => setState(() => _color = null),
                ),
                const SizedBox(width: 10),
                for (final c in _quick) ...[
                  _Swatch(
                    color: c,
                    selected: _color == c,
                    onTap: () => setState(() => _color = c),
                  ),
                  const SizedBox(width: 6),
                ],
                _More(onTap: _pickColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 16, VehaInsets.screen, 14),
            child: Row(
              children: [
                if (widget.canDelete)
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, const NoteDraft.deleted()),
                    icon: Icon(VehaIcons.byName('trash'), size: 18),
                    label: const Text('Удалить'),
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _text.text.trim().isEmpty
                      ? null
                      : () => Navigator.pop(
                            context,
                            NoteDraft(text: _text.text.trim(), color: _color),
                          ),
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: const Text('Готово'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor() async {
    final picked = await Navigator.of(context).push<Color>(
      MaterialPageRoute(
        builder: (_) => ColorPickerScreen(
          initial: _color ?? widget.inheritedColor,
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _color = picked);
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.inherited = false,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;

  /// Кружок «как у события» стоит первым и отличается размером: он не про
  /// выбор оттенка, а про отказ от своего цвета.
  final bool inherited;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ink = EventColors.of(color, theme.brightness);
    final side = inherited ? 34.0 : 30.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: side,
        height: side,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: ink.background,
          shape: const CircleBorder(),
        ),
        child: selected
            ? Icon(VehaIcons.byName('check'), size: 16, color: ink.foreground)
            : null,
      ),
    );
  }
}

class _More extends StatelessWidget {
  const _More({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: scheme.surfaceContainerHigh,
          shape: const CircleBorder(),
        ),
        child: Icon(VehaIcons.byName('dropper'),
            size: 15, color: scheme.onSurfaceVariant),
      ),
    );
  }
}
