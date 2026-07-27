// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navList => 'List';

  @override
  String get navAccess => 'Access';

  @override
  String get navSettings => 'Settings';

  @override
  String get viewDay => 'Day';

  @override
  String get viewDays => 'Days';

  @override
  String get viewWeek => 'Week';

  @override
  String get viewMonth => 'Month';

  @override
  String get readingClock => 'Clock';

  @override
  String get readingChain => 'Chain';

  @override
  String get viewNotBuilt => 'This view is not built yet';

  @override
  String get newEvent => 'New event';

  @override
  String get today => 'today';

  @override
  String get nothingPlanned => 'Nothing planned';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String spanDayOf(int current, int total) {
    return 'day $current of $total';
  }

  @override
  String spanUntil(String date) {
    return 'until $date';
  }
}
