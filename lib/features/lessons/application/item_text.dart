import 'package:flutter/foundation.dart' show immutable, listEquals;

/// An example of an item and, when the text carries one, its explanation (C51
/// `ExampleBox`; pano 7.3: "Örnek" / "Bazı insanlar karanlıktan korkar." /
/// "Karanlık" burada ışıksız anlamında kullanılmış).
@immutable
class ItemExample {
  const ItemExample({required this.text, this.explanation});

  /// The example sentence.
  final String text;

  /// What the example shows; `null` when the text has none.
  final String? explanation;

  @override
  bool operator ==(Object other) =>
      other is ItemExample &&
      other.text == text &&
      other.explanation == explanation;

  @override
  int get hashCode => Object.hash(text, explanation);
}

/// An item's text split into what the reader sees: the definition paragraphs
/// and the examples in their own boxes (pano 7.3 "tanım" and "Örnek kutusu").
@immutable
class ItemText {
  const ItemText({this.definition = const [], this.examples = const []});

  /// The paragraphs that are not examples, in order.
  final List<String> definition;
  final List<ItemExample> examples;

  /// Nothing to read.
  bool get isEmpty => definition.isEmpty && examples.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is ItemText &&
      listEquals(other.definition, definition) &&
      listEquals(other.examples, examples);

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(definition), Object.hashAll(examples));
}

/// Splits the paragraphs of an item (`desc`) into definition and examples.
/// Pure and unit-tested.
///
/// The server sends one list of paragraphs; the old screen drew them all as
/// bullets and the example sat among them ("• Örnek: Bazı insanlar karanlıktan
/// korkar. (Cümledeki karanlık, ışıksız anlamında kullanılmıştır.)"). A
/// paragraph that starts with "Örnek" and a colon (or a dash) is an example;
/// when it ends with a sentence in parentheses, that sentence is the
/// explanation. Everything else is the definition. A bullet mark in front of
/// a paragraph is dropped. Whether the backend should send the example as a
/// field of its own is an open question (report).
abstract final class ItemTextParser {
  static ItemText parse(List<String> paragraphs) {
    final definition = <String>[];
    final examples = <ItemExample>[];
    for (final raw in paragraphs) {
      final paragraph = _stripBullet(raw.trim());
      if (paragraph.isEmpty) continue;
      final example = _exampleOf(paragraph);
      if (example == null) {
        definition.add(paragraph);
      } else {
        examples.add(example);
      }
    }
    return ItemText(definition: definition, examples: examples);
  }

  static String _stripBullet(String text) {
    var value = text;
    while (value.isNotEmpty && _bullets.contains(value[0])) {
      value = value.substring(1).trimLeft();
    }
    return value;
  }

  static const Set<String> _bullets = {'•', '·', '-', '–', '*'};

  /// "Örnek:", "Örnek 2:", "Örnek -": the marker of an example paragraph.
  static final RegExp _marker = RegExp(r'^[ÖöOo]rnek\s*\d*\s*[:\-–]\s*');

  /// A closing sentence in parentheses.
  static final RegExp _explanation = RegExp(r'^(.*\S)\s*\(([^()]+)\)\s*$');

  static ItemExample? _exampleOf(String paragraph) {
    final marker = _marker.firstMatch(paragraph);
    if (marker == null) return null;
    final body = paragraph.substring(marker.end).trim();
    if (body.isEmpty) return null;
    final split = _explanation.firstMatch(body);
    if (split != null) {
      final note = split.group(2)!.trim();
      if (_isSentence(note)) {
        return ItemExample(text: split.group(1)!.trim(), explanation: note);
      }
    }
    return ItemExample(text: body);
  }

  /// A parenthesis that is a sentence ("Cümledeki karanlık, ışıksız anlamında
  /// kullanılmıştır."), not a date or a number ("(1071)").
  static bool _isSentence(String note) =>
      note.length >= 10 && note.contains(' ');
}
