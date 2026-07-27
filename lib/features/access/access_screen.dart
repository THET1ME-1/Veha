import 'package:flutter/material.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../calendar/widgets/month_header.dart';

/// Ключ доступа для ИИ-агента.
class AccessKey {
  const AccessKey({
    required this.name,
    required this.prefix,
    required this.scopes,
    required this.lastUsed,
    this.expires,
    this.revoked = false,
  });

  final String name;
  final String prefix;

  /// Календарь и право: `true` — запись.
  final List<(String, bool)> scopes;
  final String lastUsed;
  final String? expires;
  final bool revoked;
}

/// Раздел «Доступ»: ключи агентов и журнал их действий.
///
/// Появляется только при включённой синхронизации: до неё стучаться некуда,
/// и приложение говорит это прямо, а не молчит.
class AccessScreen extends StatelessWidget {
  const AccessScreen({super.key, required this.keys});

  final List<AccessKey> keys;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          VehaInsets.screen, 6, VehaInsets.screen, 120),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            'Доступ',
            style: TextStyle(
              fontFamily: AppFonts.display,
              fontSize: 30,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: ShapeDecoration(
            color: scheme.secondaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(VehaIcons.byName('exam'),
                  size: 19, color: scheme.onSecondaryContainer),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Ключи работают, пока включена синхронизация. Календарь, '
                  'который живёт только на телефоне, снаружи недоступен — '
                  'стучаться некуда.',
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (final k in keys) ...[
          _KeyCard(item: k),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: scheme.surfaceContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(26)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(VehaIcons.byName('add'), size: 19, color: scheme.primary),
              const SizedBox(width: 9),
              Text(
                'Создать ключ',
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KeyCard extends StatelessWidget {
  const _KeyCard({required this.item});

  final AccessKey item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: item.revoked ? 0.5 : 1,
      child: Container(
        padding: const EdgeInsets.all(15),
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
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: item.revoked
                        ? scheme.surfaceContainerHighest
                        : scheme.primaryContainer,
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    VehaIcons.byName('key'),
                    size: 21,
                    color: item.revoked
                        ? scheme.onSurfaceVariant
                        : scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontFamily: AppFonts.display,
                          fontSize: 15.5,
                          letterSpacing: -0.2,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.prefix,
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.scopes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final (name, canWrite) in item.scopes)
                    _ScopeChip(name: name, canWrite: canWrite),
                ],
              ),
            ],
            if (!item.revoked) ...[
              const SizedBox(height: 13),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      [
                        item.lastUsed,
                        if (item.expires != null) item.expires!,
                      ].join(' · '),
                      style: TextStyle(
                        fontFamily: AppFonts.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    'Отозвать',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: scheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({required this.name, required this.canWrite});

  final String name;
  final bool canWrite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: ShapeDecoration(
        color: canWrite ? scheme.primaryContainer : scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            VehaIcons.byName(canWrite ? 'note' : 'clock'),
            size: 13,
            color: canWrite
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: canWrite
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
