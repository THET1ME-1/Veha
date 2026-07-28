import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/settings.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sync_api.dart';
import '../calendar/widgets/month_header.dart';
import '../common/blocks.dart';
import '../settings/sync_rows.dart' show syncApiFactoryProvider;

/// Журнал ключа: что и когда агент делал.
///
/// То, что превращает опасную фичу в аргумент. В чужих календарях не видно,
/// что именно творило стороннее приложение, — здесь видно, включая отказы.
class KeyLogScreen extends ConsumerWidget {
  const KeyLogScreen({super.key, required this.keyId, required this.keyName});

  final String keyId;
  final String keyName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);
    final entries = ref.watch(keyLogProvider(keyId));

    return Scaffold(
      appBar:
          AppBar(toolbarHeight: 56, leading: vBack(context), leadingWidth: 60),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            VehaInsets.screen, 0, VehaInsets.screen, 120),
        children: [
          Text(
            keyName,
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 28,
              letterSpacing: -0.9,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          entries.when(
            loading: () => _Note(text: l.accessLoading),
            error: (e, _) => _Note(text: '${l.syncFailed}: $e'),
            data: (rows) => rows.isEmpty
                ? _Note(text: l.accessLogEmpty)
                : VBlock(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        if (i > 0) const VSep(inset: 15),
                        _Entry(entry: rows[i]),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Журнал с сервера. Семейство по ключу: экран открыт ровно для одного.
final keyLogProvider =
    FutureProvider.family<List<KeyAction>, String>((ref, keyId) async {
  final settings = ref.watch(syncSettingsProvider);
  if (!settings.connected) return const [];
  return ref
      .read(syncApiFactoryProvider)(settings.url)
      .tokenLog(settings.token, keyId);
});

class _Entry extends StatelessWidget {
  const _Entry({required this.entry});

  final KeyAction entry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final denied = entry.result != 'ok';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              color:
                  denied ? scheme.errorContainer : scheme.surfaceContainerHigh,
              shape: const CircleBorder(),
            ),
            child: Icon(
              VehaIcons.byName(_iconOf(entry.action)),
              size: 16,
              color: denied ? scheme.onErrorContainer : scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.tool,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                Text(
                  DateFormat('d MMMM, HH:mm', locale)
                      .format(DateTime.fromMillisecondsSinceEpoch(entry.at)),
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          VTag(entry.result, accent: !denied),
        ],
      ),
    );
  }

  /// Иконка по действию: читал, завёл, поправил, удалил.
  static String _iconOf(String action) => switch (action) {
        'create' => 'add',
        'update' => 'pencil',
        'delete' => 'trash',
        _ => 'eye',
      };
}

class _Note extends StatelessWidget {
  const _Note({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
