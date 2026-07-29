/// Разметка заметки: списки, галочки и ссылки.
///
/// Хранится всё той же строкой: отдельных таблиц под пункты нет намеренно —
/// заметку правят целиком в одном поле, а разбор нужен, только чтобы её
/// показать. Поэтому он обязан быть обратимым и не терять ни символа: что
/// человек написал, то и лежит в базе.
library;

enum NoteLineKind { text, bullet, check }

/// Кусок строки: обычный текст или ссылка.
class NoteSpan {
  const NoteSpan(this.text, {this.link});

  final String text;

  /// `null` — обычный текст. Иначе адрес, по которому уходят при тапе.
  final String? link;
}

/// Строка заметки после разбора.
class NoteLine {
  const NoteLine({
    required this.kind,
    required this.content,
    required this.spans,
    this.checked = false,
  });

  final NoteLineKind kind;

  /// Текст без маркера: «- » и «[x] » при показе рисуются знаком, а не
  /// буквами.
  final String content;
  final bool checked;
  final List<NoteSpan> spans;
}

/// Сколько пунктов сделано. `null` — галочек в заметке нет.
class NoteProgress {
  const NoteProgress({required this.done, required this.total});

  final int done;
  final int total;
}

/// Маркер списка в начале строки: «- », «— », «• ».
final RegExp _bullet = RegExp(r'^\s*[-—•]\s+');

/// Галочка: «[ ]» или «[x]», сама по себе или следом за маркером списка.
final RegExp _check = RegExp(r'^\s*(?:[-—•]\s+)?\[([ xXvV])\]\s*');

/// Ссылка. Хвостовая пунктуация в адрес не входит: точка в конце
/// предложения ломала бы открытие.
final RegExp _link = RegExp(r'(https?://[^\s<>"]+[^\s<>".,;:!?)\]])');

List<NoteLine> parseNote(String text) => [
      for (final raw in text.split('\n')) _lineOf(raw),
    ];

NoteLine _lineOf(String raw) {
  final check = _check.firstMatch(raw);
  if (check != null) {
    final mark = check.group(1)!;
    final content = raw.substring(check.end);
    return NoteLine(
      kind: NoteLineKind.check,
      content: content,
      checked: mark != ' ',
      spans: _spansOf(content),
    );
  }

  final bullet = _bullet.firstMatch(raw);
  if (bullet != null) {
    final content = raw.substring(bullet.end);
    return NoteLine(
      kind: NoteLineKind.bullet,
      content: content,
      spans: _spansOf(content),
    );
  }

  return NoteLine(
    kind: NoteLineKind.text,
    content: raw,
    spans: _spansOf(raw),
  );
}

List<NoteSpan> _spansOf(String line) {
  final spans = <NoteSpan>[];
  var cursor = 0;

  for (final match in _link.allMatches(line)) {
    if (match.start > cursor) {
      spans.add(NoteSpan(line.substring(cursor, match.start)));
    }
    spans.add(NoteSpan(match.group(0)!, link: match.group(0)));
    cursor = match.end;
  }

  if (cursor < line.length) spans.add(NoteSpan(line.substring(cursor)));
  return spans;
}

/// Отметить пункт сделанным и обратно. Возвращает всю заметку: правим строку
/// на месте, чтобы остальное осталось ровно таким, как человек написал.
String toggleNoteCheck(String text, int lineIndex) {
  final lines = text.split('\n');
  if (lineIndex < 0 || lineIndex >= lines.length) return text;

  final line = lines[lineIndex];
  final match = _check.firstMatch(line);
  if (match == null) return text;

  final done = match.group(1)! != ' ';
  final head = line.substring(0, match.start);
  final marker = _bullet.hasMatch(line) ? '- ' : '';
  lines[lineIndex] =
      '$head$marker[${done ? ' ' : 'x'}] ${line.substring(match.end)}';
  return lines.join('\n');
}

/// Счётчик галочек для свёрнутой карточки: «2 из 5» видно, не разворачивая
/// заметку.
NoteProgress? noteProgress(List<NoteLine> lines) {
  final checks = lines.where((l) => l.kind == NoteLineKind.check);
  if (checks.isEmpty) return null;
  return NoteProgress(
    done: checks.where((l) => l.checked).length,
    total: checks.length,
  );
}
