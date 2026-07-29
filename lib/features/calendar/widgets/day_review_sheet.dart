import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/brand.dart';
import '../../../core/icon_registry.dart';
import '../../../data/models.dart';
import '../../../domain/day_review.dart';
import '../../../domain/free_time.dart';
import '../../../domain/time_label.dart';
import '../../../l10n/app_localizations.dart';
import '../../common/blocks.dart';
import 'month_header.dart' show AppFonts;

/// Разбор дня: сколько занято, где окна, что наехало друг на друга.
///
/// Открывается из шапки и отвечает на вопрос, ради которого человек иначе
/// складывает часы глазами: влезет ли сюда ещё одно дело и куда именно.
/// Возвращает выбранное окно — по нему тут же заводят событие.
Future<TimeSlot?> showDayReview(
  BuildContext context, {
  required DayReview review,
  required Inheritance inheritance,
}) =>
    showModalBottomSheet<TimeSlot>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: _DayReviewSheet(review: review, inheritance: inheritance),
      ),
    );

class _DayReviewSheet extends StatelessWidget {
  const _DayReviewSheet({required this.review, required this.inheritance});

  final DayReview review;
  final Inheritance inheritance;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final scheme = Theme.of(context).colorScheme;
    final empty = review.busy == Duration.zero && review.clashes.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 0, VehaInsets.screen, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.dayReviewTitle,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          if (empty)
            _Quiet(text: l.dayReviewEmpty)
          else ...[
            _LoadBar(review: review),
            const SizedBox(height: 14),
            VBlock(children: [
              VRow(
                icon: 'hourglass',
                label: l.dayReviewBusy,
                value: humanDuration(l, review.busy),
              ),
              const VSep(),
              VRow(
                icon: 'coffee',
                label: l.dayReviewFree,
                value: humanDuration(l, review.free),
              ),
              if (review.longest != null) ...[
                const VSep(),
                VRow(
                  icon: inheritance.iconOfEvent(review.longest!),
                  label: l.dayReviewLongest,
                  value: '${review.longest!.title} · '
                      '${humanDuration(l, review.longest!.duration)}',
                ),
              ],
              if (review.clashes.isNotEmpty) ...[
                const VSep(),
                VRow(
                  icon: 'warning',
                  iconColor: scheme.onErrorContainer,
                  iconBackground: scheme.errorContainer,
                  label: l.dayReviewClashes(review.clashes.length),
                  value: review.clashes
                      .map((c) => '${c.first.title} · ${c.second.title}')
                      .join('\n'),
                ),
              ],
            ]),
            if (review.hasNoBreaks) ...[
              const SizedBox(height: 10),
              _Quiet(text: l.dayReviewNoBreaks, alarming: true),
            ],
            if (review.gaps.isNotEmpty) ...[
              const SizedBox(height: 16),
              VBlockCap(l.dayReviewGaps),
              VBlock(children: [
                for (var i = 0; i < review.gaps.length; i++) ...[
                  if (i > 0) const VSep(),
                  _GapRow(
                    index: i,
                    slot: review.gaps[i],
                    onTap: () => Navigator.pop(context, review.gaps[i]),
                  ),
                ],
              ]),
            ],
          ],
        ],
      ),
    );
  }
}

/// Полоса загрузки. Заливка двумя тонами без градиента и обводки — так же,
/// как всё остальное в приложении.
class _LoadBar extends StatelessWidget {
  const _LoadBar({required this.review});

  final DayReview review;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final share = review.load.clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(99)),
      child: SizedBox(
        height: 14,
        child: Row(
          // Без растяжения по вертикали заливка получает нулевую высоту:
          // Row по умолчанию центрирует детей по их собственному размеру,
          // а у ColoredBox его нет.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (share > 0)
              Expanded(
                flex: (share * 1000).round(),
                child: ColoredBox(color: scheme.primary),
              ),
            if (share < 1)
              Expanded(
                flex: ((1 - share) * 1000).round(),
                child: ColoredBox(color: scheme.surfaceContainerHighest),
              ),
          ],
        ),
      ),
    );
  }
}

/// Свободное окно: время и сколько это длится. Тап заводит сюда событие.
class _GapRow extends StatelessWidget {
  const _GapRow({
    required this.index,
    required this.slot,
    required this.onTap,
  });

  final int index;
  final TimeSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return VRow(
      key: ValueKey('gap-$index'),
      icon: 'add',
      label: humanDuration(l, slot.length),
      value: '${hhmm(slot.start)} – ${hhmm(slot.end)}',
      onTap: onTap,
      trailing: Icon(
        VehaIcons.byName('chevron'),
        size: 17,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// Спокойная строка-замечание: заливка вместо восклицательных знаков.
class _Quiet extends StatelessWidget {
  const _Quiet({required this.text, this.alarming = false});

  final String text;
  final bool alarming;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: ShapeDecoration(
        color: alarming ? scheme.errorContainer : scheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: alarming ? scheme.onErrorContainer : scheme.onSurface,
        ),
      ),
    );
  }
}

/// Дата дня для заголовка — в разборе месяца не бывает, только сутки.
String dayReviewDate(DateTime day, String locale) =>
    DateFormat('EEEE, d MMMM', locale).format(day);
