#!/usr/bin/env python3
"""Собирает шрифт иконок Veha из Material Symbols Rounded.

Зачем свой шрифт. Пакет material_symbols_icons тащит в сборку три вариативных
шрифта на 34 мегабайта, а его иконки выбираются по имени, и tree-shaking
режет глифы вслепую: в релизной сборке пропали иконки навигации и части
событий. Здесь вариативный шрифт схлопывается в одно начертание — все 4300
иконок весят 1,7 МБ, и качать по сети нечего.

Берём весь набор, а не белый список: человеку нужна его иконка, а угадать её
заранее нельзя. Короткие имена Veha («fitness», «trash») остаются псевдонимами
поверх настоящих — по ним записаны события в уже existing базах.

Запуск: python3 tool/build_icon_font.py
После обновления пакета перезапустить и закоммитить шрифт с реестром.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

# Имя иконки в Veha → имя в Material Symbols (без суффикса стиля).
ICONS: dict[str, str] = {
    'alarm': 'alarm',
    'fitness': 'fitness_center',
    'restaurant': 'restaurant',
    'groups': 'groups',
    'coffee': 'local_cafe',
    'school': 'school',
    'pool': 'pool',
    'book': 'menu_book',
    'work': 'work',
    'cake': 'cake',
    'pets': 'pets',
    'flight': 'flight',
    'shopping': 'shopping_bag',
    'health': 'favorite',
    'music': 'music_note',
    'movie': 'movie',
    'ticket': 'confirmation_number',
    'exam': 'assignment_turned_in',
    'door': 'meeting_room',
    'person': 'person',
    'place': 'location_on',
    'bell': 'notifications',
    'calendar': 'calendar_month',
    'repeat': 'repeat',
    'cloud': 'cloud_done',
    'note': 'notes',
    'number': 'tag',
    'text': 'subject',
    'toggle': 'toggle_on',
    'clock': 'schedule',
    'flag': 'flag',
    'wand': 'auto_fix_high',
    'add': 'add',
    'key': 'key',
    'dropper': 'colorize',
    'chevron': 'chevron_right',
    'link': 'link',
    'check': 'check',
    'back': 'arrow_back',
    'undo': 'undo',
    'trash': 'delete',
    'pencil': 'edit',
    'search': 'search',
    'close': 'close',
    'circle': 'circle',
    'list': 'format_list_bulleted',
    'tune': 'tune',
    'viewDay': 'calendar_view_day',
    'viewAgenda': 'view_agenda',
    'viewWeek': 'view_week',
    'timeline': 'timeline',
    'shield': 'shield',
    'download': 'download',
    'upload': 'upload',
    'palette': 'palette',
    'language': 'language',
    'info': 'info',
    'eye': 'visibility',
    'eyeOff': 'visibility_off',
    'drag': 'drag_indicator',
    'today': 'today',
}

ROOT = Path(__file__).resolve().parent.parent
OUT_FONT = ROOT / 'assets' / 'fonts' / 'VehaSymbols.ttf'
OUT_DART = ROOT / 'lib' / 'core' / 'icon_registry.dart'
FAMILY = 'VehaSymbols'


# Ходовой ряд: с него открывается выбор, остальное — через поиск.
PICKABLE = [
    'alarm', 'fitness', 'restaurant', 'groups', 'coffee', 'school',
    'pool', 'book', 'work', 'cake', 'pets', 'flight',
    'shopping', 'health', 'music', 'movie', 'ticket', 'exam',
    'door', 'person', 'place', 'bell', 'calendar', 'repeat',
    'cloud', 'note', 'number', 'text', 'toggle', 'clock',
    'flag', 'key', 'link', 'list', 'today', 'language',
]


def pub_cache_font() -> tuple[Path, Path]:
    """Путь к вариативному шрифту и карте кодов внутри material_symbols_icons."""
    config = json.loads((ROOT / '.dart_tool' / 'package_config.json').read_text())
    for package in config['packages']:
        if package['name'] == 'material_symbols_icons':
            root = Path(package['rootUri'].replace('file://', ''))
            if not root.is_absolute():
                root = (ROOT / '.dart_tool' / root).resolve()
            return (
                root / 'lib' / 'fonts' / 'MaterialSymbolsRounded.ttf',
                root / 'lib' / 'iconname_to_unicode_map.dart',
            )
    raise SystemExit('Пакет material_symbols_icons не найден, сделайте flutter pub get')


def codepoints(name_map: Path) -> dict[str, int]:
    """Коды нужных иконок из карты пакета: имя → codepoint."""
    source = name_map.read_text(encoding='utf-8')
    all_codes = {
        match.group(1): int(match.group(2), 16)
        for match in re.finditer(r"'([\w]+)':\s*0x([0-9a-fA-F]+)", source)
    }

    missing = set(ICONS.values()) - all_codes.keys()
    if missing:
        raise SystemExit(f'Не нашлись иконки: {sorted(missing)}')
    return all_codes


def subset(font: Path, codes: list[int]) -> None:
    OUT_FONT.parent.mkdir(parents=True, exist_ok=True)
    unicodes = ','.join(f'U+{code:04X}' for code in codes)

    # Вариативные оси схлопываем в одно начертание: FILL=0 (контур), вес 400.
    # Иначе в сборку уезжают все промежуточные состояния, а нужен один вид.
    subprocess.run(
        [
            sys.executable, '-m', 'fontTools.varLib.instancer',
            str(font),
            'FILL=0', 'wght=400', 'GRAD=0', 'opsz=24',
            '-o', str(OUT_FONT),
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )
    subprocess.run(
        [
            sys.executable, '-m', 'fontTools.subset',
            str(OUT_FONT),
            f'--unicodes={unicodes}',
            '--no-layout-closure',
            '--desubroutinize',
            f'--output-file={OUT_FONT}',
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def write_dart(codes: dict[str, int]) -> None:
    lines = [
        "import 'package:flutter/widgets.dart';",
        '',
        '/// Иконки Veha: весь набор Material Symbols Rounded.',
        '///',
        '/// Иконка события хранится в базе строкой, и tree-shaking такие',
        '/// обращения не видит — поэтому глифы живут в своём шрифте',
        '/// `assets/fonts/VehaSymbols.ttf`, собранном скриптом',
        '/// `tool/build_icon_font.py`. Файл сгенерирован, править руками',
        '/// бессмысленно: изменения затрёт следующий запуск.',
        'class VehaIcons {',
        '  VehaIcons._();',
        '',
        f"  static const String fontFamily = '{FAMILY}';",
        '',
        '  /// Короткие имена, которыми Veha пользовалась до полного набора.',
        '  /// Ими записаны события в уже заведённых базах, поэтому остаются',
        '  /// навсегда: переименование осиротит чужие записи.',
        '  static const Map<String, String> _aliases = {',
    ]
    for veha, material in ICONS.items():
        if veha != material:
            lines.append(f"    '{veha}': '{material}',")
    lines += [
        '  };',
        '',
        '  static const Map<String, IconData> _all = {',
    ]
    for name in sorted(codes):
        lines.append(
            f"    '{name}': IconData(0x{codes[name]:x}, fontFamily: fontFamily),"
        )
    lines += [
        '  };',
        '',
        '  /// Иконка по имени. Неизвестное имя — точка, а не крэш: база может',
        '  /// приехать с чужого устройства, где набор шире.',
        '  static IconData byName(String? name) {',
        '    if (name == null) return _all[fallback]!;',
        '    return _all[_aliases[name] ?? name] ?? _all[fallback]!;',
        '  }',
        '',
        "  static const String fallback = 'circle';",
        '',
        '  /// Все имена набора. По ним же идёт поиск в выборе иконки.',
        '  static Iterable<String> get names => _all.keys;',
        '',
        '  /// Ходовые иконки: их показывают первыми, до поиска. Порядок',
        '  /// осмысленный — люди, занятия, еда, дорога, знаки.',
        '  static const List<String> pickable = [',
    ]
    for veha in PICKABLE:
        lines.append(f"    '{ICONS.get(veha, veha)}',")
    lines += [
        '  ];',
        '}',
        '',
    ]
    OUT_DART.write_text('\n'.join(lines), encoding='utf-8')


def main() -> None:
    font, name_map = pub_cache_font()
    codes = codepoints(name_map)
    subset(font, sorted(codes.values()))
    write_dart(codes)
    size = OUT_FONT.stat().st_size / 1024
    print(f'{OUT_FONT.relative_to(ROOT)}: {len(codes)} иконок, {size:.0f} КБ')


if __name__ == '__main__':
    main()
