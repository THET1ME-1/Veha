import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';

enum MonthRule { byDate, byPosition, lastWorkday }

enum RepeatEnd { never, afterCount, untilDate }

/// Правила месяца, окончание ряда и исключения.
///
/// Верхняя строка принимает обычный текст и раскладывает его в правило.
/// Разобранный вариант показывается до применения: вслепую не применяется,
/// иначе человек получит не тот ряд и заметит через месяц.
class RepeatAdvancedScreen extends StatefulWidget {
  const RepeatAdvancedScreen({super.key});

  @override
  State<RepeatAdvancedScreen> createState() => _RepeatAdvancedScreenState();
}

class _RepeatAdvancedScreenState extends State<RepeatAdvancedScreen> {
  MonthRule _rule = MonthRule.byPosition;
  RepeatEnd _end = RepeatEnd.afterCount;
  bool _skipHolidays = true;
  bool _moveWithFirst = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'Повторение',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 27,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: ShapeDecoration(
            color: scheme.surfaceContainerHigh,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          child: Row(
            children: [
              Icon(VehaIcons.byName('wand'), size: 20, color: scheme.primary),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '«каждую последнюю пятницу месяца»',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Разобрано в правило · нажмите, чтобы применить',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const VBlockCap('Правило месяца'),
        VBlock(children: [
          VOption(
            title: 'По числу',
            subtitle: '27-го каждого месяца',
            selected: _rule == MonthRule.byDate,
            onTap: () => setState(() => _rule = MonthRule.byDate),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'По позиции',
            subtitle: 'Последняя пятница месяца',
            selected: _rule == MonthRule.byPosition,
            onTap: () => setState(() => _rule = MonthRule.byPosition),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'Последний рабочий день',
            subtitle: 'С учётом праздников страны',
            selected: _rule == MonthRule.lastWorkday,
            onTap: () => setState(() => _rule = MonthRule.lastWorkday),
          ),
        ]),
        const VBlockCap('Окончание'),
        VBlock(children: [
          VOption(
            title: 'Никогда',
            selected: _end == RepeatEnd.never,
            onTap: () => setState(() => _end = RepeatEnd.never),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'После 12 повторов',
            subtitle: 'Осталось 9',
            selected: _end == RepeatEnd.afterCount,
            onTap: () => setState(() => _end = RepeatEnd.afterCount),
          ),
          const VSep(inset: 15),
          VOption(
            title: 'До даты',
            subtitle: 'Не выбрана',
            selected: _end == RepeatEnd.untilDate,
            onTap: () => setState(() => _end = RepeatEnd.untilDate),
          ),
        ]),
        const VBlockCap('Исключения'),
        VBlock(children: [
          VRow(
            icon: 'calendar',
            value: 'Пропущенные даты',
            label: '4 и 11 августа',
            labelFirst: false,
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 18, color: scheme.outline),
          ),
          const VSep(),
          _ToggleRow(
            icon: 'flag',
            title: 'Не повторять в праздники',
            subtitle: 'Календарь праздников Молдовы',
            value: _skipHolidays,
            onChanged: (v) => setState(() => _skipHolidays = v),
          ),
          const VSep(),
          _ToggleRow(
            icon: 'clock',
            title: 'Сдвигать вместе с первым',
            subtitle: 'Перенос первой даты двигает весь ряд',
            value: _moveWithFirst,
            onChanged: (v) => setState(() => _moveWithFirst = v),
          ),
        ]),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName(icon),
                size: 17, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          VSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
