import 'package:flutter/foundation.dart';

/// One option of the optical form: A to E, or no mark ("Boş").
///
/// The answer sheet has five options a question; the fix sheet offers the
/// five letters and "Boş" (pano 4.7 kare 2), which is [blank].
enum AnswerChoice {
  a('A'),
  b('B'),
  c('C'),
  d('D'),
  e('E'),
  blank('Boş');

  const AnswerChoice(this.legacyValue);

  /// The text the server's `answerArray` edits carry: the letter, or
  /// `Boş` for no mark (the legacy sheet's option list, unchanged).
  final String legacyValue;

  /// The letters A to E, in the order the form prints them.
  static const List<AnswerChoice> letters = [a, b, c, d, e];

  /// The letter, or `null` for [blank] (the cell then draws a dash).
  String? get letter => this == blank ? null : legacyValue;

  /// Reads one entry of the server's `answersArray`.
  ///
  /// A letter A to E (either case) is that option; `null`, an empty string, a
  /// dash and "Boş" are no mark. Anything else is not understood and yields
  /// `null`, so the caller can tell "no mark" from "unreadable".
  static AnswerChoice? parse(Object? raw) {
    if (raw == null) return blank;
    if (raw is! String) return null;
    final text = raw.trim();
    if (text.isEmpty) return blank;
    switch (text.toUpperCase()) {
      case 'A':
        return a;
      case 'B':
        return b;
      case 'C':
        return c;
      case 'D':
        return d;
      case 'E':
        return e;
      case '-':
      case '–':
      case '—':
      case '_':
      case 'BOŞ':
      case 'BOS':
        return blank;
    }
    return null;
  }
}

/// The answers the optical reader found: the columns of the form with a
/// choice for each question (pano 4.7; spec §4.C 4.7 "Veri").
///
/// A form has four columns of 40 questions. The server's `answersArray` is
/// read as a list of columns, each a list of 40 entries; a flat list is cut
/// into columns of 40. Columns and questions are counted from 1 in the UI and
/// in the `answerArray` edits ("3. kolon · 12. soru" is `"Kolon 3": {"12": …}`);
/// the accessors here take those 1-based numbers.
@immutable
class AnswerGrid {
  /// A grid of [columns]; every column is a list of choices from the first
  /// question down.
  AnswerGrid(Iterable<List<AnswerChoice>> columns)
    : columns = List.unmodifiable(columns.map(List<AnswerChoice>.unmodifiable));

  /// Questions in a full column.
  static const int columnSize = 40;

  /// The columns, left to right.
  final List<List<AnswerChoice>> columns;

  /// Reads the server's `answersArray`. `null` when it is missing, empty or
  /// holds something that is not a choice, which the flow treats as "form not
  /// found" (the reader found no answer area).
  static AnswerGrid? parse(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    final rawColumns = raw.every((entry) => entry is List)
        ? raw.cast<List<Object?>>()
        : _chunk(raw);
    final columns = <List<AnswerChoice>>[];
    for (final rawColumn in rawColumns) {
      if (rawColumn.isEmpty) return null;
      final column = <AnswerChoice>[];
      for (final entry in rawColumn) {
        final choice = AnswerChoice.parse(entry);
        if (choice == null) return null;
        column.add(choice);
      }
      columns.add(column);
    }
    return columns.isEmpty ? null : AnswerGrid(columns);
  }

  static List<List<Object?>> _chunk(List<Object?> flat) => [
    for (var start = 0; start < flat.length; start += columnSize)
      flat.sublist(
        start,
        start + columnSize > flat.length ? flat.length : start + columnSize,
      ),
  ];

  /// How many columns there are.
  int get columnCount => columns.length;

  /// Every question of every column ("160 cevap okundu").
  int get totalCells => columns.fold(0, (sum, column) => sum + column.length);

  /// Questions in [column] (1-based).
  int questionCount(int column) => columns[column - 1].length;

  /// The choice the reader found for [question] of [column], both 1-based.
  AnswerChoice at(int column, int question) =>
      columns[column - 1][question - 1];

  /// Whether [column] and [question] (1-based) exist.
  bool contains(int column, int question) =>
      column >= 1 &&
      column <= columnCount &&
      question >= 1 &&
      question <= questionCount(column);

  @override
  bool operator ==(Object other) =>
      other is AnswerGrid &&
      listEquals(_flat, other._flat) &&
      _sameShape(other);

  List<AnswerChoice> get _flat => [for (final column in columns) ...column];

  bool _sameShape(AnswerGrid other) => listEquals(
    columns.map((c) => c.length).toList(),
    other.columns.map((c) => c.length).toList(),
  );

  @override
  int get hashCode => Object.hash(
    Object.hashAll(_flat),
    Object.hashAll(columns.map((c) => c.length)),
  );
}
