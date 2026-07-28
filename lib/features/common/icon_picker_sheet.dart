import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Выбор иконки из всего набора Material Symbols — четыре с лишним тысячи.
///
/// Список открывается ходовым рядом: девять десятых событий — это подъём,
/// спорт, работа и еда, и ради них листать четыре тысячи не нужно. Всё
/// остальное достаётся поиском.
///
/// Ищем по имени иконки, а имена в наборе английские: «pool», «school»,
/// «cake». Свой перевод для четырёх тысяч имён завести неоткуда, а врать
/// половинчатым словарём хуже, чем честно искать по оригиналу.
Future<String?> askIcon(
  BuildContext context, {
  String? current,
  Color? tint,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _IconPickerSheet(current: current, tint: tint),
    ),
  );
}

class _IconPickerSheet extends StatefulWidget {
  const _IconPickerSheet({required this.current, required this.tint});

  final String? current;
  final Color? tint;

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Что показывать. Пустой запрос — ходовой ряд, иначе совпадения по имени.
  /// Совпадения с начала имени идут первыми: «cake» ищут как торт, а не как
  /// часть «cake_add».
  List<String> get _shown {
    final needle = _query.trim().toLowerCase().replaceAll(' ', '_');
    if (needle.isEmpty) return VehaIcons.pickable;

    final starts = <String>[];
    final contains = <String>[];
    for (final name in VehaIcons.names) {
      if (name.startsWith(needle)) {
        starts.add(name);
      } else if (name.contains(needle)) {
        contains.add(name);
      }
    }
    return [...starts, ...contains];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final shown = _shown;

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
                  VehaInsets.screen, 2, VehaInsets.screen, 10),
              child: Text(
                l.iconPickerTitle,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: ShapeDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  children: [
                    Icon(VehaIcons.byName('search'),
                        size: 19, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        cursorColor: scheme.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                          hintText: l.iconSearchHint,
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    ),
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _controller.clear();
                          _query = '';
                        }),
                        child: Icon(VehaIcons.byName('close'),
                            size: 19, color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 10, VehaInsets.screen, 6),
              child: Text(
                _query.trim().isEmpty
                    ? l.iconPickerCommon
                    : l.iconFound(shown.length),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Flexible(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(
                    VehaInsets.screen, 0, VehaInsets.screen, 20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                // Строим по мере прокрутки: четыре тысячи готовых ячеек
                // съедают и память, и первый кадр.
                itemCount: shown.length,
                itemBuilder: (context, i) => _IconCell(
                  name: shown[i],
                  selected: shown[i] == widget.current,
                  tint: widget.tint,
                  onTap: () => Navigator.pop(context, shown[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.name,
    required this.selected,
    required this.tint,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final Color? tint;
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
              ? (tint ?? scheme.secondaryContainer)
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
