import 'package:flutter/material.dart';
import '../../../core/icon_registry.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../common/blocks.dart';

/// Заголовок «Июль 2026»: месяц жирным Unbounded, год лёгким Onest акцентным.
/// Контраст начертаний — фирменная деталь экрана, она же работает в ленте дней.
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.date,
    this.dayReading,
    this.onReadingChanged,
    this.onSearch,
  });

  final DateTime date;

  /// Прочтение дня: часы или цепочка. `null` — переключателя нет
  /// (на экранах недели и месяца ему нечего переключать).
  final DayReading? dayReading;
  final ValueChanged<DayReading>? onReadingChanged;

  /// Поиск по всему календарю. Живёт в шапке, а не в нижней панели: искать
  /// хотят из любого вида, а разделов внизу и так четыре.
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat.MMMM('ru').format(date);
    final title = month[0].toUpperCase() + month.substring(1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              // Заголовок не должен упираться в кнопку поиска.
              padding: const EdgeInsets.only(right: 10),
              child: Text.rich(
              TextSpan(children: [
                TextSpan(text: '$title '),
                TextSpan(
                  text: '${date.year}',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w300,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.4,
                  ),
                ),
              ]),
              style: theme.textTheme.displaySmall?.copyWith(
                fontSize: 36,
                height: 1,
                letterSpacing: -1.26,
                fontWeight: FontWeight.w800,
              ),
              ),
            ),
          ),
          if (onSearch != null) ...[
            VRoundButton(icon: 'search', onTap: onSearch!),
            const SizedBox(width: 8),
          ],
          if (dayReading != null)
            _ReadingSwitch(
              value: dayReading!,
              onChanged: onReadingChanged ?? (_) {},
            ),
        ],
      ),
    );
  }
}


/// Часы или цепочка. Оба прочтения дня равноправны, поэтому в сегментированном
/// контроле они занимают одно место, а переключаются здесь.
enum DayReading { clock, chain }

class _ReadingSwitch extends StatelessWidget {
  const _ReadingSwitch({required this.value, required this.onChanged});

  final DayReading value;
  final ValueChanged<DayReading> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in DayReading.values)
            GestureDetector(
              onTap: () => onChanged(r),
              child: Container(
                width: 36,
                height: 32,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: r == value ? scheme.secondaryContainer : Colors.transparent,
                  shape: const StadiumBorder(),
                ),
                child: Icon(
                  r == DayReading.clock
                      ? VehaIcons.byName('clock')
                      : VehaIcons.byName('timeline'),
                  size: 18,
                  color: r == value
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Имена шрифтов ДНК. Держим рядом, чтобы не тянуть весь AppTheme ради строки.
/// Имена семейств те же, что в дизайн-ДНК. Пакет ссылается на них без
/// префикса `packages/`, поэтому шрифты обязано объявлять само приложение —
/// иначе тема ДНК остаётся без начертаний и текст рисуется квадратами.
class AppFonts {
  AppFonts._();
  static const String display = 'Unbounded';
  static const String body = 'Onest';
}
