import 'package:flutter/material.dart';
import '../../../core/icon_registry.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../common/blocks.dart';

/// Заголовок «Июль 2026»: месяц жирным, год лёгким акцентным.
/// Контраст начертаний — фирменная деталь экрана, она же работает в ленте дней.
class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.date,
    this.dayReading,
    this.onReadingChanged,
    this.onSearch,
    this.onReview,
    this.onAdd,
    this.period,
    this.summary,
    this.onPrev,
    this.onNext,
    this.onToday,
  });

  final DateTime date;

  /// Прочтение дня: часы или цепочка. `null` — переключателя нет
  /// (на экранах недели и месяца ему нечего переключать).
  final DayReading? dayReading;
  final ValueChanged<DayReading>? onReadingChanged;

  /// Поиск по всему календарю. Живёт в шапке, а не в нижней панели: искать
  /// хотят из любого вида, а разделов внизу и так четыре.
  final VoidCallback? onSearch;

  /// Разбор дня. Кнопка есть только там, где есть день: в месяце разбирать
  /// нечего — тридцать дней разом ни о чём не скажут.
  final VoidCallback? onReview;

  /// Завести событие. Стоит в шапке, а не плавающей кнопкой в углу:
  /// внизу теперь переключатель видов, и кнопка накрывала бы его.
  final VoidCallback? onAdd;

  /// Подпись видимого отрезка: «27 июля», «27 июл — 2 авг», «Июль 2026».
  /// `null` — вид сам решает, что писать, и берётся месяц с годом.
  final String? period;

  /// Что за отрезком: сколько событий и сколько занято. Две строки мелким.
  final String? summary;

  /// Листание стрелками. Свайп остаётся, стрелки нужны на широком экране и
  /// тем, кому свайп неудобен.
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  /// Возврат на сегодня. `null` — человек и так на сегодняшнем дне, и кнопке
  /// нечего делать: она бы занимала место и ни на что не отвечала.
  final VoidCallback? onToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = DateFormat.MMMM('ru').format(date);
    final title = month[0].toUpperCase() + month.substring(1);

    final titleWidget = period == null
        ? Text.rich(
            TextSpan(children: [
              TextSpan(text: '$title '),
              TextSpan(
                text: '${date.year}',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: -0.4,
                ),
              ),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.displaySmall?.copyWith(
              fontSize: 30,
              height: 1.05,
              letterSpacing: -1.1,
              fontWeight: FontWeight.w800,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                period!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  height: 1.1,
                ),
              ),
              if (summary != null)
                Text(
                  summary!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
            ],
          );

    // Шапка в две строки: сверху период со стрелками и кнопка «завести»,
    // снизу редкие действия. В одну строку они не влезали — от заголовка
    // оставалось «8 …».
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onPrev != null)
                _Arrow(
                  key: const ValueKey('prev-period'),
                  icon: 'back',
                  onTap: onPrev!,
                ),
              Expanded(child: titleWidget),
              if (onNext != null) ...[
                _Arrow(
                  key: const ValueKey('next-period'),
                  icon: 'chevron',
                  onTap: onNext!,
                ),
                const SizedBox(width: 6),
              ],
              // Кнопка возврата появляется, только когда человек ушёл с
              // сегодняшнего дня: уехать свайпом на полгода вперёд — дело трёх
              // движений, вернуться тем же способом — полгода движений.
              if (onToday != null) ...[
                VRoundButton(
                  key: const ValueKey('go-today'),
                  icon: 'calendar_today',
                  onTap: onToday!,
                  size: 38,
                ),
                const SizedBox(width: 6),
              ],
              if (onAdd != null)
                VRoundButton(
                  key: const ValueKey('add-event'),
                  icon: 'add',
                  onTap: onAdd!,
                  filled: true,
                ),
            ],
          ),
          if (onReview != null || onSearch != null || dayReading != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  if (dayReading != null)
                    _ReadingSwitch(
                      value: dayReading!,
                      onChanged: onReadingChanged ?? (_) {},
                    ),
                  const Spacer(),
                  if (onReview != null) ...[
                    VRoundButton(
                      key: const ValueKey('day-review'),
                      icon: 'insights',
                      onTap: onReview!,
                      size: 38,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onSearch != null)
                    VRoundButton(icon: 'search', onTap: onSearch!, size: 38),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


/// Стрелка листания: мелкий круг без заливки, чтобы не спорить с «плюсом».
class _Arrow extends StatelessWidget {
  const _Arrow({super.key, required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(VehaIcons.byName(icon), size: 20, color: scheme.onSurfaceVariant),
    );
  }
}

/// Часы или лента. Оба прочтения дня равноправны, поэтому в сегментированном
/// контроле они занимают одно место, а переключаются здесь.
///
/// Часы держат масштаб времени и позволяют таскать блоки, лента отвечает на
/// «что у меня сегодня» и показывает пустые окна словами.
enum DayReading { clock, tape }

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
              key: ValueKey('reading-${r.name}'),
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
                      : VehaIcons.byName('viewAgenda'),
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
  static const String display = 'Manrope';
  static const String body = 'Manrope';
}
