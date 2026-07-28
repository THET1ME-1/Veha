#!/usr/bin/env python3
"""Собирает шрифт иконок Veha из Material Symbols Rounded.

Зачем свой шрифт. Пакет material_symbols_icons тащит в сборку три вариативных
шрифта на 34 мегабайта, а его иконки выбираются по имени, и tree-shaking
режет глифы вслепую: в релизной сборке пропали иконки навигации и части
событий. Вместо этого берём ровно те иконки, что перечислены в белом списке,
инстанцируем вариативный шрифт в одном начертании и складываем в assets.

Запуск: python3 tool/build_icon_font.py
После правки списка иконок в ICONS перезапустить и закоммитить шрифт.
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

    wanted = set(ICONS.values())
    missing = wanted - all_codes.keys()
    if missing:
        raise SystemExit(f'Не нашлись иконки: {sorted(missing)}')
    return {name: all_codes[name] for name in wanted}


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
            f'--output-file={OUT_FONT}',
        ],
        check=True,
        stdout=subprocess.DEVNULL,
    )


def write_dart(codes: dict[str, int]) -> None:
    lines = [
        "import 'package:flutter/widgets.dart';",
        '',
        '/// Белый список иконок Veha.',
        '///',
        '/// Иконка события хранится в базе строкой, и tree-shaking такие',
        '/// обращения не видит. Раньше здесь лежали константы чужого пакета, и',
        '/// в релизной сборке половина иконок исчезала, а три вариативных',
        '/// шрифта занимали 34 мегабайта. Теперь глифы живут в своём шрифте',
        '/// `assets/fonts/VehaSymbols.ttf`, собранном скриптом',
        '/// `tool/build_icon_font.py` ровно по этому списку.',
        'class VehaIcons {',
        '  VehaIcons._();',
        '',
        f"  static const String fontFamily = '{FAMILY}';",
        '',
        '  static const Map<String, IconData> _all = {',
    ]
    for veha, material in ICONS.items():
        code = codes[material]
        lines.append(
            f"    '{veha}': IconData(0x{code:x}, fontFamily: fontFamily),"
        )
    lines += [
        '  };',
        '',
        '  /// Иконка по имени. Неизвестное имя — точка, а не крэш: база может',
        '  /// приехать с чужого устройства, где список шире.',
        '  static IconData byName(String? name) =>',
        "      _all[name] ?? _all['circle']!;",
        '',
        '  static Iterable<String> get names => _all.keys;',
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
    print(f'{OUT_FONT.relative_to(ROOT)}: {len(ICONS)} иконок, {size:.0f} КБ')


if __name__ == '__main__':
    main()
