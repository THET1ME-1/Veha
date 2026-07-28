import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../event/look_sheet.dart';

/// Что вернул редактор: имя с внешностью либо просьба удалить.
class CalendarDraft {
  const CalendarDraft({
    required this.name,
    required this.iconName,
    required this.color,
    this.deleted = false,
  });

  const CalendarDraft.deleted()
      : name = '',
        iconName = 'calendar',
        color = VehaBrand.seed,
        deleted = true;

  final String name;
  final String iconName;
  final Color color;
  final bool deleted;
}

/// Заведение и правка календаря или ветки. Одна форма на оба случая: разница
/// только в заголовке и в том, обязателен ли свой цвет.
Future<CalendarDraft?> askCalendarDraft(
  BuildContext context, {
  required String title,
  String name = '',
  String iconName = 'calendar',
  Color? color,
  required Color inheritedColor,
  bool canDelete = false,
  bool colorOptional = false,
}) {
  return showModalBottomSheet<CalendarDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _CalendarEditorSheet(
        title: title,
        name: name,
        iconName: iconName,
        color: color,
        inheritedColor: inheritedColor,
        canDelete: canDelete,
        colorOptional: colorOptional,
      ),
    ),
  );
}

class _CalendarEditorSheet extends StatefulWidget {
  const _CalendarEditorSheet({
    required this.title,
    required this.name,
    required this.iconName,
    required this.color,
    required this.inheritedColor,
    required this.canDelete,
    required this.colorOptional,
  });

  final String title;
  final String name;
  final String iconName;
  final Color? color;
  final Color inheritedColor;
  final bool canDelete;
  final bool colorOptional;

  @override
  State<_CalendarEditorSheet> createState() => _CalendarEditorSheetState();
}

class _CalendarEditorSheetState extends State<_CalendarEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.name);
  late String _icon = widget.iconName;
  late Color? _color = widget.color;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = _color ?? widget.inheritedColor;
    final ink = EventColors.of(color, theme.brightness);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 12),
            child: Text(
              widget.title,
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
            child: Row(
              children: [
                InkWell(
                  onTap: _pickLook,
                  borderRadius: BorderRadius.circular(99),
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: ink.background,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(VehaIcons.byName(_icon),
                        size: 24, color: ink.foreground),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _name,
                    autofocus: widget.name.isEmpty,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: scheme.onSurface,
                    ),
                    cursorColor: scheme.primary,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      hintText: 'Название',
                      hintStyle: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.4,
                        color: scheme.outline,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 18, VehaInsets.screen, 14),
            child: Row(
              children: [
                if (widget.canDelete)
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, const CalendarDraft.deleted()),
                    icon: Icon(VehaIcons.byName('trash'), size: 18),
                    label: const Text('Удалить'),
                    style:
                        TextButton.styleFrom(foregroundColor: scheme.error),
                  ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _name.text.trim().isEmpty
                      ? null
                      : () => Navigator.pop(
                            context,
                            CalendarDraft(
                              name: _name.text.trim(),
                              iconName: _icon,
                              color: _color ?? widget.inheritedColor,
                            ),
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

  Future<void> _pickLook() async {
    final look = await askEventLook(
      context,
      current: EventLook(iconName: _icon, color: _color),
      inheritedColor: widget.inheritedColor,
      inheritedIcon: _icon,
    );
    if (look == null) return;
    setState(() {
      _icon = look.iconName ?? _icon;
      _color = look.color ?? (widget.colorOptional ? null : _color);
    });
  }
}
