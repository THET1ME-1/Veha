import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Белый список иконок.
///
/// Иконка события хранится в базе строкой, а tree-shaking такие обращения не
/// видит: он либо выбросит нужное, либо придётся тащить весь шрифт целиком.
/// Поэтому все допустимые иконки перечислены здесь явно — компилятор видит
/// каждую константу, шейкер оставляет только их.
class VehaIcons {
  VehaIcons._();

  static const Map<String, IconData> _all = {
    'alarm': Symbols.alarm_rounded,
    'fitness': Symbols.fitness_center_rounded,
    'restaurant': Symbols.restaurant_rounded,
    'groups': Symbols.groups_rounded,
    'coffee': Symbols.local_cafe_rounded,
    'school': Symbols.school_rounded,
    'pool': Symbols.pool_rounded,
    'book': Symbols.menu_book_rounded,
    'work': Symbols.work_rounded,
    'cake': Symbols.cake_rounded,
    'pets': Symbols.pets_rounded,
    'flight': Symbols.flight_rounded,
    'shopping': Symbols.shopping_bag_rounded,
    'health': Symbols.favorite_rounded,
    'music': Symbols.music_note_rounded,
    'movie': Symbols.movie_rounded,
    'ticket': Symbols.confirmation_number_rounded,
    'exam': Symbols.assignment_turned_in_rounded,
    'door': Symbols.meeting_room_rounded,
    'person': Symbols.person_rounded,
    'place': Symbols.location_on_rounded,
    'bell': Symbols.notifications_rounded,
    'calendar': Symbols.calendar_month_rounded,
    'repeat': Symbols.repeat_rounded,
    'cloud': Symbols.cloud_done_rounded,
    'note': Symbols.notes_rounded,
    'number': Symbols.tag_rounded,
    'text': Symbols.subject_rounded,
    'toggle': Symbols.toggle_on_rounded,
    'clock': Symbols.schedule_rounded,
    'flag': Symbols.flag_rounded,
    'wand': Symbols.auto_fix_high_rounded,
    'add': Symbols.add_rounded,
    'key': Symbols.key_rounded,
    'chevron': Symbols.chevron_right_rounded,
    'link': Symbols.link_rounded,
  };

  /// Иконка по имени. Неизвестное имя — точка, а не крэш: база может приехать
  /// с чужого устройства, где список шире.
  static IconData byName(String? name) =>
      _all[name] ?? Symbols.circle_rounded;

  static Iterable<String> get names => _all.keys;
}
