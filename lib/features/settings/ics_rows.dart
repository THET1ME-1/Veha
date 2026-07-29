import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/platform.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../domain/ics.dart';
import '../common/blocks.dart';
import '../event/calendar_picker_sheet.dart';

/// Обмен с чужими календарями. Две строки в настройках, вся работа — здесь:
/// экран настроек про оформление, а не про формат файлов.
class IcsRows extends ConsumerWidget {
  const IcsRows({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final chevron =
        Icon(VehaIcons.byName('chevron'), size: 17, color: scheme.outline);

    return Column(
      children: [
        VRow(
          icon: 'upload',
          label: L.of(context).icsExport,
          value: L.of(context).icsExportHint,
          trailing: chevron,
          onTap: () => _export(context, ref),
        ),
        const VSep(),
        VRow(
          icon: 'download',
          label: L.of(context).icsImport,
          value: L.of(context).icsImportHint,
          trailing: chevron,
          onTap: () => _import(context, ref),
        ),
      ],
    );
  }

  static Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l = L.of(context);
    final repo = ref.read(repositoryProvider);
    final events = await repo.allEvents();
    final defs = {for (final f in await repo.fieldsFor(null)) f.id: f};
    if (!context.mounted) return;

    if (events.isEmpty) {
      _say(context, l.icsNothingToExport);
      return;
    }

    // Имя с датой: файлы копятся в «Загрузках», и «veha.ics» рядом с
    // «veha (3).ics» ничего не говорит.
    final now = DateTime.now();
    final name = 'veha-${now.year}-${_two(now.month)}-${_two(now.day)}.ics';
    final bytes = utf8.encode(toIcs(events, defs: defs));

    final path = await FilePicker.platform.saveFile(
      dialogTitle: l.icsSaveTitle,
      fileName: name,
      bytes: bytes,
    );
    if (!context.mounted || path == null) return;

    // На Android байты пишет сам системный диалог, на десктопе возвращается
    // только путь — файл надо записать руками.
    if (!isAndroid) {
      await File(path).writeAsBytes(bytes);
      if (!context.mounted) return;
    }
    _say(context, l.icsExported(events.length));
  }

  static Future<void> _import(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(
      dialogTitle: L.of(context).icsPickTitle,
      type: FileType.any,
      withData: true,
    );
    if (!context.mounted || picked == null || picked.files.isEmpty) return;

    final file = picked.files.single;
    final bytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (!context.mounted) return;
    if (bytes == null) {
      _say(context, L.of(context).icsUnreadable);
      return;
    }

    // Кодировку файла угадывать не будем: `.ics` по стандарту в UTF-8, а
    // битые байты не должны ронять приложение.
    final data = parseIcs(
      utf8.decode(bytes, allowMalformed: true),
      untitled: L.of(context).untitled,
    );
    if (data.events.isEmpty) {
      _say(context, L.of(context).icsNoEvents);
      return;
    }

    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null || inheritance.calendars.isEmpty) return;

    // Куда складывать, решает человек: чужой файл про календари ничего не
    // знает, а угаданная стопка потом разгребается руками.
    final target = await askCalendar(
      context,
      inheritance: inheritance,
      calendarId: inheritance.calendars.keys.first,
      subcategoryId: null,
    );
    if (!context.mounted || target == null) return;

    final added = await ref.read(repositoryProvider).importEvents(
          data.events,
          calendarId: target.calendarId,
          fields: data.fields,
        );
    if (!context.mounted) return;
    _say(context, L.of(context).icsImported(added));
  }

  static void _say(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
