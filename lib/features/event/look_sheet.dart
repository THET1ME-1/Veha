import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../l10n/app_localizations.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../color/color_picker_screen.dart';
import '../common/icon_picker_sheet.dart';

/// Внешность события: иконка и цвет.
///
/// Оба поля необязательны — пустое значение означает «как у ветки или
/// календаря». Это и есть наследование на четырёх уровнях: в базе тут `null`,
/// а не скопированное вниз значение.
class EventLook {
  const EventLook({this.iconName, this.color});

  final String? iconName;
  final Color? color;
}

Future<EventLook?> askEventLook(
  BuildContext context, {
  required EventLook current,
  required Color inheritedColor,
  required String inheritedIcon,
}) {
  return showModalBottomSheet<EventLook>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _LookSheet(
      current: current,
      inheritedColor: inheritedColor,
      inheritedIcon: inheritedIcon,
    ),
  );
}

class _LookSheet extends StatefulWidget {
  const _LookSheet({
    required this.current,
    required this.inheritedColor,
    required this.inheritedIcon,
  });

  final EventLook current;
  final Color inheritedColor;
  final String inheritedIcon;

  @override
  State<_LookSheet> createState() => _LookSheetState();
}

class _LookSheetState extends State<_LookSheet> {
  late String? _icon = widget.current.iconName;
  late Color? _color = widget.current.color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final color = _color ?? widget.inheritedColor;
    final ink = EventColors.of(color, theme.brightness);
    final icon = _icon ?? widget.inheritedIcon;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 2, VehaInsets.screen, 10),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: ink.background,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(VehaIcons.byName(icon),
                        size: 22, color: ink.foreground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.lookTitle,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      EventLook(iconName: _icon, color: _color),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 11),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(l.actionDone),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
              child: Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _Chip(
                    label: l.lookInherit,
                    selected: _color == null && _icon == null,
                    onTap: () => setState(() {
                      _color = null;
                      _icon = null;
                    }),
                  ),
                  _Chip(
                    label: l.lookOwnColor,
                    selected: _color != null,
                    onTap: _pickColor,
                  ),
                  _Chip(
                    label: l.iconPickerTitle,
                    selected: _icon != null,
                    onTap: _pickIcon,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    final picked = await askIcon(
      context,
      current: _icon ?? widget.inheritedIcon,
      tint: _color ?? widget.inheritedColor,
    );
    if (picked == null) return;
    setState(() => _icon = picked);
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

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: ShapeDecoration(
          color: selected
              ? scheme.primaryContainer
              : scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

