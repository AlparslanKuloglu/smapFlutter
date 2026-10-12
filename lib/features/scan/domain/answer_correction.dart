import 'package:flutter/foundation.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

/// A cell of the answer grid: [column] and [question], both 1-based.
@immutable
class AnswerCell {
  const AnswerCell(this.column, this.question);

  final int column;
  final int question;

  @override
  bool operator ==(Object other) =>
      other is AnswerCell &&
      other.column == column &&
      other.question == question;

  @override
  int get hashCode => Object.hash(column, question);

  @override
  String toString() => 'AnswerCell($column. kolon, $question. soru)';
}

/// What the student changed in one cell: the reading [from] and the mark of
/// the form [to] (pano 4.7 kare 3: "3. kolon · 12. soru  Boş → C").
@immutable
class AnswerCorrection {
  const AnswerCorrection({
    required this.cell,
    required this.from,
    required this.to,
  });

  final AnswerCell cell;
  final AnswerChoice from;
  final AnswerChoice to;

  @override
  bool operator ==(Object other) =>
      other is AnswerCorrection &&
      other.cell == cell &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(cell, from, to);
}

/// The corrections of one check, newest first (pano 4.7 kare 3: "satır
/// listenin başına girer").
///
/// Immutable: [add] and [remove] return a new value. A cell has at most one
/// correction; correcting it again replaces the old one, and correcting it to
/// what the reader found removes it, since nothing changed.
@immutable
class AnswerCorrections {
  const AnswerCorrections._(this.items);

  /// No correction.
  static const AnswerCorrections none = AnswerCorrections._(
    <AnswerCorrection>[],
  );

  /// The corrections, newest first.
  final List<AnswerCorrection> items;

  int get count => items.length;

  bool get isEmpty => items.isEmpty;

  /// The correction of [cell], or `null`.
  AnswerCorrection? of(AnswerCell cell) {
    for (final item in items) {
      if (item.cell == cell) return item;
    }
    return null;
  }

  /// Corrects [cell] to [to]; [read] is what the reader found there.
  AnswerCorrections add(
    AnswerCell cell, {
    required AnswerChoice read,
    required AnswerChoice to,
  }) {
    final rest = items.where((item) => item.cell != cell);
    if (to == read) return AnswerCorrections._(List.unmodifiable(rest));
    return AnswerCorrections._(
      List.unmodifiable([
        AnswerCorrection(cell: cell, from: read, to: to),
        ...rest,
      ]),
    );
  }

  /// Takes the correction of [cell] back.
  AnswerCorrections remove(AnswerCell cell) => AnswerCorrections._(
    List.unmodifiable(items.where((item) => item.cell != cell)),
  );

  /// The `edits` of the `answerArray` body, in the legacy shape
  /// `{"Kolon 3": {"12": "C"}}`: the column's name, the question's number and
  /// the option (`Boş` for no mark), oldest correction first.
  Map<String, Map<String, String>> toLegacyEdits() {
    final edits = <String, Map<String, String>>{};
    for (final item in items.reversed) {
      final column = edits.putIfAbsent('Kolon ${item.cell.column}', () => {});
      column['${item.cell.question}'] = item.to.legacyValue;
    }
    return edits;
  }

  @override
  bool operator ==(Object other) =>
      other is AnswerCorrections && listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);
}
