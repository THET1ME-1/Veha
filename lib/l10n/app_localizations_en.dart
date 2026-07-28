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

  @override
  String get actionDone => 'Done';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSave => 'Save';

  @override
  String get actionAdd => 'add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionUndo => 'Undo';

  @override
  String get fieldName => 'Name';

  @override
  String get calendarsTitle => 'Calendars';

  @override
  String get calendarOne => 'Calendar';

  @override
  String get calendarNewShort => 'New';

  @override
  String get calendarNew => 'New calendar';

  @override
  String get calendarCreate => 'Create a calendar';

  @override
  String get calendarsEmptyTitle => 'No calendars yet';

  @override
  String get calendarsEmptyBody =>
      'A calendar sets the colour and icon for every event inside it. Three or four is usual: home, work, study, sport.';

  @override
  String get branchOne => 'Branch';

  @override
  String get branchNone => 'No branches';

  @override
  String get branchAdd => 'Add a branch';

  @override
  String branchOf(String name) {
    return 'Branch “$name”';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count branches',
      one: '$count branch',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'inherited';

  @override
  String get colorOwn => 'own colour';

  @override
  String get fieldsTitle => 'Custom fields';

  @override
  String get fieldsShared => 'Shared by all';

  @override
  String get fieldsSharedRow => 'Shared fields';

  @override
  String get fieldsGroups => 'Groups';

  @override
  String get fieldsNoneYet => 'None yet';

  @override
  String get fieldsGroupEmpty => 'No custom fields';

  @override
  String get fieldsGroupCreate => 'Create a field group';

  @override
  String get fieldsGroupNew => 'New group';

  @override
  String fieldAddTo(String name) {
    return 'Add a field to “$name”';
  }

  @override
  String fieldNewIn(String name) {
    return 'New field in “$name”';
  }

  @override
  String get fieldOne => 'Field';

  @override
  String get fieldShared => 'shared';

  @override
  String get fieldNamePlaceholder => 'Field name';

  @override
  String get fieldKind => 'What goes in it';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count custom fields',
      one: '$count custom field',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'in the card: $count';
  }

  @override
  String get fieldEraseValue => 'Erase';

  @override
  String get yes => 'yes';

  @override
  String get no => 'no';

  @override
  String get typeText => 'Text';

  @override
  String get typeNumber => 'Number';

  @override
  String get typeDate => 'Date';

  @override
  String get typeTime => 'Time';

  @override
  String get typeDuration => 'Duration';

  @override
  String get typeSelect => 'List';

  @override
  String get typeCheckbox => 'Checkbox';

  @override
  String get typeUrl => 'Link';

  @override
  String get typePhone => 'Phone';

  @override
  String get typePerson => 'Person';

  @override
  String get typeMoney => 'Money';

  @override
  String get searchHint => 'Find an event';

  @override
  String get searchEmpty =>
      'Search by title, place or a custom field — a room number, for instance.';

  @override
  String get searchNothing => 'Nothing found.';

  @override
  String get allDay => 'all day';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsSystem => 'Follow the system';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsChroma => 'Saturation';

  @override
  String get settingsChromaHint =>
      'On the brand mint, “Vivid” pushes the pills to an acid tone';

  @override
  String get settingsExact => 'Exact';

  @override
  String get settingsVivid => 'Vivid';

  @override
  String get settingsSeed => 'Brand colour';

  @override
  String get settingsCalendarGroup => 'Calendar';

  @override
  String get settingsWeekDays => 'Days in the Week view';

  @override
  String get settingsWeekFull => 'Whole week';

  @override
  String get settingsWeekdaysOnly => 'Weekdays only';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days a week',
      one: '$count day a week',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Room, coach, pass number';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDataGroup => 'Data';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsStorage => 'Everything stays on the device';

  @override
  String get settingsSource => 'Source code';

  @override
  String get monthViewTitle => 'Month view';

  @override
  String get monthChips => 'Chips with titles';

  @override
  String get monthChipsHint => 'You see exactly what is on that day';

  @override
  String get monthTint => 'Tinted cells';

  @override
  String get monthTintHint => 'You see how busy the day is';

  @override
  String get monthDensity => 'Chip density';

  @override
  String get monthDensityBoth => 'Icon and text';

  @override
  String get monthDensityIcon => 'Icon only';

  @override
  String get monthPerCell => 'Events per cell';

  @override
  String get monthPerCellHint => 'The rest collapse into “+N”';

  @override
  String get eventOne => 'Event';

  @override
  String get eventWhen => 'When';

  @override
  String get eventTime => 'Time';

  @override
  String get eventRepeat => 'Repeat';

  @override
  String get eventCalendarAndBranch => 'Calendar and branch';

  @override
  String get eventReminder => 'Reminder';

  @override
  String get eventPlace => 'Place';

  @override
  String get eventPlaceHint => 'Where it happens';

  @override
  String get eventDelete => 'Delete the event';

  @override
  String get moreDetails => 'More';

  @override
  String get lookTitle => 'Icon and colour';

  @override
  String get lookInherit => 'Same as the calendar';

  @override
  String get lookOwnColor => 'Own colour';

  @override
  String get inCard => 'in the card';

  @override
  String get notesTitle => 'Notes';

  @override
  String get noteOne => 'Note';

  @override
  String get noteAdd => 'Add a note';

  @override
  String get noteHint => 'What not to forget';

  @override
  String get repeatNone => 'does not repeat';

  @override
  String get repeatByRule => 'by rule';

  @override
  String get repeatTitle => 'Repetition';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekly => 'Every week';

  @override
  String get repeatEvery => 'Every';

  @override
  String get repeatEndsWhen => 'When it ends';

  @override
  String get repeatNextDates => 'Next dates';

  @override
  String get repeatNever => 'Never';

  @override
  String get repeatUntilDate => 'Until a date';

  @override
  String repeatAfterCount(int count) {
    return 'After $count repeats';
  }

  @override
  String get unitDay => 'Day';

  @override
  String get unitWeek => 'Week';

  @override
  String get unitMonth => 'Month';

  @override
  String get unitYear => 'Year';

  @override
  String get scopeTitle => 'What to change';

  @override
  String scopeRepeats(String label) {
    return 'This one repeats: $label';
  }

  @override
  String get scopeOnly => 'This one only';

  @override
  String get scopeFollowing => 'This and the following';

  @override
  String get scopeFollowingHint =>
      'The series splits: past ones stay as they were';

  @override
  String get scopeWhole => 'The whole series';

  @override
  String get scopeWholeHint => 'Every occurrence, past ones too';

  @override
  String get msgEventDeleted => 'Event deleted';

  @override
  String get msgSeriesDeleted => 'Series deleted';

  @override
  String get msgOccurrenceSkipped => 'Occurrence cancelled';

  @override
  String get reminderNone => 'No reminder';

  @override
  String get reminderAtStart => 'At the start';

  @override
  String get reminderNever => 'Do not remind';

  @override
  String get reminderHint =>
      'Several are fine: a day to get ready, ten minutes to head out';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes before',
      one: '$count minute before',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours before',
      one: 'An hour before',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days before',
      one: 'A day before',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'A week before';

  @override
  String get reminderStarts => 'Starting now';

  @override
  String reminderStartsAt(String time) {
    return 'Starts at $time';
  }

  @override
  String get icsExport => 'Export to .ics';

  @override
  String get icsExportHint => 'A file for another calendar';

  @override
  String get icsImport => 'Import from .ics';

  @override
  String get icsImportHint => 'Events from another calendar';

  @override
  String get icsSaveTitle => 'Where to save the calendar';

  @override
  String get icsPickTitle => 'Choose a calendar file';

  @override
  String get icsNothingToExport => 'Nothing to export: there are no events.';

  @override
  String icsExported(int count) {
    return 'Events exported: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Events imported: $count.';
  }

  @override
  String get icsUnreadable => 'The file could not be read.';

  @override
  String get icsNoEvents => 'No events were found in the file.';

  @override
  String get colorPickerOwn => 'Own colour';

  @override
  String get colorHue => 'Hue';

  @override
  String get colorChroma => 'Chroma';

  @override
  String get colorTone => 'Lightness';

  @override
  String get colorMine => 'My colours';

  @override
  String get colorRecent => 'Recent';

  @override
  String get colorSaveMine => 'Save';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Hue $hue° · chroma $chroma · lightness $tone';
  }

  @override
  String get colorPickerHint =>
      'The dropper picks a colour from your wallpaper or a screenshot. Saved ones live in “My colours” and are available in every picker.';

  @override
  String get branchColorTitle => 'Branch colour';

  @override
  String get branchColorOwnHint => 'Set on this branch';

  @override
  String branchColorOfCalendar(String name) {
    return 'Colour of “$name”';
  }

  @override
  String get branchColorPickerRow => 'Own colour from the picker';

  @override
  String get branchColorPickerHint => 'Hue, chroma, hex, dropper';

  @override
  String branchColorChain(String name) {
    return 'Recolour “$name” and every branch and event set to inherit changes with it. Branches with their own colour stay as they are.';
  }

  @override
  String get branchColorEventRow => 'Event of the branch';

  @override
  String get levelCalendar => 'calendar';

  @override
  String get levelOwn => 'own';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count days',
      one: 'every day',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count weeks',
      one: 'every week',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'every $count months',
      one: 'every month',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'every year';

  @override
  String ruleWeekDays(String every, String days) {
    return '$every: $days';
  }

  @override
  String ruleMonthPosition(String every, String ordinal, String weekday) {
    return '$every: the $ordinal $weekday';
  }

  @override
  String get ordinalLast => 'last,last,last,last,last,last,last';

  @override
  String get ordinal1 => 'first,first,first,first,first,first,first';

  @override
  String get ordinal2 => 'second,second,second,second,second,second,second';

  @override
  String get ordinal3 => 'third,third,third,third,third,third,third';

  @override
  String get ordinal4 => 'fourth,fourth,fourth,fourth,fourth,fourth,fourth';

  @override
  String get weekSetupTitle => 'Which days to show';

  @override
  String get weekSetupHint => 'There will be as many columns as days ticked';

  @override
  String get weekSetupAll => 'Whole week';

  @override
  String get weekSetupWorkdays => 'Weekdays';

  @override
  String get weekSetupWeekend => 'Weekend';

  @override
  String get weekSetupStartsWith => 'The week starts on';

  @override
  String get accessTitle => 'Access';

  @override
  String get accessCreateKey => 'Create a key';

  @override
  String get accessRevoke => 'Revoke';

  @override
  String get accessHint =>
      'Keys work only while sync is on. A calendar that lives on the phone alone is unreachable from outside — there is nowhere to knock.';
}
