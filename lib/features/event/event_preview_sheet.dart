import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../domain/time_label.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/views/chain_view.dart' show recurrenceLabelOf;
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';
import 'reminders_sheet.dart' show remindersLabel;

/// Что человек выбрал в превью.
enum PreviewAction {
  edit,
  duplicate,
  moveTomorrow,
  moveNextWeek,
  movePickDate,
  changeCalendar,
  changeLook,
  reminders,
  copyText,
  exportIcs,
  openMap,
  delete,

  // Дальше — то, чего нет в других календарях и что вытекает из устройства
  // Veha: наследование цвета, цепочка дня, ряд, задачи рядом с событиями.

  /// Пауза ряда: занятий не будет столько-то недель, ряд живёт.
  pauseSeries,

  /// Вернуть цвет и иконку к ветке: событие снова наследует.
  resetLook,

  /// Событие оказалось делом, а не встречей.
  toTask,

  /// Сдвинуть остаток дня следом за этим событием.
  shiftRest,

  /// Повторить день целиком на другой дате.
  repeatDay,

  /// Занять промежуток до ближайшего события.
  stretchToNext,
}

/// Что человек выбрал и с каким числом. Пауза ряда отличается от остальных
/// действий тем, что несёт срок: одна неделя, две или четыре.
class PreviewChoice {
  const PreviewChoice(this.action, {this.weeks = 0});

  final PreviewAction action;
  final int weeks;
}

/// Превью события: тап по блоку показывает подробности и то, что с ним можно
/// сделать.
///
/// До превью тап открывал форму правки — человек лез в неё, только чтобы
/// посмотреть место или напоминание, и каждый раз рисковал что-то задеть.
Future<PreviewChoice?> showEventPreview(
  BuildContext context, {
  required VEvent event,
  required Inheritance inheritance,
}) {
  return showModalBottomSheet<PreviewChoice>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _PreviewSheet(event: event, inheritance: inheritance),
  );
}

/// Лист события.
///
/// Действий у события восемнадцать, и все восемнадцать разом превращают лист
/// в пульт управления, где глазами приходится искать «Изменить». Открытыми
/// остаются те, за которыми сюда приходят: правка, перенос, копия, удаление.
/// Остальное живёт под «Ещё» — оно нужно раз в месяц и не должно каждый день
/// занимать экран.
class _PreviewSheet extends StatefulWidget {
  const _PreviewSheet({required this.event, required this.inheritance});

  final VEvent event;
  final Inheritance inheritance;

  @override
  State<_PreviewSheet> createState() => _PreviewSheetState();
}

class _PreviewSheetState extends State<_PreviewSheet> {
  bool _more = false;

  VEvent get event => widget.event;
  Inheritance get inheritance => widget.inheritance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final color = inheritance.colorOfEvent(event);
    final ink = EventColors.of(color, theme.brightness);

    final calendar = inheritance.calendars[event.calendarId];
    final sub = event.subcategoryId == null
        ? null
        : inheritance.subcategories[event.subcategoryId];
    final repeat = recurrenceLabelOf(l, event, locale: locale);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
              VehaInsets.screen, 0, VehaInsets.screen, 18),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              decoration: ShapeDecoration(
                color: ink.background,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          color: ink.foreground.withValues(alpha: 0.15),
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          VehaIcons.byName(inheritance.iconOfEvent(event)),
                          size: 22,
                          color: ink.foreground,
                        ),
                      ),
                      const Spacer(),
                      // Правка вынесена в шапку: из превью в неё уходят чаще
                      // всего остального вместе взятого.
                      FilledButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, PreviewChoice(PreviewAction.edit)),
                        icon: Icon(VehaIcons.byName('pencil'), size: 17),
                        label: Text(l.actionEdit),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              ink.foreground.withValues(alpha: 0.16),
                          foregroundColor: ink.foreground,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 11),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 22,
                      height: 1.12,
                      letterSpacing: -0.7,
                      fontWeight: FontWeight.w800,
                      color: ink.foreground,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _when(context, locale),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: ink.foreground.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Описание идёт первым: ради него карточку и открывают чаще, чем
            // ради строки календаря.
            if (event.description != null && event.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: VBlock(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
                    child: Text(
                      event.description!,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                ]),
              ),
            VBlock(children: [
              if (repeat != null)
                VRow(icon: 'repeat', label: l.eventRepeat, value: repeat),
              if (repeat != null) const VSep(),
              if (event.location != null) ...[
                VRow(
                  icon: 'place',
                  label: l.eventPlace,
                  value: event.location,
                  onTap: () => Navigator.pop(context, PreviewChoice(PreviewAction.openMap)),
                  trailing: Icon(VehaIcons.byName('chevron'),
                      size: 17, color: scheme.outline),
                ),
                const VSep(),
              ],
              // Дорога здесь важнее самой длительности: до встречи надо
              // выйти, и время выхода — то, ради чего превью открывают.
              if (event.travelMinutes > 0) ...[
                VRow(
                  icon: 'directions_walk',
                  label: l.eventTravel,
                  value: '${humanDuration(l, Duration(minutes: event.travelMinutes))}'
                      ' · ${l.travelLeaveAt(hhmm(event.busyFrom))}',
                ),
                const VSep(),
              ],
              VRow(
                icon: 'bell',
                label: l.eventReminder,
                value: remindersLabel(l, event.reminders),
                onTap: () => Navigator.pop(context, PreviewChoice(PreviewAction.reminders)),
                trailing: Icon(VehaIcons.byName('chevron'),
                    size: 17, color: scheme.outline),
              ),
              const VSep(),
              VRow(
                icon: 'calendar',
                label: l.eventCalendarAndBranch,
                value: sub == null
                    ? calendar?.name ?? ''
                    : '${calendar?.name} · ${sub.name}',
                onTap: () =>
                    Navigator.pop(context, PreviewChoice(PreviewAction.changeCalendar)),
                trailing: Icon(VehaIcons.byName('chevron'),
                    size: 17, color: scheme.outline),
              ),
            ]),
            VBlockCap(l.moveTitle),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Chip(
                  icon: 'today',
                  label: l.moveTomorrow,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.moveTomorrow)),
                ),
                _Chip(
                  icon: 'viewWeek',
                  label: l.moveNextWeek,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.moveNextWeek)),
                ),
                _Chip(
                  icon: 'calendar',
                  label: l.movePickDate,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.movePickDate)),
                ),
              ],
            ),
            VBlockCap(l.previewActions),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                _Chip(
                  icon: 'content_copy',
                  label: l.eventDuplicate,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.duplicate)),
                ),
                _Chip(
                  icon: 'share',
                  label: l.actionShare,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.copyText)),
                ),
                _Chip(
                  icon: 'trash',
                  label: l.actionDelete,
                  danger: true,
                  onTap: () =>
                      Navigator.pop(context, PreviewChoice(PreviewAction.delete)),
                ),
                if (!_more)
                  _Chip(
                    icon: 'chevron',
                    label: l.previewMore,
                    onTap: () => setState(() => _more = true),
                  ),
              ],
            ),
            if (_more) ..._rare(context, l),
          ],
        ),
      ),
    );
  }

  /// Редкое: то, что делают раз в месяц. Пауза ряда живёт здесь же — она нужна
  /// на каникулах, а не каждый день.
  List<Widget> _rare(BuildContext context, L l) => [
        if (event.isOccurrence) ...[
          VBlockCap(l.seriesPause),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final weeks in const [1, 2, 4])
                _Chip(
                  icon: 'repeat',
                  label: l.seriesPauseWeeks(weeks),
                  onTap: () => Navigator.pop(
                    context,
                    PreviewChoice(PreviewAction.pauseSeries, weeks: weeks),
                  ),
                ),
            ],
          ),
        ],
        VBlockCap(l.previewMore),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            // День — цепочка: занятие сдвинулось, за ним едет остаток.
            _Chip(
              icon: 'viewDay',
              label: l.shiftRest,
              onTap: () =>
                  Navigator.pop(context, PreviewChoice(PreviewAction.shiftRest)),
            ),
            _Chip(
              icon: 'expand',
              label: l.stretchToNext,
              onTap: () => Navigator.pop(
                  context, PreviewChoice(PreviewAction.stretchToNext)),
            ),
            _Chip(
              icon: 'today',
              label: l.repeatDay,
              onTap: () =>
                  Navigator.pop(context, PreviewChoice(PreviewAction.repeatDay)),
            ),
            _Chip(
              icon: 'task_alt',
              label: l.toTask,
              onTap: () =>
                  Navigator.pop(context, PreviewChoice(PreviewAction.toTask)),
            ),
            _Chip(
              icon: 'palette',
              label: l.lookTitle,
              onTap: () =>
                  Navigator.pop(context, PreviewChoice(PreviewAction.changeLook)),
            ),
            // Сброс к ветке предлагается, только когда есть что сбрасывать.
            if (event.color != null || event.iconName != null)
              _Chip(
                icon: 'wand',
                label: l.lookReset,
                onTap: () =>
                    Navigator.pop(context, PreviewChoice(PreviewAction.resetLook)),
              ),
            _Chip(
              icon: 'download',
              label: l.icsExport,
              onTap: () =>
                  Navigator.pop(context, PreviewChoice(PreviewAction.exportIcs)),
            ),
          ],
        ),
      ];

  String _when(BuildContext context, String locale) {
    if (event.isMultiDay) {
      return '${DateFormat.MMMd(locale).format(event.start)} – '
          '${DateFormat.MMMd(locale).format(event.end)}';
    }
    final day = DateFormat('EEEE, d MMMM', locale).format(event.start);
    return '$day · ${eventTimeLabel(context, event)}';
  }

}

/// Кнопка-пилюля действия. Заливка, а не обводка: обводок в приложении нет.
class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        danger ? scheme.errorContainer : scheme.surfaceContainerHigh;
    final foreground =
        danger ? scheme.onErrorContainer : scheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: background,
          shape: const StadiumBorder(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(VehaIcons.byName(icon), size: 16, color: foreground),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
