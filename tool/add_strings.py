#!/usr/bin/env python3
"""Дописывает строки во все семь словарей разом.

Руками это семь файлов на каждую подпись: русский забыть невозможно, а
испанский — запросто, и обнаружится он потом, пустой строкой на экране.
Скрипт читает JSON вида

    {"ключ": {"ru": "...", "en": "...", ..., "@": {"placeholders": {...}}}}

и вставляет каждый перевод в свой `app_*.arb`, сохраняя порядок ключей.
"""

import json
import sys
from collections import OrderedDict
from pathlib import Path

LOCALES = ['ru', 'en', 'uk', 'ro', 'pl', 'de', 'es']
L10N = Path(__file__).resolve().parent.parent / 'lib' / 'l10n'


def main() -> int:
    source = json.loads(Path(sys.argv[1]).read_text(encoding='utf-8'))

    for locale in LOCALES:
        path = L10N / f'app_{locale}.arb'
        data = json.loads(path.read_text(encoding='utf-8'),
                          object_pairs_hook=OrderedDict)

        for key, translations in source.items():
            if locale not in translations:
                raise SystemExit(f'Нет перевода {key} на {locale}')
            data[key] = translations[locale]
            meta = OrderedDict([('description', key)])
            extra = translations.get('@')
            if extra:
                meta.update(extra)
            data[f'@{key}'] = meta

        path.write_text(
            json.dumps(data, ensure_ascii=False, indent=2) + '\n',
            encoding='utf-8',
        )

    print(f'Добавлено {len(source)} строк в {len(LOCALES)} словарей')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
