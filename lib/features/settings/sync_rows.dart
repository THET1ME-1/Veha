import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sync_api.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;
import '../common/blocks.dart';

/// Синхронизация в настройках: подключить сервер, увидеть очередь, слить
/// вручную.
///
/// Местный календарь — это норма, а не половина функции: без сервера всё
/// работает, и отключение ничего не стирает.
class SyncRows extends ConsumerStatefulWidget {
  const SyncRows({super.key});

  @override
  ConsumerState<SyncRows> createState() => _SyncRowsState();
}

class _SyncRowsState extends ConsumerState<SyncRows> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final sync = ref.watch(syncSettingsProvider);
    final pending = ref.watch(pendingChangesProvider).valueOrNull ?? 0;

    if (!sync.connected) {
      return VRow(
        icon: 'cloud',
        label: l.syncTitle,
        value: l.syncOff,
        trailing:
            Icon(VehaIcons.byName('chevron'), size: 17, color: scheme.outline),
        onTap: _busy ? null : _connect,
      );
    }

    return Column(
      children: [
        VRow(
          icon: 'cloud',
          label: l.syncTitle,
          value: sync.url,
          trailing: Text(
            pending == 0 ? l.syncClean : l.syncPending(pending),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: pending == 0 ? scheme.onSurfaceVariant : scheme.primary,
            ),
          ),
          onTap: _busy ? null : _syncNow,
        ),
        const VSep(),
        VRow(
          icon: 'key',
          label: l.syncPairTitle,
          value: l.syncPairHint,
          trailing:
              Icon(VehaIcons.byName('chevron'), size: 17, color: scheme.outline),
          onTap: _busy ? null : _showCode,
        ),
        const VSep(),
        VRow(
          icon: 'close',
          label: l.syncDisconnect,
          value: l.syncDisconnectHint,
          onTap: _busy
              ? null
              : () => ref.read(syncSettingsProvider.notifier).disconnect(),
        ),
      ],
    );
  }

  /// Подключение: адрес и, если это второе устройство, код с первого.
  Future<void> _connect() async {
    final l = L.of(context);
    final url = TextEditingController(text: 'http://');
    final code = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.syncConnectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: url,
              autofocus: true,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l.syncServerAddress),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: code,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: l.syncCode,
                helperText: l.syncCodeHint,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.actionDone),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    final address = url.text.trim().replaceAll(RegExp(r'/+$'), '');
    if (address.isEmpty) return;

    setState(() => _busy = true);
    try {
      final api = ref.read(syncApiFactoryProvider)(address);
      final credentials = code.text.trim().isEmpty
          ? await api.register(l.syncDeviceName)
          : await api.claim(code.text.trim(), l.syncDeviceName);

      await ref
          .read(syncSettingsProvider.notifier)
          .connect(url: address, token: credentials.token);
      if (mounted) _say(l.syncConnected);
      await _syncNow();
    } on Exception catch (e) {
      if (mounted) _say('${l.syncFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncNow() async {
    final l = L.of(context);
    final settings = ref.read(syncSettingsProvider);
    final service = ref.read(syncServiceProvider);
    if (service == null) return;

    setState(() => _busy = true);
    try {
      final outcome = await service.run(
        token: settings.token,
        since: settings.cursor,
      );
      await ref.read(syncSettingsProvider.notifier).setCursor(outcome.cursor);
      ref.invalidate(pendingChangesProvider);
      if (mounted) _say(l.syncDone(outcome.sent, outcome.received));
    } on Exception catch (e) {
      if (mounted) _say('${l.syncFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Код для второго устройства. Живёт десять минут — этого хватает, чтобы
  /// набрать его на планшете, и мало, чтобы он где-то залежался.
  Future<void> _showCode() async {
    final l = L.of(context);
    final settings = ref.read(syncSettingsProvider);
    setState(() => _busy = true);
    try {
      final api = ref.read(syncApiFactoryProvider)(settings.url);
      final code = await api.pairCode(settings.token);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.syncPairTitle),
          content: SelectableText(
            code,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.actionDone),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      if (mounted) _say('${l.syncFailed}: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Фабрика разговорщика с сервером: адрес известен только в момент подключения.
final syncApiFactoryProvider = Provider<SyncApi Function(String)>(
  (ref) => (url) => HttpSyncApi(baseUrl: url),
);
