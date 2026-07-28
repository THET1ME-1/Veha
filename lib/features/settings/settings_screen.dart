import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/settings.dart';
import '../../domain/week_layout.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../calendar/widgets/week_setup_sheet.dart';
import '../color/color_picker_screen.dart';
import '../common/blocks.dart';
import '../fields/fields_screen.dart';

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
          'Настройки',
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: scheme.onSurface,
          ),
        ),
        const VBlockCap('Оформление'),
        VBlock(children: [
          _ChoiceRow(
            icon: 'palette',
            label: 'Тема',
            options: const {
              ThemeMode.system: 'Как в системе',
              ThemeMode.light: 'Светлая',
              ThemeMode.dark: 'Тёмная',
            },
            value: look.themeMode,
            onChanged: (v) =>
                ref.read(appearanceProvider.notifier).setThemeMode(v),
          ),
          const VSep(),
          _ChoiceRow(
            icon: 'wand',
            label: 'Насыщенность',
            hint: 'На фирменной мяте «Сочно» выкручивает пилюли до кислотного',
            options: const {false: 'Точь-в-точь', true: 'Сочно'},
            value: look.vibrant,
            onChanged: (v) =>
                ref.read(appearanceProvider.notifier).setVibrant(v),
          ),
          const VSep(),
          VRow(
            icon: 'dropper',
            label: 'Фирменный цвет',
            value: _hex(look.seed),
            trailing: Container(
              width: 26,
              height: 26,
              decoration: ShapeDecoration(
                color: look.seed,
                shape: const CircleBorder(),
              ),
            ),
            onTap: () => _pickSeed(context, ref, look.seed),
          ),
        ]),
        const VBlockCap('Календарь'),
        VBlock(children: [
          VRow(
            icon: 'viewWeek',
            label: 'Дни в виде «Неделя»',
            value: _weekLabel(week),
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 17, color: scheme.outline),
            onTap: () async {
              final chosen = await askWeekLayout(context, week);
              if (chosen == null) return;
              await ref.read(weekLayoutProvider.notifier).set(chosen);
            },
          ),
          const VSep(),
          VRow(
            icon: 'text',
            label: 'Свои поля',
            value: 'Кабинет, тренер, номер абонемента',
            trailing: Icon(VehaIcons.byName('chevron'),
                size: 17, color: scheme.outline),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FieldGroupsScreen()),
            ),
          ),
          const VSep(),
          _ChoiceRow(
            icon: 'language',
            label: 'Язык',
            options: const {
              '': 'Как в системе',
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
        const VBlockCap('О приложении'),
        VBlock(children: [
          const _VersionRow(),
          const VSep(),
          VRow(
            icon: 'shield',
            label: 'Данные',
            value: 'Всё хранится на устройстве',
          ),
          const VSep(),
          VRow(
            icon: 'link',
            label: 'Исходный код',
            value: 'THET1ME-1/Veha · GPL-3.0',
          ),
        ]),
      ],
    );
  }

  static Future<void> _pickSeed(
    BuildContext context,
    WidgetRef ref,
    Color current,
  ) async {
    final picked = await Navigator.of(context).push<Color>(
      MaterialPageRoute(
        builder: (_) => ColorPickerScreen(initial: current),
      ),
    );
    if (picked == null) return;
    await ref.read(appearanceProvider.notifier).setSeed(picked);
  }

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  static String _weekLabel(WeekLayout layout) {
    if (layout.isFullWeek) return 'Вся неделя';
    if (layout.weekdays.length == 5 &&
        layout.weekdays.every((d) => d <= 5)) {
      return 'Только будни';
    }
    return '${layout.weekdays.length} дня в неделе';
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
          label: 'Версия',
          value: info == null
              ? '—'
              : '${info.version} · сборка ${info.buildNumber}',
        );
      },
    );
  }
}
