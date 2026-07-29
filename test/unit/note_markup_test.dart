import 'package:flutter_test/flutter_test.dart';
import 'package:veha/domain/note_markup.dart';

/// Разметка заметки: списки, галочки и ссылки.
///
/// Хранится всё той же строкой — отдельных таблиц под пункты нет намеренно:
/// заметку правят целиком в одном поле, а разбор нужен только чтобы её
/// показать. Значит он обязан быть обратимым и не терять ни символа.
void main() {
  test('Обычный текст остаётся абзацем', () {
    final lines = parseNote('Взять ключи');
    expect(lines.single.kind, NoteLineKind.text);
    expect(lines.single.content, 'Взять ключи');
  });

  test('Дефис в начале строки делает пункт списка', () {
    final lines = parseNote('- Хлеб\n- Молоко');
    expect(lines.map((l) => l.kind), everyElement(NoteLineKind.bullet));
    expect(lines.map((l) => l.content), ['Хлеб', 'Молоко']);
  });

  test('Квадратные скобки делают галочку', () {
    final lines = parseNote('[ ] Позвонить\n[x] Купить билет');
    expect(lines.first.kind, NoteLineKind.check);
    expect(lines.first.checked, isFalse);
    expect(lines.first.content, 'Позвонить');
    expect(lines.last.checked, isTrue);
  });

  test('Галочка пишется и через дефис', () {
    // Так её ставят руками, если раньше это был обычный пункт списка.
    final lines = parseNote('- [x] Хлеб');
    expect(lines.single.kind, NoteLineKind.check);
    expect(lines.single.checked, isTrue);
    expect(lines.single.content, 'Хлеб');
  });

  test('Ссылка отделяется от текста', () {
    final spans = parseNote('Созвон тут https://meet.example/room-7 в 15:00')
        .single
        .spans;
    expect(spans.map((s) => s.link).whereType<String>().single,
        'https://meet.example/room-7');
    expect(spans.first.text, 'Созвон тут ');
    expect(spans.last.text, ' в 15:00');
  });

  test('Точка после ссылки в неё не входит', () {
    // Иначе адрес открывается битым: точка в конце предложения — знак
    // препинания, а не часть ссылки.
    final spans = parseNote('Смотри https://example.com/a.').single.spans;
    expect(spans.firstWhere((s) => s.link != null).link, 'https://example.com/a');
  });

  test('Галочка переключается, остальные строки не трогаются', () {
    const text = '[ ] Позвонить\nЗаехать за тортом\n[x] Купить билет';
    final next = toggleNoteCheck(text, 0);
    expect(next, '[x] Позвонить\nЗаехать за тортом\n[x] Купить билет');
    expect(toggleNoteCheck(next, 2),
        '[x] Позвонить\nЗаехать за тортом\n[ ] Купить билет');
  });

  test('Переключение чужой строки ничего не меняет', () {
    const text = 'Просто текст';
    expect(toggleNoteCheck(text, 0), text);
    expect(toggleNoteCheck(text, 5), text);
  });

  test('Сколько пунктов сделано — видно без разворота заметки', () {
    final progress = noteProgress(parseNote('[x] Раз\n[ ] Два\n- Три'));
    expect(progress?.done, 1);
    expect(progress?.total, 2);
    expect(noteProgress(parseNote('Без галочек')), isNull);
  });
}
