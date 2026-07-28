import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/settings.dart';
import '../../domain/week_layout.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../calendar/widgets/week_setup_sheet.dart';
import '../common/blocks.dart';
import '../fields/fields_screen.dart';
import '../calendar/widgets/view_switcher.dart';
import 'appearance_card.dart';
import 'ics_rows.dart';
import 'sync_rows.dart';

/// Настройки: оформление, неделя, данные, о приложении.
///
/// Тема и цвет применяются сразу, без «Сохранить»: человек видит результат
/// в тот же момент, когда выбирает.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final look = ref.watch(appearanceProvider);
    final week = ref.watch(weekLayoutProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 10, VehaInsets.screen, 120),
      children: [
        Text(
          L.of(context).settingsTitle,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: scheme.onSurface,
          ),
        ),
        VBlockCap(L.of(context).settingsAppearance),
        const AppearanceCard(),
        VBlockCap(L.of(context).settingsCalendarGroup),
        VBlock(children: [
          VRow(
            icon: 'viewWeek',
            label: L.of(context).settingsWeekDays,
            value: _weekLabel(L.of(context), week),
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 17, color: scheme.outline),
            onTap: () async {
              final chosen = await askWeekLayout(context, week);
              if (chosen == null) return;
              await ref.read(weekLayoutProvider.notifier).set(chosen);
            },
          ),
          const VSep(),
          _ChoiceRow(
            icon: 'today',
            label: L.of(context).settingsStartScreen,
            hint: L.of(context).settingsStartScreenHint,
            options: {
              0: L.of(context).navCalendar,
              1: L.of(context).navList,
              2: L.of(context).navAccess,
              3: L.of(context).navSettings,
            },
            value: ref.watch(startTabProvider),
            onChanged: (v) => ref.read(startTabProvider.notifier).set(v),
          ),
          if (ref.watch(startTabProvider) == 0) ...[
            const VSep(),
            _ChoiceRow(
              icon: 'viewDay',
              label: L.of(context).settingsStartView,
              options: {
                for (final v in CalendarView.values) v: v.label(L.of(context)),
              },
              value: ref.watch(startViewProvider),
              onChanged: (v) => ref.read(startViewProvider.notifier).set(v),
            ),
          ],
          const VSep(),
          VRow(
            icon: 'text',
            label: L.of(context).fieldsTitle,
            value: L.of(context).settingsFieldsHint,
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 17, color: scheme.outline),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FieldGroupsScreen()),
            ),
          ),
          const VSep(),
          _ChoiceRow(
            icon: 'language',
            label: L.of(context).settingsLanguage,
            options: {
              '': L.of(context).settingsSystem,
              'ru': 'Русский',
              'en': 'English',
              'uk': 'Українська',
              'ro': 'Română',
              'pl': 'Polski',
              'de': 'Deutsch',
              'es': 'Español',
            },
            value: look.locale?.languageCode ?? '',
            onChanged: (v) => ref
                .read(appearanceProvider.notifier)
                .setLocale(v.isEmpty ? null : Locale(v)),
          ),
        ]),
        VBlockCap(L.of(context).settingsDataGroup),
        const VBlock(children: [
          SyncRows(),
          VSep(),
          IcsRows(),
        ]),
        VBlockCap(L.of(context).settingsAbout),
        VBlock(children: [
          const _VersionRow(),
          const VSep(),
          VRow(
            icon: 'shield',
            label: L.of(context).settingsDataGroup,
            value: L.of(context).settingsStorage,
          ),
          const VSep(),
          VRow(
            icon: 'link',
            label: L.of(context).settingsSource,
            value: 'THET1ME-1/Veha · GPL-3.0',
          ),
        ]),
      ],
    );
  }

  static String _weekLabel(L l, WeekLayout layout) {
    if (layout.isFullWeek) return l.settingsWeekFull;
    if (layout.weekdays.length == 5 && layout.weekdays.every((d) => d <= 5)) {
      return l.settingsWeekdaysOnly;
    }
    return l.settingsWeekSome(layout.weekdays.length);
  }
}

/// Строка с выбором из нескольких значений: варианты открываются листом снизу.
class _ChoiceRow<T> extends StatelessWidget {
  const _ChoiceRow({
    required this.icon,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.hint,
  });

  final String icon;
  final String label;
  final String? hint;
  final Map<T, String> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return VRow(
      icon: icon,
      label: label,
      value: options[value] ?? '',
      trailing: Icon(VehaIcons.byName('chevron'),
          size: 17, color: scheme.outline),
      onTap: () async {
        final chosen = await showModalBottomSheet<T>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      VehaInsets.screen, 2, VehaInsets.screen, 4),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFonts.display,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                if (hint != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        VehaInsets.screen, 0, VehaInsets.screen, 8),
                    child: Text(
                      hint!,
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 6, 15, 14),
                  child: VBlock(children: [
                    for (final entry in options.entries) ...[
                      if (entry.key != options.keys.first) const VSep(inset: 15),
                      VOption(
                        title: entry.value,
                        selected: entry.key == value,
                        onTap: () => Navigator.pop(context, entry.key),
                      ),
                    ],
                  ]),
                ),
              ],
            ),
          ),
        );
        if (chosen != null) onChanged(chosen);
      },
    );
  }
}

/// Версия читается из сборки, а не пишется руками: расхождение заметят первым.
class _VersionRow extends StatelessWidget {
  const _VersionRow();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        return VRow(
          icon: 'info',
          label: L.of(context).settingsVersion,
          value: info == null
              ? '—'
              : '${info.version} · сборка ${info.buildNumber}',
        );
      },
    );
  }
}
