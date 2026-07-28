import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/event_colors.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sync_api.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';
import '../settings/sync_rows.dart' show syncApiFactoryProvider;
import 'key_log_screen.dart';

/// Ключи для ИИ-агентов.
///
/// Ключи живут на сервере, поэтому без синхронизации раздел честно пустой:
/// календарь, который живёт только на телефоне, снаружи недоступен —
/// стучаться некуда. Это написано прямо, а не выясняется опытным путём.
class AccessScreen extends ConsumerStatefulWidget {
  const AccessScreen({super.key});

  @override
  ConsumerState<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends ConsumerState<AccessScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final sync = ref.watch(syncSettingsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 10, VehaInsets.screen, 120),
      children: [
        Text(
          l.accessTitle,
          style: TextStyle(
            fontFamily: AppFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.9,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        _Hint(text: l.accessHint),
        const SizedBox(height: 14),
        if (!sync.connected)
          _Empty(text: l.accessNeedsSync)
        else
          ..._keys(l),
      ],
    );
  }

  List<Widget> _keys(L l) {
    final keys = ref.watch(agentKeysProvider);

    return [
      keys.when(
        loading: () => _Empty(text: l.accessLoading),
        error: (e, _) => _Empty(text: '${l.syncFailed}: $e'),
        data: (list) => Column(
          children: [
            for (final key in list) ...[
              _KeyCard(
                item: key,
                onRevoke: key.revoked ? null : () => _revoke(key),
                onLog: () => _openLog(key),
              ),
              const SizedBox(height: 8),
            ],
            if (list.isEmpty) _Empty(text: l.accessNoKeys),
          ],
        ),
      ),
      const SizedBox(height: 6),
      VBlock(
        color: Theme.of(context).colorScheme.surfaceContainer,
        children: [
          VRow(
            icon: 'add',
            value: l.accessCreateKey,
            onTap: _busy ? null : _create,
          ),
        ],
      ),
    ];
  }

  /// Создание ключа: имя и галочки по календарям. Право на запись — отдельной
  /// галочкой на каждый: «дай ИИ мой календарь» почти никогда не значит «дай
  /// стирать».
  Future<void> _create() async {
    final l = L.of(context);
    final inheritance = ref.read(inheritanceProvider).valueOrNull;
    if (inheritance == null) return;

    final calendars = inheritance.calendars.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final name = TextEditingController(text: 'Claude');
    final scopes = <String, bool>{};

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: _CreateSheet(
            name: name,
            calendars: calendars,
            scopes: scopes,
            onChanged: () => setSheet(() {}),
          ),
        ),
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final settings = ref.read(syncSettingsProvider);
      final api = ref.read(syncApiFactoryProvider)(settings.url);
      final created = await api.createToken(
        settings.token,
        name: name.text.trim().isEmpty ? 'Агент' : name.text.trim(),
        scopes: [
          for (final entry in scopes.entries)
            KeyScope(calendarId: entry.key, canWrite: entry.value),
        ],
      );
      ref.invalidate(agentKeysProvider);
      if (mounted) await _showOnce(created.token);
    } on Exception catch (e) {
      if (mounted) _say('${l.syncFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Строка ключа показывается один раз: на сервере остался только хеш, и
  /// восстановить её неоткуда.
  Future<void> _showOnce(String token) async {
    final l = L.of(context);
    final scheme = Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.accessKeyOnce),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              token,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l.accessKeyOnceHint,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.actionDone),
          ),
        ],
      ),
    );
  }

  Future<void> _revoke(AgentKey key) async {
    final l = L.of(context);
    setState(() => _busy = true);
    try {
      final settings = ref.read(syncSettingsProvider);
      final api = ref.read(syncApiFactoryProvider)(settings.url);
      await api.revokeToken(settings.token, key.id);
      ref.invalidate(agentKeysProvider);
    } on Exception catch (e) {
      if (mounted) _say('${l.syncFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLog(AgentKey key) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => KeyLogScreen(keyId: key.id, keyName: key.name),
      ),
    );
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Ключи с сервера. Перечитываются после создания и отзыва.
final agentKeysProvider = FutureProvider<List<AgentKey>>((ref) async {
  final settings = ref.watch(syncSettingsProvider);
  if (!settings.connected) return const [];
  return ref.read(syncApiFactoryProvider)(settings.url).tokens(settings.token);
});

class _KeyCard extends StatelessWidget {
  const _KeyCard({
    required this.item,
    required this.onRevoke,
    required this.onLog,
  });

  final AgentKey item;
  final VoidCallback? onRevoke;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final ink = EventColors.of(VehaBrand.seed, theme.brightness);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(26)),
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
                  color:
                      item.revoked ? scheme.surfaceContainerHigh : ink.background,
                  shape: const CircleBorder(),
                ),
                child: Icon(
                  VehaIcons.byName('key'),
                  size: 21,
                  color: item.revoked ? scheme.outline : ink.foreground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: AppFonts.display,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: item.revoked ? scheme.outline : scheme.onSurface,
                      ),
                    ),
                    Text(
                      '${item.prefix} · · · · · ·',
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.revoked
                      ? l.accessRevoked
                      : item.lastUsedAt == null
                          ? l.accessNeverUsed
                          : l.accessLastUsed(
                              DateFormat('d MMMM, HH:mm', locale).format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    item.lastUsedAt!),
                              ),
                            ),
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(onPressed: onLog, child: Text(l.accessLog)),
              if (onRevoke != null)
                TextButton(
                  onPressed: onRevoke,
                  style: TextButton.styleFrom(foregroundColor: scheme.error),
                  child: Text(l.accessRevoke),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateSheet extends StatelessWidget {
  const _CreateSheet({
    required this.name,
    required this.calendars,
    required this.scopes,
    required this.onChanged,
  });

  final TextEditingController name;
  final List<VCalendar> calendars;
  final Map<String, bool> scopes;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 10),
            child: Text(
              l.accessCreateKey,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: TextField(
              controller: name,
              decoration: InputDecoration(labelText: l.accessKeyName),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Text(
              l.accessScopesHint,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final calendar in calendars)
                  _ScopeRow(
                    calendar: calendar,
                    granted: scopes.containsKey(calendar.id),
                    canWrite: scopes[calendar.id] ?? false,
                    onGrant: (value) {
                      if (value) {
                        scopes[calendar.id] = false;
                      } else {
                        scopes.remove(calendar.id);
                      }
                      onChanged();
                    },
                    onWrite: (value) {
                      scopes[calendar.id] = value;
                      onChanged();
                    },
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 10, VehaInsets.screen, 14),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.actionCancel),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed:
                      scopes.isEmpty ? null : () => Navigator.pop(context, true),
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: Text(l.actionDone),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeRow extends StatelessWidget {
  const _ScopeRow({
    required this.calendar,
    required this.granted,
    required this.canWrite,
    required this.onGrant,
    required this.onWrite,
  });

  final VCalendar calendar;
  final bool granted;
  final bool canWrite;
  final ValueChanged<bool> onGrant;
  final ValueChanged<bool> onWrite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = L.of(context);
    final ink = EventColors.of(calendar.color, theme.brightness);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: VehaInsets.screen, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color: ink.background,
              shape: const CircleBorder(),
            ),
            child: Icon(VehaIcons.byName(calendar.iconName),
                size: 17, color: ink.foreground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              calendar.name,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          if (granted)
            TextButton(
              onPressed: () => onWrite(!canWrite),
              child: Text(canWrite ? l.accessWrite : l.accessReadOnly),
            ),
          VSwitch(value: granted, onChanged: onGrant),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: scheme.secondaryContainer,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(VehaIcons.byName('shield'),
              size: 20, color: scheme.onSecondaryContainer),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
