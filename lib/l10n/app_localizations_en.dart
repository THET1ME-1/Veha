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
  String get actionAdd => 'Add';

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
  String get colorInherits => 'Inherited';

  @override
  String get colorOwn => 'Own colour';

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
  String get fieldShared => 'Shared';

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
  String get yes => 'Yes';

  @override
  String get no => 'No';

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
  String get inCard => 'In the card';

  @override
  String get notesTitle => 'Notes';

  @override
  String get noteOne => 'Note';

  @override
  String get noteAdd => 'Add a note';

  @override
  String get noteHint => 'What not to forget';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatByRule => 'By rule';

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
      'The dropper takes a color from an image: open a screenshot or a photo and tap the spot you need. Saved colors live in «My colors» and are available in every picker.';

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
  String get levelCalendar => 'Calendar';

  @override
  String get levelOwn => 'Own';

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

  @override
  String get repeatNever2 => 'Do not repeat';

  @override
  String get repeatWeekdays => 'On weekdays';

  @override
  String get repeatCountLabel => 'Repeats';

  @override
  String get repeatTimes => 'times';

  @override
  String get repeatAfterSome => 'After a number of repeats';

  @override
  String get repeatNoDates => 'This rule produces no occurrences';

  @override
  String get unitDays => 'days';

  @override
  String get unitWeeks => 'weeks';

  @override
  String get unitMonths => 'months';

  @override
  String get unitYears => 'years';

  @override
  String get repeatAdvEnd => 'Ending';

  @override
  String get repeatAdvNotSet => 'Not chosen';

  @override
  String get repeatAdvMonthRule => 'Monthly rule';

  @override
  String get repeatAdvByDate => 'By date';

  @override
  String get repeatAdvByPosition => 'By position';

  @override
  String get repeatAdvSkipped => 'Skipped dates';

  @override
  String get repeatAdvExceptions => 'Exceptions';

  @override
  String get repeatAdvShiftFirst => 'Shift with the first date';

  @override
  String get repeatAdvShiftHint =>
      'Moving the first date moves the whole series';

  @override
  String get repeatAdvHolidays => 'Skip public holidays';

  @override
  String get repeatAdvHolidaysHint => 'Uses the country’s holiday calendar';

  @override
  String get repeatAdvParsed => 'Parsed into a rule · tap to apply';

  @override
  String get weekSetupCancel => 'Cancel';

  @override
  String get searchInCalendar => 'Search';

  @override
  String monthMore(int count) {
    return '$count more';
  }

  @override
  String eventCancelOn(String date) {
    return 'Cancel on $date';
  }

  @override
  String get eventDeleteSeries => 'Delete the whole series';

  @override
  String get untitled => 'Untitled';

  @override
  String msgCancelledNamed(String title) {
    return '“$title” cancelled';
  }

  @override
  String get iconPickerTitle => 'Icon';

  @override
  String get iconSearchHint => 'Find an icon';

  @override
  String get iconPickerCommon => 'Common';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count found',
      one: '$count found',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'By time of day';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Pure black background in the dark theme';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint =>
      'Colour from the system wallpaper (Android 12+)';

  @override
  String get settingsStartScreen => 'Start screen';

  @override
  String get settingsStartScreenHint => 'The app opens on it';

  @override
  String get settingsStartView => 'View on start';

  @override
  String get placeHere => 'I am here';

  @override
  String get placeSearchHint => 'Street, place, city';

  @override
  String get placeSearching => 'Searching…';

  @override
  String get placeNoFix =>
      'Could not get the location: no permission or no signal.';

  @override
  String get msgSaveFailed => 'Could not save';

  @override
  String get msgNotSaved => 'Changes were not saved';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncOff => 'Off — the calendar lives here only';

  @override
  String get syncClean => 'All sent';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes waiting',
      one: '$count change waiting',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Connect a server';

  @override
  String get syncServerAddress => 'Server address';

  @override
  String get syncCode => 'Code from the first device';

  @override
  String get syncCodeHint => 'Empty means this is the first device';

  @override
  String get syncDeviceName => 'Phone';

  @override
  String get syncConnected => 'Server connected';

  @override
  String get syncFailed => 'Failed';

  @override
  String syncDone(int sent, int received) {
    return 'Sent $sent, received $received';
  }

  @override
  String get syncPairTitle => 'Code for a second device';

  @override
  String get syncPairHint => 'Show it and type it on the other one';

  @override
  String get syncDisconnect => 'Disconnect the server';

  @override
  String get syncDisconnectHint => 'The data stays on the device';

  @override
  String get accessNeedsSync => 'Keys appear once you turn on sync';

  @override
  String get accessNoKeys => 'No keys yet';

  @override
  String get accessLoading => 'Loading…';

  @override
  String get accessKeyName => 'Agent name';

  @override
  String get accessScopesHint =>
      'Which calendars the key sees and where it may write';

  @override
  String get accessReadOnly => 'Read only';

  @override
  String get accessWrite => 'Read and write';

  @override
  String get accessKeyOnce => 'The key is shown once';

  @override
  String get accessKeyOnceHint =>
      'Copy it into your agent now: only a hash is stored on the server, and the string cannot be recovered.';

  @override
  String accessLastUsed(String when) {
    return 'Used $when';
  }

  @override
  String get accessNeverUsed => 'Not used yet';

  @override
  String get accessRevoked => 'Revoked';

  @override
  String get accessLog => 'Log';

  @override
  String get accessLogEmpty => 'The key has not touched anything yet';

  @override
  String get photosTitle => 'Photos';

  @override
  String get photoAdd => 'Add a photo';

  @override
  String get photoCamera => 'Take a photo';

  @override
  String get photoGallery => 'From gallery';

  @override
  String get photoRemove => 'Remove the photo';

  @override
  String get photoRemoveAsk => 'Remove this photo?';

  @override
  String get photoNeedsSave =>
      'Photos become available once the event is saved';

  @override
  String get navTasks => 'Tasks';

  @override
  String get tasksEmpty => 'No tasks yet';

  @override
  String get tasksEmptyHint => 'The button below adds the first one';

  @override
  String get taskNew => 'New task';

  @override
  String get taskOne => 'Task';

  @override
  String get taskTitleHint => 'What to do';

  @override
  String get taskDue => 'Due';

  @override
  String get taskNoDue => 'No due date';

  @override
  String get taskAtTime => 'At a time';

  @override
  String get taskNotes => 'Note';

  @override
  String get taskNotesHint => 'Details';

  @override
  String get taskDelete => 'Delete the task';

  @override
  String get taskOverdue => 'Overdue';

  @override
  String get tasksDoneSection => 'Done';

  @override
  String tasksOpenCount(int count) {
    return '$count open';
  }

  @override
  String get msgTaskDeleted => 'Task deleted';

  @override
  String get dueToday => 'Today';

  @override
  String get dueTomorrow => 'Tomorrow';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsWeek => 'Week';

  @override
  String get statsMonth => 'Month';

  @override
  String get statsYear => 'Year';

  @override
  String get statsBusyTime => 'Time booked';

  @override
  String get statsEventCount => 'Events';

  @override
  String get statsTasksClosed => 'Tasks closed';

  @override
  String get statsPerDay => 'Per day on average';

  @override
  String get statsByCalendar => 'By calendar';

  @override
  String get statsByWeekday => 'By weekday';

  @override
  String get statsBusiestDay => 'Busiest day';

  @override
  String get statsEmpty => 'Nothing recorded for this period';

  @override
  String statsHoursShort(String hours) {
    return '$hours h';
  }

  @override
  String statsShare(int percent) {
    return '$percent%';
  }

  @override
  String get colorSaved => 'Saved to My colors';

  @override
  String get colorAlreadySaved => 'That color is already saved';

  @override
  String get colorRemovedFromMine => 'Removed from My colors';

  @override
  String get colorCopied => 'Code copied';

  @override
  String get colorCopy => 'Copy the code';

  @override
  String get colorPickFromImage => 'Pick a color from an image';

  @override
  String get colorTapImage => 'Tap the image to take the color from it';

  @override
  String get colorHexHint => 'Your own code';

  @override
  String scopeOnlyHint(String day) {
    return '$day moves, the rest stay put';
  }

  @override
  String get scopeDeleteTitle => 'What to delete';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day disappears, the series stays';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'The series ends on this date; past occurrences stay';

  @override
  String get scopeDeleteWholeHint =>
      'Every occurrence goes, past ones included';

  @override
  String get msgSeriesTrimmed => 'The series now ends on this date';

  @override
  String get eventDuplicate => 'Make a copy';

  @override
  String eventCopySuffix(String title) {
    return '$title — copy';
  }

  @override
  String get moveTitle => 'Move';

  @override
  String get moveTomorrow => 'To tomorrow';

  @override
  String get moveNextWeek => 'In a week';

  @override
  String get movePickDate => 'Pick a date';

  @override
  String msgEventMoved(String day) {
    return 'Moved to $day';
  }

  @override
  String get actionShare => 'Share';

  @override
  String get msgEventCopiedText => 'Event copied as text';

  @override
  String get eventOpenMap => 'Open on the map';

  @override
  String get previewActions => 'Actions';

  @override
  String get seriesPause => 'Pause the series';

  @override
  String seriesPauseWeeks(int weeks) {
    return 'Skip $weeks wk';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Occurrences skipped: $count';
  }

  @override
  String get lookReset => 'Back to branch';

  @override
  String get msgLookReset => 'Color and icon are inherited again';

  @override
  String get toTask => 'Turn into a task';

  @override
  String get msgBecameTask => 'The event is a task now';

  @override
  String get shiftRest => 'Shift the rest of the day';

  @override
  String msgDayShifted(int count) {
    return 'Shifted along: $count';
  }

  @override
  String get repeatDay => 'Repeat this day';

  @override
  String msgDayCopied(String day, int count) {
    return 'Day copied to $day: $count events';
  }

  @override
  String get stretchToNext => 'Stretch to the next one';

  @override
  String msgStretched(String time) {
    return 'The event now runs until $time';
  }

  @override
  String get nothingToShift => 'Nothing else that day';

  @override
  String msgEventShifted(String time) {
    return 'Event at $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Now until $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Overlaps: $title';
  }

  @override
  String get quickPhraseHint => 'Call tomorrow at 3 pm for an hour';

  @override
  String get quickPhraseRead => 'Read from the line';

  @override
  String get findSlot => 'Next free slot';

  @override
  String msgSlotFound(String when) {
    return 'Free at $when';
  }

  @override
  String get msgNoSlot => 'No free slot in the next two weeks';

  @override
  String get trashTitle => 'Trash';

  @override
  String get trashHint => 'Deleted items are kept for 90 days';

  @override
  String get trashEmpty => 'The trash is empty';

  @override
  String get trashRestore => 'Restore';

  @override
  String get trashClear => 'Empty the trash';

  @override
  String msgTrashCleared(int count) {
    return 'Records removed: $count';
  }

  @override
  String msgRestored(String title) {
    return 'Restored: $title';
  }

  @override
  String get calendarDefaults => 'Defaults';

  @override
  String get calendarDefaultReminder => 'Reminder for new events';

  @override
  String get calendarDefaultDuration => 'Length of new events';

  @override
  String get actionSelect => 'Select multiple';

  @override
  String selectedCount(int count) {
    return 'Selected: $count';
  }

  @override
  String get bulkMove => 'Move';

  @override
  String get bulkCalendar => 'To calendar';

  @override
  String msgBulkMoved(int count) {
    return 'Events moved: $count';
  }

  @override
  String msgBulkDeleted(int count) {
    return 'Events deleted: $count';
  }

  @override
  String msgBulkCalendar(int count) {
    return 'Events moved to calendar: $count';
  }
}
