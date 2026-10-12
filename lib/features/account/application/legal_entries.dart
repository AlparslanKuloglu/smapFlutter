import 'package:flutter/foundation.dart';

import 'package:smap/features/account/data/dtos/legal_document_dto.dart';

/// Which of the known legal texts a document is, by its machine name (the
/// registration flow records the accepted version by the same names).
enum LegalKind {
  /// `kullanim_kosullari`: "Kullanım Koşulları".
  terms,

  /// `kvkk_aydinlatma_metni`: "KVKK Aydınlatma Metni".
  kvkk,

  /// `gizlilik_politikasi`: "Gizlilik Politikası".
  privacy,

  /// A document the app does not know by name; listed only when it carries a
  /// title of its own.
  other;

  /// Reads a document's machine name; [other] for anything else.
  static LegalKind of(String? name) => switch (name?.trim()) {
    'kullanim_kosullari' => terms,
    'kvkk_aydinlatma_metni' => kvkk,
    'gizlilik_politikasi' => privacy,
    _ => other,
  };
}

/// One row of "Sözleşmeler" (pano 9.7 kare 1): a legal text with the title and
/// the version to show.
///
/// The design also shows a date ("1 Eylül 2026"); the backend sends none
/// (spec §6.3 #13, assumption 8.2), so none is drawn.
@immutable
class LegalEntry {
  const LegalEntry({required this.document, required this.kind});

  final LegalDocumentDto document;
  final LegalKind kind;

  /// The server's own heading; `null` when it sent none (the screen then
  /// writes the title of [kind]).
  String? get title {
    final text = document.title?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// The version text ("1.2.0"); `null` when the server sent none.
  String? get version {
    final text = document.version?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  /// A stable id for the row.
  String get key => document.id ?? document.name ?? title ?? '';

  /// The rows of "Sözleşmeler" for the [documents] the server sent: the
  /// active ones, in the design's order (terms, KVKK, privacy, then others),
  /// without a document that has neither a known name nor a title of its own
  /// (nothing honest to call it).
  static List<LegalEntry> listOf(Iterable<LegalDocumentDto> documents) {
    final entries = <LegalEntry>[];
    for (final document in documents) {
      if (!document.active) continue;
      final entry = LegalEntry(
        document: document,
        kind: LegalKind.of(document.name),
      );
      if (entry.kind == LegalKind.other && entry.title == null) continue;
      entries.add(entry);
    }
    // `List.sort` is not stable: break ties by the server's order.
    final ordered = [...entries.indexed]
      ..sort((a, b) {
        final byKind = a.$2.kind.index.compareTo(b.$2.kind.index);
        return byKind != 0 ? byKind : a.$1.compareTo(b.$1);
      });
    return [for (final (_, entry) in ordered) entry];
  }

  @override
  bool operator ==(Object other) =>
      other is LegalEntry && other.document == document && other.kind == kind;

  @override
  int get hashCode => Object.hash(document, kind);
}

/// The text of a legal document as the reading screen draws it (pano 9.7
/// kare 2: the server's text in the app's own type, not a web view).
abstract final class LegalReading {
  static final RegExp _tag = RegExp(r'</?[a-zA-Z][^>]*>');
  static final RegExp _blankLine = RegExp(r'\r?\n[ \t]*\r?\n');

  /// Whether [content] holds markup (any HTML tag).
  static bool isHtml(String content) => _tag.hasMatch(content);

  /// [content] as HTML for the reader. HTML passes through; plain text, which
  /// a web view would show as one run-on line, becomes paragraphs at blank
  /// lines with `<br>` at single line breaks (and is escaped). Empty for no
  /// text.
  static String htmlOf(String? content) {
    final text = content?.trim() ?? '';
    if (text.isEmpty) return '';
    if (isHtml(text)) return text;
    final paragraphs = text
        .split(_blankLine)
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .map(
          (paragraph) =>
              '<p>${_escape(paragraph).replaceAll(RegExp(r'\r?\n'), '<br>')}</p>',
        );
    return paragraphs.join();
  }

  static String _escape(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}
