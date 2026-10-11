import 'package:flutter/foundation.dart';

/// One piece of the consent line: plain words or a link.
@immutable
class ConsentPart {
  const ConsentPart.text(this.text) : link = null;
  const ConsentPart.link(this.text, ConsentLink this.link);

  final String text;

  /// Which text the piece opens; `null` for plain words.
  final ConsentLink? link;

  @override
  bool operator ==(Object other) =>
      other is ConsentPart && other.text == text && other.link == link;

  @override
  int get hashCode => Object.hash(text, link);

  @override
  String toString() => 'ConsentPart($text, $link)';
}

/// The text a consent link opens.
enum ConsentLink { terms, kvkk }

/// Cuts the consent sentence ("{terms}'nı ve {kvkk}'ni okudum, kabul
/// ediyorum.") into plain words and its two links, so the screen can draw the
/// links as tappable text while the sentence stays one ARB string.
abstract final class ConsentTextParts {
  /// Placeholder values to format the ARB string with; they never reach the
  /// screen.
  static const String termsMark = '\u{E000}';
  static const String kvkkMark = '\u{E001}';

  /// Splits [formatted] (the ARB string formatted with [termsMark] and
  /// [kvkkMark]) and fills the links with [termsLabel] and [kvkkLabel].
  static List<ConsentPart> split(
    String formatted, {
    required String termsLabel,
    required String kvkkLabel,
  }) {
    final parts = <ConsentPart>[];
    final buffer = StringBuffer();
    void flush() {
      if (buffer.isEmpty) return;
      parts.add(ConsentPart.text(buffer.toString()));
      buffer.clear();
    }

    for (final char in formatted.split('')) {
      switch (char) {
        case termsMark:
          flush();
          parts.add(ConsentPart.link(termsLabel, ConsentLink.terms));
        case kvkkMark:
          flush();
          parts.add(ConsentPart.link(kvkkLabel, ConsentLink.kvkk));
        default:
          buffer.write(char);
      }
    }
    flush();
    return parts;
  }
}
