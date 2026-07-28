import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Готовые сроки напоминаний. Произвольное число минут завести нельзя: выбор
/// из девяти вариантов закрывает жизнь, а поле ввода заставляет считать в уме.
const List<int> reminderPresets = [0, 5, 10, 15, 30, 60, 120, 1440, 10080];

/// Подпись срока. Значения вне списка приезжают по синхронизации с чужого
/// устройства, поэтому запасной вариант обязателен.
String reminderLabel(int minutes) => switch (minutes) {
      0 => 'В момент начала',
      5 => 'За 5 минут',
      10 => 'За 10 минут',
      15 => 'За 15 минут',
      30 => 'За 30 минут',
      60 => 'За час',
      120 => 'За 2 часа',
      1440 => 'За день',
      10080 => 'За неделю',
      final m when m % 1440 == 0 => 'За ${m ~/ 1440} дн.',
      final m when m % 60 == 0 => 'За ${m ~/ 60} ч.',
      final m => 'За $m мин.',
    };

/// Строка «Напоминание» в карточке события.
String remindersLabel(List<int> minutes) {
  if (minutes.isEmpty) return 'Без напоминания';
  final sorted = minutes.toList()..sort((a, b) => b.compareTo(a));
  final parts = [
    for (var i = 0; i < sorted.length; i++)
      i == 0
          ? reminderLabel(sorted[i])
          : reminderLabel(sorted[i]).toLowerCase(),
  ];
  return parts.join(' · ');
}

/// Выбор сроков напоминания. Несколько сразу: «за день» и «за десять минут»
/// отвечают на разные вопросы — успеть подготовиться и успеть дойти.
Future<List<int>?> askReminders(
  BuildContext context, {
  required List<int> current,
}) {
  return showModalBottomSheet<List<int>>(
    context: context,
    showDragHandle: true,
    builder: (context) => _RemindersSheet(current: current),
  );
}

class _RemindersSheet extends StatefulWidget {
  const _RemindersSheet({required this.current});

  final List<int> current;

  @override
  State<_RemindersSheet> createState() => _RemindersSheetState();
}

class _RemindersSheetState extends State<_RemindersSheet> {
  late final Set<int> _chosen = widget.current.toSet();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Сроки, приехавшие с чужого устройства, показываем вместе с готовыми:
    // иначе выбранное человеком пропадает из списка молча.
    final options = <int>{...reminderPresets, ..._chosen}.toList()..sort();

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 4),
            child: Text(
              'Напоминание',
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 0, VehaInsets.screen, 12),
            child: Text(
              'Можно несколько: за день собраться, за десять минут выйти',
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in options)
                  _Chip(
                    label: reminderLabel(m),
                    selected: _chosen.contains(m),
                    onTap: () => setState(() {
                      if (!_chosen.remove(m)) _chosen.add(m);
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 16, VehaInsets.screen, 14),
            child: Row(
              children: [
                TextButton(
                  onPressed: _chosen.isEmpty
                      ? null
                      : () => setState(_chosen.clear),
                  child: const Text('Не напоминать'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _chosen.toList()),
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
}

class _Chip extends StatelessWidget {
  const _Chip({
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
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
            fontSize: 12.5,
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
