// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navList => 'Liste';

  @override
  String get navAccess => 'Zugriff';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get viewDay => 'Tag';

  @override
  String get viewDays => 'Tage';

  @override
  String get viewWeek => 'Woche';

  @override
  String get viewMonth => 'Monat';

  @override
  String get readingClock => 'Uhr';

  @override
  String get readingChain => 'Kette';

  @override
  String get viewNotBuilt => 'Diese Ansicht fehlt noch';

  @override
  String get newEvent => 'Neuer Termin';

  @override
  String get today => 'heute';

  @override
  String get nothingPlanned => 'Nichts geplant';

  @override
  String durationMinutes(int minutes) {
    return '$minutes Min.';
  }

  @override
  String durationHours(int hours) {
    return '$hours Std.';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String spanDayOf(int current, int total) {
    return 'Tag $current von $total';
  }

  @override
  String spanUntil(String date) {
    return 'bis $date';
  }

  @override
  String get actionDone => 'Fertig';

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionEdit => 'Ändern';

  @override
  String get actionUndo => 'Rückgängig';

  @override
  String get fieldName => 'Name';

  @override
  String get calendarsTitle => 'Kalender';

  @override
  String get calendarOne => 'Kalender';

  @override
  String get calendarNewShort => 'Neu';

  @override
  String get calendarNew => 'Neuer Kalender';

  @override
  String get calendarCreate => 'Kalender anlegen';

  @override
  String get calendarsEmptyTitle => 'Noch keine Kalender';

  @override
  String get calendarsEmptyBody =>
      'Ein Kalender gibt allen Terminen darin Farbe und Symbol. Üblich sind drei bis vier: Zuhause, Arbeit, Studium, Sport.';

  @override
  String get branchOne => 'Zweig';

  @override
  String get branchNone => 'Ohne Zweige';

  @override
  String get branchAdd => 'Zweig hinzufügen';

  @override
  String branchOf(String name) {
    return 'Zweig „$name“';
  }

  @override
  String branchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zweige',
      one: '$count Zweig',
    );
    return '$_temp0';
  }

  @override
  String get colorInherits => 'Geerbt';

  @override
  String get colorOwn => 'Eigene Farbe';

  @override
  String get fieldsTitle => 'Eigene Felder';

  @override
  String get fieldsShared => 'Für alle gemeinsam';

  @override
  String get fieldsSharedRow => 'Gemeinsame Felder';

  @override
  String get fieldsGroups => 'Gruppen';

  @override
  String get fieldsNoneYet => 'Noch keine';

  @override
  String get fieldsGroupEmpty => 'Ohne eigene Felder';

  @override
  String get fieldsGroupCreate => 'Feldgruppe anlegen';

  @override
  String get fieldsGroupNew => 'Neue Gruppe';

  @override
  String fieldAddTo(String name) {
    return 'Feld zu „$name“ hinzufügen';
  }

  @override
  String fieldNewIn(String name) {
    return 'Neues Feld in „$name“';
  }

  @override
  String get fieldOne => 'Feld';

  @override
  String get fieldShared => 'Gemeinsam';

  @override
  String get fieldNamePlaceholder => 'Feldname';

  @override
  String get fieldKind => 'Was hineinkommt';

  @override
  String fieldsOwnCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eigene Felder',
      one: '$count eigenes Feld',
    );
    return '$_temp0';
  }

  @override
  String fieldsInCard(int count) {
    return 'in der Karte $count';
  }

  @override
  String get fieldEraseValue => 'Löschen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get typeText => 'Text';

  @override
  String get typeNumber => 'Zahl';

  @override
  String get typeDate => 'Datum';

  @override
  String get typeTime => 'Uhrzeit';

  @override
  String get typeDuration => 'Dauer';

  @override
  String get typeSelect => 'Liste';

  @override
  String get typeCheckbox => 'Kästchen';

  @override
  String get typeUrl => 'Link';

  @override
  String get typePhone => 'Telefon';

  @override
  String get typePerson => 'Person';

  @override
  String get typeMoney => 'Geld';

  @override
  String get searchHint => 'Termin finden';

  @override
  String get searchEmpty =>
      'Suche nach Titel, Ort oder einem eigenen Feld — etwa nach der Raumnummer.';

  @override
  String get searchNothing => 'Nichts gefunden.';

  @override
  String get allDay => 'ganztägig';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsAppearance => 'Aussehen';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsSystem => 'Wie im System';

  @override
  String get settingsLight => 'Hell';

  @override
  String get settingsDark => 'Dunkel';

  @override
  String get settingsChroma => 'Sättigung';

  @override
  String get settingsChromaHint =>
      'Auf dem Marken-Mint dreht „Kräftig“ die Pillen ins Grelle';

  @override
  String get settingsExact => 'Genau';

  @override
  String get settingsVivid => 'Kräftig';

  @override
  String get settingsSeed => 'Markenfarbe';

  @override
  String get settingsCalendarGroup => 'Kalender';

  @override
  String get settingsWeekDays => 'Tage in der Wochenansicht';

  @override
  String get settingsWeekFull => 'Ganze Woche';

  @override
  String get settingsWeekdaysOnly => 'Nur Werktage';

  @override
  String settingsWeekSome(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage pro Woche',
      one: '$count Tag pro Woche',
    );
    return '$_temp0';
  }

  @override
  String get settingsFieldsHint => 'Raum, Trainer, Abo-Nummer';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsDataGroup => 'Daten';

  @override
  String get settingsAbout => 'Über die App';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsStorage => 'Alles bleibt auf dem Gerät';

  @override
  String get settingsSource => 'Quellcode';

  @override
  String get monthViewTitle => 'Monatsansicht';

  @override
  String get monthChips => 'Chips mit Titeln';

  @override
  String get monthChipsHint => 'Man sieht, was genau an dem Tag ist';

  @override
  String get monthTint => 'Getönte Zellen';

  @override
  String get monthTintHint => 'Man sieht, womit der Tag belegt ist';

  @override
  String get monthDensity => 'Chip-Dichte';

  @override
  String get monthDensityBoth => 'Symbol und Text';

  @override
  String get monthDensityIcon => 'Nur Symbol';

  @override
  String get monthPerCell => 'Termine pro Zelle';

  @override
  String get monthPerCellHint => 'Der Rest wird zu „+N“';

  @override
  String get eventOne => 'Termin';

  @override
  String get eventWhen => 'Wann';

  @override
  String get eventTime => 'Uhrzeit';

  @override
  String get eventRepeat => 'Wiederholung';

  @override
  String get eventCalendarAndBranch => 'Kalender und Zweig';

  @override
  String get eventReminder => 'Erinnerung';

  @override
  String get eventPlace => 'Ort';

  @override
  String get eventPlaceHint => 'Wo es stattfindet';

  @override
  String get eventDelete => 'Termin löschen';

  @override
  String get moreDetails => 'Mehr';

  @override
  String get lookTitle => 'Symbol und Farbe';

  @override
  String get lookInherit => 'Wie beim Kalender';

  @override
  String get lookOwnColor => 'Eigene Farbe';

  @override
  String get inCard => 'In der Karte';

  @override
  String get notesTitle => 'Notizen';

  @override
  String get noteOne => 'Notiz';

  @override
  String get noteAdd => 'Notiz hinzufügen';

  @override
  String get noteHint => 'Was nicht vergessen';

  @override
  String get repeatNone => 'Wiederholt sich nicht';

  @override
  String get repeatByRule => 'Nach Regel';

  @override
  String get repeatTitle => 'Wiederholung';

  @override
  String get repeatDaily => 'Täglich';

  @override
  String get repeatWeekly => 'Wöchentlich';

  @override
  String get repeatEvery => 'Alle';

  @override
  String get repeatEndsWhen => 'Wann es endet';

  @override
  String get repeatNextDates => 'Nächste Termine';

  @override
  String get repeatNever => 'Nie';

  @override
  String get repeatUntilDate => 'Bis zu einem Datum';

  @override
  String repeatAfterCount(int count) {
    return 'Nach $count Wiederholungen';
  }

  @override
  String get unitDay => 'Tag';

  @override
  String get unitWeek => 'Woche';

  @override
  String get unitMonth => 'Monat';

  @override
  String get unitYear => 'Jahr';

  @override
  String get scopeTitle => 'Was ändern';

  @override
  String scopeRepeats(String label) {
    return 'Wiederholt sich: $label';
  }

  @override
  String get scopeOnly => 'Nur dieser Termin';

  @override
  String get scopeFollowing => 'Dieser und die folgenden';

  @override
  String get scopeFollowingHint =>
      'Die Serie teilt sich: Vergangenes bleibt, wie es war';

  @override
  String get scopeWhole => 'Die ganze Serie';

  @override
  String get scopeWholeHint => 'Alle Termine, auch vergangene';

  @override
  String get msgEventDeleted => 'Termin gelöscht';

  @override
  String get msgSeriesDeleted => 'Serie gelöscht';

  @override
  String get msgOccurrenceSkipped => 'Termin abgesagt';

  @override
  String get reminderNone => 'Ohne Erinnerung';

  @override
  String get reminderAtStart => 'Zum Beginn';

  @override
  String get reminderNever => 'Nicht erinnern';

  @override
  String get reminderHint =>
      'Mehrere sind möglich: einen Tag zum Vorbereiten, zehn Minuten zum Losgehen';

  @override
  String reminderMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Minuten vorher',
      one: '$count Minute vorher',
    );
    return '$_temp0';
  }

  @override
  String reminderHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden vorher',
      one: 'Eine Stunde vorher',
    );
    return '$_temp0';
  }

  @override
  String reminderDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage vorher',
      one: 'Einen Tag vorher',
    );
    return '$_temp0';
  }

  @override
  String get reminderWeek => 'Eine Woche vorher';

  @override
  String get reminderStarts => 'Beginnt';

  @override
  String reminderStartsAt(String time) {
    return 'Beginn um $time';
  }

  @override
  String get icsExport => 'Als .ics exportieren';

  @override
  String get icsExportHint => 'Eine Datei für einen anderen Kalender';

  @override
  String get icsImport => 'Aus .ics importieren';

  @override
  String get icsImportHint => 'Termine aus einem anderen Kalender';

  @override
  String get icsSaveTitle => 'Wohin den Kalender speichern';

  @override
  String get icsPickTitle => 'Kalenderdatei wählen';

  @override
  String get icsNothingToExport => 'Nichts zu exportieren: keine Termine.';

  @override
  String icsExported(int count) {
    return 'Exportierte Termine: $count.';
  }

  @override
  String icsImported(int count) {
    return 'Importierte Termine: $count.';
  }

  @override
  String get icsUnreadable => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get icsNoEvents => 'In der Datei wurde kein Termin gefunden.';

  @override
  String get colorPickerOwn => 'Eigene Farbe';

  @override
  String get colorHue => 'Farbton';

  @override
  String get colorChroma => 'Sättigung';

  @override
  String get colorTone => 'Helligkeit';

  @override
  String get colorMine => 'Meine Farben';

  @override
  String get colorRecent => 'Zuletzt';

  @override
  String get colorSaveMine => 'Merken';

  @override
  String colorReadout(int hue, int chroma, int tone) {
    return 'Farbton $hue° · Sättigung $chroma · Helligkeit $tone';
  }

  @override
  String get colorPickerHint =>
      'Die Pipette nimmt die Farbe aus einem Bild: Screenshot oder Foto öffnen und die Stelle antippen. Gespeicherte Farben liegen in «Meine Farben» und stehen in jeder Auswahl bereit.';

  @override
  String get branchColorTitle => 'Zweigfarbe';

  @override
  String get branchColorOwnHint => 'An diesem Zweig gesetzt';

  @override
  String branchColorOfCalendar(String name) {
    return 'Farbe von „$name“';
  }

  @override
  String get branchColorPickerRow => 'Eigene Farbe aus dem Wähler';

  @override
  String get branchColorPickerHint => 'Farbton, Sättigung, Hex, Pipette';

  @override
  String branchColorChain(String name) {
    return 'Färbst du „$name“ um, ändern sich alle Zweige und Termine mit Vererbung. Zweige mit eigener Farbe bleiben unverändert.';
  }

  @override
  String get branchColorEventRow => 'Termin des Zweigs';

  @override
  String get levelCalendar => 'Kalender';

  @override
  String get levelOwn => 'Eigene';

  @override
  String ruleDaily(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'alle $count Tage',
      one: 'täglich',
    );
    return '$_temp0';
  }

  @override
  String ruleWeekly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'alle $count Wochen',
      one: 'wöchentlich',
    );
    return '$_temp0';
  }

  @override
  String ruleMonthly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'alle $count Monate',
      one: 'monatlich',
    );
    return '$_temp0';
  }

  @override
  String get ruleYearly => 'jährlich';

  @override
  String ruleWeekDays(String every, String days) {
    return '$every: $days';
  }

  @override
  String ruleMonthPosition(String every, String ordinal, String weekday) {
    return '$every: $ordinal $weekday';
  }

  @override
  String get ordinalLast =>
      'letzter,letzter,letzter,letzter,letzter,letzter,letzter';

  @override
  String get ordinal1 => 'erster,erster,erster,erster,erster,erster,erster';

  @override
  String get ordinal2 =>
      'zweiter,zweiter,zweiter,zweiter,zweiter,zweiter,zweiter';

  @override
  String get ordinal3 =>
      'dritter,dritter,dritter,dritter,dritter,dritter,dritter';

  @override
  String get ordinal4 =>
      'vierter,vierter,vierter,vierter,vierter,vierter,vierter';

  @override
  String get weekSetupTitle => 'Welche Tage zeigen';

  @override
  String get weekSetupHint => 'So viele Spalten wie angehakte Tage';

  @override
  String get weekSetupAll => 'Ganze Woche';

  @override
  String get weekSetupWorkdays => 'Werktage';

  @override
  String get weekSetupWeekend => 'Wochenende';

  @override
  String get weekSetupStartsWith => 'Die Woche beginnt am';

  @override
  String get accessTitle => 'Zugriff';

  @override
  String get accessCreateKey => 'Schlüssel erstellen';

  @override
  String get accessRevoke => 'Widerrufen';

  @override
  String get accessHint =>
      'Schlüssel funktionieren nur bei eingeschalteter Synchronisierung. Ein Kalender, der allein auf dem Telefon lebt, ist von außen nicht erreichbar.';

  @override
  String get repeatNever2 => 'Nicht wiederholen';

  @override
  String get repeatWeekdays => 'An Werktagen';

  @override
  String get repeatCountLabel => 'Wiederholungen';

  @override
  String get repeatTimes => 'mal';

  @override
  String get repeatAfterSome => 'Nach mehreren Wiederholungen';

  @override
  String get repeatNoDates => 'Diese Regel ergibt keine Termine';

  @override
  String get unitDays => 'tage';

  @override
  String get unitWeeks => 'wochen';

  @override
  String get unitMonths => 'monate';

  @override
  String get unitYears => 'jahre';

  @override
  String get repeatAdvEnd => 'Ende';

  @override
  String get repeatAdvNotSet => 'Nicht gewählt';

  @override
  String get repeatAdvMonthRule => 'Monatsregel';

  @override
  String get repeatAdvByDate => 'Nach Datum';

  @override
  String get repeatAdvByPosition => 'Nach Position';

  @override
  String get repeatAdvSkipped => 'Ausgelassene Termine';

  @override
  String get repeatAdvExceptions => 'Ausnahmen';

  @override
  String get repeatAdvShiftFirst => 'Mit dem ersten Termin verschieben';

  @override
  String get repeatAdvShiftHint =>
      'Das Verschieben des ersten Termins verschiebt die ganze Serie';

  @override
  String get repeatAdvHolidays => 'An Feiertagen aussetzen';

  @override
  String get repeatAdvHolidaysHint => 'Berücksichtigt die Feiertage des Landes';

  @override
  String get repeatAdvParsed => 'In eine Regel übersetzt · zum Anwenden tippen';

  @override
  String get weekSetupCancel => 'Abbrechen';

  @override
  String get searchInCalendar => 'Suche';

  @override
  String monthMore(int count) {
    return 'noch $count';
  }

  @override
  String eventCancelOn(String date) {
    return 'Am $date absagen';
  }

  @override
  String get eventDeleteSeries => 'Ganze Serie löschen';

  @override
  String get untitled => 'Ohne Titel';

  @override
  String msgCancelledNamed(String title) {
    return '„$title“ abgesagt';
  }

  @override
  String get iconPickerTitle => 'Symbol';

  @override
  String get iconSearchHint => 'Symbol suchen (englisch)';

  @override
  String get iconPickerCommon => 'Häufige';

  @override
  String iconFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gefunden',
      one: '$count gefunden',
    );
    return '$_temp0';
  }

  @override
  String get settingsAutoTime => 'Nach Tageszeit';

  @override
  String get settingsAmoled => 'AMOLED';

  @override
  String get settingsAmoledHint => 'Reines Schwarz im dunklen Design';

  @override
  String get settingsMaterialYou => 'Material You';

  @override
  String get settingsMaterialYouHint =>
      'Farbe aus dem System-Hintergrundbild (Android 12+)';

  @override
  String get settingsStartScreen => 'Startbildschirm';

  @override
  String get settingsStartScreenHint => 'Damit startet die App';

  @override
  String get settingsStartView => 'Ansicht beim Start';

  @override
  String get placeHere => 'Ich bin hier';

  @override
  String get placeSearchHint => 'Straße, Ort, Stadt';

  @override
  String get placeSearching => 'Suche…';

  @override
  String get placeNoFix =>
      'Ort nicht ermittelbar: keine Berechtigung oder kein Signal.';

  @override
  String get msgSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get msgNotSaved => 'Änderungen wurden nicht gespeichert';

  @override
  String get syncTitle => 'Synchronisierung';

  @override
  String get syncOff => 'Aus — der Kalender lebt nur hier';

  @override
  String get syncClean => 'Alles gesendet';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen warten',
      one: '$count Änderung wartet',
    );
    return '$_temp0';
  }

  @override
  String get syncConnectTitle => 'Server verbinden';

  @override
  String get syncServerAddress => 'Serveradresse';

  @override
  String get syncCode => 'Code vom ersten Gerät';

  @override
  String get syncCodeHint => 'Leer heißt: erstes Gerät';

  @override
  String get syncDeviceName => 'Telefon';

  @override
  String get syncConnected => 'Server verbunden';

  @override
  String get syncFailed => 'Fehlgeschlagen';

  @override
  String syncDone(int sent, int received) {
    return 'Gesendet $sent, empfangen $received';
  }

  @override
  String get syncPairTitle => 'Code für ein zweites Gerät';

  @override
  String get syncPairHint => 'Anzeigen und am anderen eingeben';

  @override
  String get syncDisconnect => 'Server trennen';

  @override
  String get syncDisconnectHint => 'Die Daten bleiben auf dem Gerät';

  @override
  String get accessNeedsSync =>
      'Schlüssel erscheinen, sobald die Synchronisierung an ist';

  @override
  String get accessNoKeys => 'Noch keine Schlüssel';

  @override
  String get accessLoading => 'Lädt…';

  @override
  String get accessKeyName => 'Name des Agenten';

  @override
  String get accessScopesHint =>
      'Welche Kalender der Schlüssel sieht und wo er schreiben darf';

  @override
  String get accessReadOnly => 'Nur lesen';

  @override
  String get accessWrite => 'Lesen und schreiben';

  @override
  String get accessKeyOnce => 'Der Schlüssel wird einmal gezeigt';

  @override
  String get accessKeyOnceHint =>
      'Kopiere ihn jetzt in den Agenten: auf dem Server liegt nur ein Hash, die Zeichenfolge ist nicht wiederherstellbar.';

  @override
  String accessLastUsed(String when) {
    return 'Zuletzt $when';
  }

  @override
  String get accessNeverUsed => 'Noch nicht benutzt';

  @override
  String get accessRevoked => 'Widerrufen';

  @override
  String get accessLog => 'Protokoll';

  @override
  String get accessLogEmpty => 'Der Schlüssel hat noch nichts angefasst';

  @override
  String get photosTitle => 'Fotos';

  @override
  String get photoAdd => 'Foto hinzufügen';

  @override
  String get photoCamera => 'Aufnehmen';

  @override
  String get photoGallery => 'Aus der Galerie';

  @override
  String get photoRemove => 'Foto entfernen';

  @override
  String get photoRemoveAsk => 'Dieses Foto entfernen?';

  @override
  String get photoNeedsSave =>
      'Fotos gibt es, sobald der Termin gespeichert ist';

  @override
  String get navTasks => 'Aufgaben';

  @override
  String get tasksEmpty => 'Noch keine Aufgaben';

  @override
  String get tasksEmptyHint => 'Der Knopf unten legt die erste an';

  @override
  String get taskNew => 'Neue Aufgabe';

  @override
  String get taskOne => 'Aufgabe';

  @override
  String get taskTitleHint => 'Was zu tun ist';

  @override
  String get taskDue => 'Frist';

  @override
  String get taskNoDue => 'Ohne Frist';

  @override
  String get taskAtTime => 'Zu einer Uhrzeit';

  @override
  String get taskNotes => 'Notiz';

  @override
  String get taskNotesHint => 'Einzelheiten';

  @override
  String get taskDelete => 'Aufgabe löschen';

  @override
  String get taskOverdue => 'Überfällig';

  @override
  String get tasksDoneSection => 'Erledigt';

  @override
  String tasksOpenCount(int count) {
    return '$count offen';
  }

  @override
  String get msgTaskDeleted => 'Aufgabe gelöscht';

  @override
  String get dueToday => 'Heute';

  @override
  String get dueTomorrow => 'Morgen';

  @override
  String get statsTitle => 'Statistik';

  @override
  String get statsWeek => 'Woche';

  @override
  String get statsMonth => 'Monat';

  @override
  String get statsYear => 'Jahr';

  @override
  String get statsBusyTime => 'Belegte Zeit';

  @override
  String get statsEventCount => 'Termine';

  @override
  String get statsTasksClosed => 'Aufgaben erledigt';

  @override
  String get statsPerDay => 'Im Schnitt pro Tag';

  @override
  String get statsByCalendar => 'Nach Kalendern';

  @override
  String get statsByWeekday => 'Nach Wochentagen';

  @override
  String get statsBusiestDay => 'Vollster Tag';

  @override
  String get statsEmpty => 'Für diesen Zeitraum gibt es nichts';

  @override
  String statsHoursShort(String hours) {
    return '$hours Std.';
  }

  @override
  String statsShare(int percent) {
    return '$percent %';
  }

  @override
  String get colorSaved => 'Farbe in «Meine Farben»';

  @override
  String get colorAlreadySaved => 'Diese Farbe ist schon gespeichert';

  @override
  String get colorRemovedFromMine => 'Aus «Meine Farben» entfernt';

  @override
  String get colorCopied => 'Code kopiert';

  @override
  String get colorCopy => 'Code kopieren';

  @override
  String get colorPickFromImage => 'Farbe aus einem Bild nehmen';

  @override
  String get colorTapImage => 'Tippe aufs Bild — die Farbe kommt von dort';

  @override
  String get colorHexHint => 'Eigener Code';

  @override
  String scopeOnlyHint(String day) {
    return '$day rückt um, der Rest bleibt';
  }

  @override
  String get scopeDeleteTitle => 'Was löschen';

  @override
  String scopeDeleteOnlyHint(String day) {
    return '$day verschwindet, die Reihe bleibt';
  }

  @override
  String get scopeDeleteFollowingHint =>
      'Die Reihe endet an diesem Datum, Vergangenes bleibt';

  @override
  String get scopeDeleteWholeHint =>
      'Alle Termine verschwinden, auch vergangene';

  @override
  String get msgSeriesTrimmed => 'Die Reihe endet jetzt an diesem Datum';

  @override
  String get eventDuplicate => 'Kopie anlegen';

  @override
  String eventCopySuffix(String title) {
    return '$title — Kopie';
  }

  @override
  String get moveTitle => 'Verschieben';

  @override
  String get moveTomorrow => 'Auf morgen';

  @override
  String get moveNextWeek => 'In einer Woche';

  @override
  String get movePickDate => 'Datum wählen';

  @override
  String msgEventMoved(String day) {
    return 'Verschoben auf $day';
  }

  @override
  String get actionShare => 'Teilen';

  @override
  String get msgEventCopiedText => 'Termin als Text kopiert';

  @override
  String get eventOpenMap => 'Auf der Karte öffnen';

  @override
  String get previewActions => 'Aktionen';

  @override
  String get seriesPause => 'Reihe pausieren';

  @override
  String seriesPauseWeeks(int weeks) {
    return '$weeks Wo. aus';
  }

  @override
  String msgSeriesPaused(int count) {
    return 'Übersprungene Termine: $count';
  }

  @override
  String get lookReset => 'Wie der Zweig';

  @override
  String get msgLookReset => 'Farbe und Symbol werden wieder geerbt';

  @override
  String get toTask => 'In Aufgabe umwandeln';

  @override
  String get msgBecameTask => 'Der Termin ist jetzt eine Aufgabe';

  @override
  String get shiftRest => 'Rest des Tages verschieben';

  @override
  String msgDayShifted(int count) {
    return 'Mitverschoben: $count';
  }

  @override
  String get repeatDay => 'Tag wiederholen';

  @override
  String msgDayCopied(String day, int count) {
    return 'Tag auf $day kopiert: $count Termine';
  }

  @override
  String get stretchToNext => 'Bis zum nächsten dehnen';

  @override
  String msgStretched(String time) {
    return 'Der Termin läuft bis $time';
  }

  @override
  String get nothingToShift => 'An dem Tag kommt nichts mehr';

  @override
  String msgEventShifted(String time) {
    return 'Termin um $time';
  }

  @override
  String msgEventResized(String time) {
    return 'Jetzt bis $time';
  }

  @override
  String msgOverlaps(String title) {
    return 'Überschneidet sich: $title';
  }

  @override
  String get quickPhraseHint => 'Anruf morgen um 15:00 eine Stunde';

  @override
  String get quickPhraseRead => 'Aus dem Satz gelesen';

  @override
  String get findSlot => 'Nächste freie Lücke';

  @override
  String msgSlotFound(String when) {
    return 'Frei: $when';
  }

  @override
  String get msgNoSlot => 'In den nächsten zwei Wochen keine Lücke';

  @override
  String get trashTitle => 'Papierkorb';

  @override
  String get trashHint => 'Gelöschtes bleibt 90 Tage liegen';

  @override
  String get trashEmpty => 'Der Papierkorb ist leer';

  @override
  String get trashRestore => 'Zurückholen';

  @override
  String get trashClear => 'Papierkorb leeren';

  @override
  String msgTrashCleared(int count) {
    return 'Entfernte Einträge: $count';
  }

  @override
  String msgRestored(String title) {
    return 'Zurückgeholt: $title';
  }

  @override
  String get calendarDefaults => 'Standardwerte';

  @override
  String get calendarDefaultReminder => 'Erinnerung bei neuen Terminen';

  @override
  String get calendarDefaultDuration => 'Dauer neuer Termine';
}
