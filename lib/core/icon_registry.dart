import 'package:flutter/widgets.dart';

/// Белый список иконок Veha.
///
/// Иконка события хранится в базе строкой, и tree-shaking такие
/// обращения не видит. Раньше здесь лежали константы чужого пакета, и
/// в релизной сборке половина иконок исчезала, а три вариативных
/// шрифта занимали 34 мегабайта. Теперь глифы живут в своём шрифте
/// `assets/fonts/VehaSymbols.ttf`, собранном скриптом
/// `tool/build_icon_font.py` ровно по этому списку.
class VehaIcons {
  VehaIcons._();

  static const String fontFamily = 'VehaSymbols';

  static const Map<String, IconData> _all = {
    'alarm': IconData(0xe855, fontFamily: fontFamily),
    'fitness': IconData(0xeb43, fontFamily: fontFamily),
    'restaurant': IconData(0xe56c, fontFamily: fontFamily),
    'groups': IconData(0xf233, fontFamily: fontFamily),
    'coffee': IconData(0xeb44, fontFamily: fontFamily),
    'school': IconData(0xe80c, fontFamily: fontFamily),
    'pool': IconData(0xeb48, fontFamily: fontFamily),
    'book': IconData(0xea19, fontFamily: fontFamily),
    'work': IconData(0xe943, fontFamily: fontFamily),
    'cake': IconData(0xe7e9, fontFamily: fontFamily),
    'pets': IconData(0xe91d, fontFamily: fontFamily),
    'flight': IconData(0xe539, fontFamily: fontFamily),
    'shopping': IconData(0xf1cc, fontFamily: fontFamily),
    'health': IconData(0xe87e, fontFamily: fontFamily),
    'music': IconData(0xe405, fontFamily: fontFamily),
    'movie': IconData(0xe684, fontFamily: fontFamily),
    'ticket': IconData(0xe638, fontFamily: fontFamily),
    'exam': IconData(0xe862, fontFamily: fontFamily),
    'door': IconData(0xeb4f, fontFamily: fontFamily),
    'person': IconData(0xf0d3, fontFamily: fontFamily),
    'place': IconData(0xf1db, fontFamily: fontFamily),
    'bell': IconData(0xe7f5, fontFamily: fontFamily),
    'calendar': IconData(0xebcc, fontFamily: fontFamily),
    'repeat': IconData(0xe040, fontFamily: fontFamily),
    'cloud': IconData(0xe2bf, fontFamily: fontFamily),
    'note': IconData(0xe26c, fontFamily: fontFamily),
    'number': IconData(0xe9ef, fontFamily: fontFamily),
    'text': IconData(0xe8d2, fontFamily: fontFamily),
    'toggle': IconData(0xe9f6, fontFamily: fontFamily),
    'clock': IconData(0xefd6, fontFamily: fontFamily),
    'flag': IconData(0xf0c6, fontFamily: fontFamily),
    'wand': IconData(0xe663, fontFamily: fontFamily),
    'add': IconData(0xe145, fontFamily: fontFamily),
    'key': IconData(0xe73c, fontFamily: fontFamily),
    'dropper': IconData(0xe3b8, fontFamily: fontFamily),
    'chevron': IconData(0xe5cc, fontFamily: fontFamily),
    'link': IconData(0xe250, fontFamily: fontFamily),
    'check': IconData(0xe668, fontFamily: fontFamily),
    'back': IconData(0xe5c4, fontFamily: fontFamily),
    'undo': IconData(0xe166, fontFamily: fontFamily),
    'trash': IconData(0xe92e, fontFamily: fontFamily),
    'pencil': IconData(0xf097, fontFamily: fontFamily),
    'search': IconData(0xef7a, fontFamily: fontFamily),
    'close': IconData(0xe5cd, fontFamily: fontFamily),
    'circle': IconData(0xef4a, fontFamily: fontFamily),
    'list': IconData(0xe241, fontFamily: fontFamily),
    'tune': IconData(0xe429, fontFamily: fontFamily),
    'viewDay': IconData(0xe936, fontFamily: fontFamily),
    'viewAgenda': IconData(0xe8e9, fontFamily: fontFamily),
    'viewWeek': IconData(0xe8f3, fontFamily: fontFamily),
    'timeline': IconData(0xe922, fontFamily: fontFamily),
    'shield': IconData(0xe9e0, fontFamily: fontFamily),
    'download': IconData(0xf090, fontFamily: fontFamily),
    'upload': IconData(0xf09b, fontFamily: fontFamily),
    'palette': IconData(0xe40a, fontFamily: fontFamily),
    'language': IconData(0xea07, fontFamily: fontFamily),
    'info': IconData(0xe88e, fontFamily: fontFamily),
    'eye': IconData(0xe8f4, fontFamily: fontFamily),
    'eyeOff': IconData(0xe8f5, fontFamily: fontFamily),
    'drag': IconData(0xe945, fontFamily: fontFamily),
    'today': IconData(0xe8df, fontFamily: fontFamily),
  };

  /// Иконка по имени. Неизвестное имя — точка, а не крэш: база может
  /// приехать с чужого устройства, где список шире.
  static IconData byName(String? name) =>
      _all[name] ?? _all['circle']!;

  static Iterable<String> get names => _all.keys;
}
