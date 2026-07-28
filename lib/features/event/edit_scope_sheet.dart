import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Область правки повторяющегося события.
enum EditScope {
  /// Одно занятие: выламывается из ряда отдельной записью.
  single,

  /// Это занятие и следующие: ряд разрезается по дате.
  following,

  /// Весь ряд, включая прошедшие занятия.
  series,
}

/// Лист «Что изменить» — спрашивается после «Сохранить».
///
/// Вопрос неизбежен: одно и то же движение пальца может означать «перенеси
/// сегодняшнее» и «теперь всегда так». Спрашиваем в конце, когда правка уже
/// сделана и человеку понятно, о чём речь.
Future<EditScope?> askEditScope(
  BuildContext context, {
  required DateTime occurrence,
  required String repeatLabel,
}) {
  return showModalBottomSheet<EditScope>(
    context: context,
    showDragHandle: true,
    builder: (context) => _EditScopeSheet(
      occurrence: occurrence,
      repeatLabel: repeatLabel,
    ),
  );
}

class _EditScopeSheet extends StatefulWidget {
  const _EditScopeSheet({required this.occurrence, required this.repeatLabel});

  final DateTime occurrence;
  final String repeatLabel;

  @override
  State<_EditScopeSheet> createState() => _EditScopeSheetState();
}

class _EditScopeSheetState extends State<_EditScopeSheet> {
  EditScope _scope = EditScope.single;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final day = DateFormat('d MMMM', locale).format(widget.occurrence);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 4, VehaInsets.screen, 2),
              child: Text(
                'Что изменить',
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 0, VehaInsets.screen, 12),
              child: Text(
                'Занятие повторяется: ${widget.repeatLabel}',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: VBlock(children: [
                VOption(
                  title: 'Только это занятие',
                  subtitle: '$day встанет по-новому, остальные не тронутся',
                  selected: _scope == EditScope.single,
                  onTap: () => setState(() => _scope = EditScope.single),
                ),
                const VSep(inset: 15),
                VOption(
                  title: 'Это и следующие',
                  subtitle: 'Ряд разделится: прошедшие занятия останутся как были',
                  selected: _scope == EditScope.following,
                  onTap: () => setState(() => _scope = EditScope.following),
                ),
                const VSep(inset: 15),
                VOption(
                  title: 'Весь ряд',
                  subtitle: 'Все занятия, включая прошедшие',
                  selected: _scope == EditScope.series,
                  onTap: () => setState(() => _scope = EditScope.series),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(VehaInsets.screen, 16, VehaInsets.screen, 14),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, _scope),
                    icon: Icon(VehaIcons.byName('check'), size: 18),
                    label: const Text('Сохранить'),
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
