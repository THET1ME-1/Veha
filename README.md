<div align="center">

# Veha — Calendar

<br>

[![License](https://img.shields.io/github/license/THET1ME-1/Veha?style=for-the-badge&color=00544A)](LICENSE)
[![Stars](https://img.shields.io/github/stars/THET1ME-1/Veha?style=for-the-badge&color=41CCB5)](https://github.com/THET1ME-1/Veha/stargazers)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Material 3](https://img.shields.io/badge/Material_3-Expressive-41CCB5?style=for-the-badge)
![Local first](https://img.shields.io/badge/Local_first-no_account_needed-00544A?style=for-the-badge)

**A local-first calendar for Android in Material 3 Expressive style** — works
offline with no account, shares selected calendars when you want it to, and lets
you connect an AI assistant with a scoped token and a full audit log.

🇬🇧 🇷🇺 🇺🇦 🇷🇴 🇵🇱 🇩🇪 🇪🇸 · 7 languages

[English](#english) · [Русский](#veha--календарь)

</div>

> **Status: in development.** No release yet. The design document lives in
> [`docs/specs`](docs/specs/2026-07-27-veha-design.md).

---

## English

### Why another calendar

FOSS calendars like Etar and Fossify Calendar keep everything on the device and
cannot share a calendar with another person. Cloud calendars share fine, but you
hand your life to a corporation. Veha does both: the app is fully functional
offline with no account, and any calendar you explicitly mark as shared — and
only that one — goes to a server you choose.

### What makes it different

**Any colour, always readable.** Other calendars give you five preset colours,
because `.ics` only carries named CSS colours and arbitrary hex breaks contrast
and clashes with Material You. Veha lets you pick any colour, then feeds it as a
seed into HCT tonal palettes and paints events with the right tone for the
current theme. Any colour, readable in both themes, consistent with the system.

**Material Symbols instead of emoji.** Around 3500 icons with a searchable
picker, tinted to match the event colour.

**Connect your AI assistant.** Once sync is on, you can issue a scoped token for
an agent: pick which calendars it sees, read or write for each, set an expiry,
revoke in one tap. Every action the token takes is written to a log you can read.
Google Calendar does not show you what a third-party app actually did. Veha does.

**Your own fields.** No calendar lets you put a room number, a teacher or a
membership ID on an event. Veha does: define a field of any type, then choose
which ones show on the collapsed card. Built-in fields sit in the same list, so
there is no seam between what ships and what you added.

**Two readings of a day.** A chain of full-radius pills for "what do I have
today", and a proportional clock for "when am I free". The week is seven columns
of pills sized by duration.

### Stack

Flutter · drift (SQLite) · riverpod · rrule · dynamic_color ·
material_color_utilities · material_symbols_icons

Optional server (separate repository, stage 3): Hono · Drizzle ·
Cloudflare Workers + D1, or Node/Bun + SQLite in Docker.

### Principles

1. **Local-first.** Fully functional with no network and no account. Sync is a
   layer on top of the local database, never its foundation.
2. **Only what you shared leaves the device.** Personal calendars never go up,
   and the settings screen always lists what did.
3. **The server is dumb.** It stores and serves. The device is the source of
   truth.
4. **Speed over features.** Cold start to a rendered month under 500 ms.

### Licence

GPL-3.0. Distribution via GitHub Releases, Obtainium and F-Droid.
Android only — iOS is not planned.

---

## Veha — Календарь

### Зачем ещё один календарь

FOSS-календари вроде Etar и Fossify Calendar держат всё на устройстве и не умеют
делиться календарём с другим человеком. Облачные делятся отлично, но требуют
отдать данные корпорации. Veha делает и то, и другое: приложение полностью
работает офлайн и без аккаунта, а на сервер уходит только тот календарь, который
вы сами пометили общим.

### Чем отличается

**Любой цвет и всегда читаемо.** У остальных календарей пять цветов на выбор,
потому что `.ics` переносит только именованные CSS-цвета, а произвольный hex
ломает контраст и спорит с Material You. Veha берёт любой выбранный цвет как
seed, строит из него тональную палитру HCT и рисует событие тоном под текущую
тему. Цвет любой, читается в обеих темах, согласован с системой.

**Material Symbols вместо эмодзи.** Около 3500 иконок с поиском, иконка красится
в тон цвета события.

**Свой ИИ-ассистент по ключу.** Когда включена синхронизация, можно выдать агенту
токен: галочками выбрать, какие календари он видит, чтение или запись по каждому,
задать срок и отозвать в один тап. Всё, что ключ делал, пишется в журнал. Google
Calendar не показывает, что именно творило стороннее приложение. Veha показывает.

**Свои поля.** Ни один календарь не даёт положить в событие кабинет,
преподавателя или номер абонемента. Veha даёт: заводите поле любого типа и сами
решаете, какие видны в свёрнутой карточке. Встроенные поля лежат в том же
списке, шва между «что было в приложении» и «что я завёл» нет.

**Два прочтения дня.** Цепочка пилюль отвечает на вопрос «что у меня сегодня»,
пропорциональная шкала — «когда я свободен». Неделя — семь колонок пилюль,
высота по длительности.

### Стек

Flutter · drift (SQLite) · riverpod · rrule · dynamic_color ·
material_color_utilities · material_symbols_icons

Опциональный сервер (отдельный репозиторий, третий этап): Hono · Drizzle ·
Cloudflare Workers + D1 либо Node/Bun + SQLite в Docker.

### Принципы

1. **Local-first.** Всё работает без сети и без аккаунта. Синхронизация — слой
   поверх локальной базы, а не её основа.
2. **Наверх уходит только явно расшаренное.** Личные календари не покидают
   устройство, а в настройках виден список того, что ушло.
3. **Сервер тупой.** Он хранит и раздаёт. Источник истины — устройство.
4. **Скорость важнее фич.** Холодный старт до отрисовки месяца — под 500 мс.

### Лицензия

GPL-3.0. Распространение через GitHub Releases, Obtainium и F-Droid.
Только Android, iOS не планируется.
