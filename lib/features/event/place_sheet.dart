import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Место события: где я сейчас или что нашлось по названию.
///
/// Набирать адрес руками — худший способ: человек стоит у входа в клинику и
/// не помнит номера дома. Поэтому первая строка — «я здесь», а дальше поиск,
/// который отдаёт готовые подписи.
Future<String?> askPlace(
  BuildContext context, {
  String? current,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: _PlaceSheet(current: current),
    ),
  );
}

class _PlaceSheet extends ConsumerStatefulWidget {
  const _PlaceSheet({required this.current});

  final String? current;

  @override
  ConsumerState<_PlaceSheet> createState() => _PlaceSheetState();
}

class _PlaceSheetState extends ConsumerState<_PlaceSheet> {
  late final TextEditingController _query =
      TextEditingController(text: widget.current ?? '');
  Timer? _debounce;
  List<String> _found = const [];
  bool _busy = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  /// Ищем не на каждую букву: геокодер — сетевой вызов, и «Ште» полетело бы
  /// три раза подряд.
  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String value) async {
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _busy = true);
    final found = await ref.read(placeSourceProvider).search(value, language);
    if (!mounted) return;
    setState(() {
      _found = found;
      _busy = false;
    });
  }

  Future<void> _here() async {
    final language = Localizations.localeOf(context).languageCode;
    setState(() => _busy = true);

    final source = ref.read(placeSourceProvider);
    final fix = await source.current();
    final name =
        fix == null ? null : await source.nameOf(fix.lat, fix.lon, language);
    if (!mounted) return;

    setState(() => _busy = false);
    if (name == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(L.of(context).placeNoFix)));
      return;
    }
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = L.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 2, VehaInsets.screen, 12),
              child: Text(
                l.eventPlace,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: ShapeDecoration(
                  color: scheme.surfaceContainerHigh,
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  children: [
                    Icon(VehaIcons.byName('search'),
                        size: 19, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _query,
                        autofocus: true,
                        onChanged: _onChanged,
                        onSubmitted: (v) => Navigator.pop(context, v.trim()),
                        style: TextStyle(
                          fontFamily: AppFonts.body,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                        cursorColor: scheme.primary,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 13),
                          hintText: l.placeSearchHint,
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.body,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: scheme.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            _Row(
              icon: 'place',
              text: l.placeHere,
              accent: true,
              onTap: _busy ? null : _here,
            ),
            if (_busy)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VehaInsets.screen, vertical: 8),
                child: Text(
                  l.placeSearching,
                  style: TextStyle(
                    fontFamily: AppFonts.body,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final name in _found)
                    _Row(
                      icon: 'place',
                      text: name,
                      onTap: () => Navigator.pop(context, name),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  VehaInsets.screen, 8, VehaInsets.screen, 14),
              child: Row(
                children: [
                  if (widget.current != null)
                    TextButton(
                      onPressed: () => Navigator.pop(context, ''),
                      child: Text(l.fieldEraseValue),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, _query.text.trim()),
                    icon: Icon(VehaIcons.byName('check'), size: 18),
                    label: Text(l.actionDone),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.text,
    required this.onTap,
    this.accent = false,
  });

  final String icon;
  final String text;
  final VoidCallback? onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: VehaInsets.screen, vertical: 12),
        child: Row(
          children: [
            Icon(VehaIcons.byName(icon),
                size: 19,
                color: accent ? scheme.primary : scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 14.5,
                  fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
                  color: accent ? scheme.primary : scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
