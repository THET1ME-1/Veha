import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../data/seed.dart';
import 'views/chain_view.dart';
import 'views/clock_view.dart';
import 'widgets/month_header.dart';
import 'widgets/span_bar.dart';
import 'widgets/view_switcher.dart';
import 'widgets/week_strip.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// Демонстрационное «сейчас»: сид собран на 27 июля 2026, и линия должна
  /// стоять там же, где на макете.
  static final DateTime _now = DateTime(2026, 7, 27, 9, 41);

  CalendarView _view = CalendarView.day;
  DayReading _reading = DayReading.chain;
  DateTime _selected = Seed.today;

  List<DateTime> get _week {
    final monday = _selected.subtract(Duration(days: _selected.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final inheritance = Seed.inheritance;
    final events = Seed.dayEvents;

    return Column(
      children: [
        MonthHeader(
          date: _selected,
          dayReading: _view == CalendarView.day ? _reading : null,
          onReadingChanged: (r) => setState(() => _reading = r),
        ),
        if (_view == CalendarView.day || _view == CalendarView.bands)
          WeekStrip(
            week: _week,
            selected: _selected,
            busyDays: const {27, 28, 29, 30, 31},
            onSelect: (d) => setState(() => _selected = d),
          ),
        ViewSwitcher(value: _view, onChanged: (v) => setState(() => _view = v)),
        SpanBars(
          events: Seed.spans,
          today: _selected,
          inheritance: inheritance,
        ),
        Expanded(child: _body(events, inheritance)),
      ],
    );
  }

  Widget _body(List<VEvent> events, Inheritance inheritance) {
    return switch (_view) {
      CalendarView.day when _reading == DayReading.chain => ChainView(
          events: events,
          inheritance: inheritance,
          now: _now,
        ),
      CalendarView.day => ClockView(
          events: events,
          inheritance: inheritance,
          now: _now,
        ),
      _ => const _Placeholder(),
    };
  }
}

/// Заглушка для видов, которые ещё не собраны. Осознанно не рисует ничего
/// кроме подписи: пустой экран честнее наполовину сделанного.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.hourglass_top_rounded, size: 32, color: scheme.outline),
          const SizedBox(height: 10),
          Text(
            L.of(context).viewNotBuilt,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
