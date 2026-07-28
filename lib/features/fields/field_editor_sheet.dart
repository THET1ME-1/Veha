import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import 'field_types.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Что вернул редактор поля: имя с типом и иконкой либо просьба удалить.
class FieldDraft {
  const FieldDraft({
    required this.name,
    required this.type,
    required this.iconName,
    this.deleted = false,
  });

  const FieldDraft.deleted()
      : name = '',
        type = VFieldType.text,
        iconName = 'text',
        deleted = true;

  final String name;
  final VFieldType type;
  final String iconName;
  final bool deleted;
}

/// Заведение и правка своего поля. Одна форма на оба случая: разница только
/// в заголовке и в том, можно ли удалить.
///
/// Тип поля решает, чем его заполнять, поэтому он стоит рядом с именем, а не
/// прячется за отдельным шагом.
Future<FieldDraft?> askFieldDraft(
  BuildContext context, {
  required String title,
  String name = '',
  VFieldType type = VFieldType.text,
  String iconName = 'text',
  bool canDelete = false,
}) {
  return showModalBottomSheet<FieldDraft>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _FieldEditorSheet(
        title: title,
        name: name,
        type: type,
        iconName: iconName,
        canDelete: canDelete,
      ),
    ),
  );
}

class _FieldEditorSheet extends StatefulWidget {
  const _FieldEditorSheet({
    required this.title,
    required this.name,
    required this.type,
    required this.iconName,
    required this.canDelete,
  });

  final String title;
  final String name;
  final VFieldType type;
  final String iconName;
  final bool canDelete;

  @override
  State<_FieldEditorSheet> createState() => _FieldEditorSheetState();
}

class _FieldEditorSheetState extends State<_FieldEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.name);
  late VFieldType _type = widget.type;
  late String _icon = widget.iconName;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: scheme.surfaceContainerHigh,
                      shape: const CircleBorder(),
                    ),
                    child: Icon(VehaIcons.byName(_icon),
                        size: 24, color: scheme.onSurfaceVariant),
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
                        hintText: l.fieldNamePlaceholder,
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
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
              child: Text(
                l.fieldKind,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in VFieldType.values)
                    _TypeChip(
                      label: fieldTypeLabel(l, t),
                      selected: t == _type,
                      onTap: () => setState(() => _type = t),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(
                    VehaInsets.screen, 0, VehaInsets.screen, 8),
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final name in VehaIcons.pickable)
                    _IconCell(
                      name: name,
                      selected: name == _icon,
                      onTap: () => setState(() => _icon = name),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 6, VehaInsets.screen, 14),
              child: Row(
                children: [
                  if (widget.canDelete)
                    TextButton.icon(
                      onPressed: () =>
                          Navigator.pop(context, const FieldDraft.deleted()),
                      icon: Icon(VehaIcons.byName('trash'), size: 18),
                      label: Text(l.actionDelete),
                      style: TextButton.styleFrom(foregroundColor: scheme.error),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _name.text.trim().isEmpty
                        ? null
                        : () => Navigator.pop(
                              context,
                              FieldDraft(
                                name: _name.text.trim(),
                                type: _type,
                                iconName: _icon,
                              ),
                            ),
                    icon: Icon(VehaIcons.byName('check'), size: 18),
                    label: Text(l.actionDone),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: ShapeDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHigh,
          shape: const StadiumBorder(),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.body,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? scheme.onSecondaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: selected
              ? scheme.secondaryContainer
              : scheme.surfaceContainerHigh,
          shape: const CircleBorder(),
        ),
        child: Icon(
          VehaIcons.byName(name),
          size: 20,
          color:
              selected ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
