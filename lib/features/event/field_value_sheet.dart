import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/brand.dart';
import '../../core/icon_registry.dart';
import '../../data/models.dart';
import '../calendar/widgets/month_header.dart' show AppFonts;

/// Заполнение своего поля. Форма ввода зависит от типа: дату спрашиваем
/// календарём, время часами, флажок вообще не открывает лист — он
/// переключается прямо в строке.
///
/// Возврат: новое значение либо пустая строка, если поле стирают. `null` —
/// человек передумал.
Future<String?> askFieldValue(
  BuildContext context, {
  required VFieldDef def,
  required String? current,
}) async {
  switch (def.type) {
    case VFieldType.date:
      final picked = await showDatePicker(
        context: context,
        initialDate: _parseDate(current) ?? DateTime.now(),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 10),
      );
      if (picked == null) return null;
      return DateFormat('yyyy-MM-dd').format(picked);

    case VFieldType.time:
      final picked = await showTimePicker(
        context: context,
        initialTime: _parseTime(current) ?? TimeOfDay.now(),
      );
      if (picked == null) return null;
      return '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}';

    case VFieldType.checkbox:
      return current == 'да' ? '' : 'да';

    default:
      return showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: _TextSheet(def: def, current: current),
        ),
      );
  }
}

/// Как значение показывается в строке. Дата и время хранятся машинными
/// строками, а читать их человеку — «28 июля».
String showFieldValue(VFieldDef def, String value) {
  switch (def.type) {
    case VFieldType.date:
      final d = _parseDate(value);
      return d == null ? value : DateFormat('d MMMM', 'ru').format(d);
    case VFieldType.checkbox:
      return value == 'да' ? 'да' : 'нет';
    case VFieldType.money:
      return '$value ₽';
    default:
      return value;
  }
}

DateTime? _parseDate(String? value) =>
    value == null ? null : DateTime.tryParse(value);

TimeOfDay? _parseTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  return TimeOfDay(hour: h, minute: m);
}

class _TextSheet extends StatefulWidget {
  const _TextSheet({required this.def, required this.current});

  final VFieldDef def;
  final String? current;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final TextEditingController _value =
      TextEditingController(text: widget.current ?? '');

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  /// Клавиатура под тип: телефон и число незачем набирать буквенной.
  TextInputType get _keyboard => switch (widget.def.type) {
        VFieldType.number || VFieldType.money => TextInputType.number,
        VFieldType.phone => TextInputType.phone,
        VFieldType.url => TextInputType.url,
        _ => TextInputType.text,
      };

  List<TextInputFormatter> get _formatters => switch (widget.def.type) {
        VFieldType.number ||
        VFieldType.money =>
          [FilteringTextInputFormatter.digitsOnly],
        _ => const [],
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 2, VehaInsets.screen, 2),
            child: Text(
              widget.def.name,
              style: TextStyle(
                fontFamily: AppFonts.display,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 0, VehaInsets.screen, 10),
            child: Text(
              widget.def.type.label,
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VehaInsets.screen),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: ShapeDecoration(
                color: scheme.surfaceContainerHigh,
                shape: const StadiumBorder(),
              ),
              child: TextField(
                controller: _value,
                autofocus: true,
                keyboardType: _keyboard,
                inputFormatters: _formatters,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
                cursorColor: scheme.primary,
                decoration: const InputDecoration(
                  isDense: true,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (v) => Navigator.pop(context, v),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                VehaInsets.screen, 14, VehaInsets.screen, 14),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, ''),
                  child: const Text('Стереть'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, _value.text),
                  icon: Icon(VehaIcons.byName('check'), size: 18),
                  label: const Text('Готово'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
