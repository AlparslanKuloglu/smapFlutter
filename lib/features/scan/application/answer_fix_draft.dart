import 'package:flutter/foundation.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

/// The state of the fix sheet's form: which column and question the student
/// is looking at and which mark they picked (pano 4.7 kare 2 and 3).
///
/// Immutable; every change returns a new draft. Changing the column or the
/// question forgets the picked mark: it belonged to another cell.
@immutable
class AnswerFixDraft {
  const AnswerFixDraft({
    required this.grid,
    this.column = 1,
    this.question = 1,
    this.choice,
  });

  /// A draft that points at [cell] with no mark picked (the student tapped
  /// a cell of the grid: "kolon ve soru dolu gelir; yalnız şık seçilir").
  factory AnswerFixDraft.at(AnswerGrid grid, AnswerCell cell) => AnswerFixDraft(
    grid: grid,
    column: cell.column.clamp(1, grid.columnCount),
    question: cell.question.clamp(
      1,
      grid.questionCount(cell.column.clamp(1, grid.columnCount)),
    ),
  );

  final AnswerGrid grid;
  final int column;
  final int question;

  /// The mark the student picked; `null` until they do.
  final AnswerChoice? choice;

  /// The cell the draft points at.
  AnswerCell get cell => AnswerCell(column, question);

  /// What the reader found in that cell ("Okunan").
  AnswerChoice get read => grid.at(column, question);

  /// Questions in the picked column.
  int get questionCount => grid.questionCount(column);

  /// Whether "Düzeltmeyi Ekle" may be pressed: a mark is picked.
  bool get canAdd => choice != null;

  /// Whether "Önceki soru" does anything.
  bool get hasPrevious => question > 1;

  /// Whether "Sonraki soru" does anything.
  bool get hasNext => question < questionCount;

  /// Looks at [column] (1-based); the question stays when the column has it,
  /// else it moves to the column's last question.
  AnswerFixDraft withColumn(int column) {
    final next = column.clamp(1, grid.columnCount);
    return AnswerFixDraft(
      grid: grid,
      column: next,
      question: question.clamp(1, grid.questionCount(next)),
    );
  }

  /// Looks at [question] of the picked column, kept inside it.
  AnswerFixDraft withQuestion(int question) => AnswerFixDraft(
    grid: grid,
    column: column,
    question: question.clamp(1, questionCount),
  );

  /// One question up or down ([delta] -1 or 1).
  AnswerFixDraft stepped(int delta) => withQuestion(question + delta);

  /// Picks [choice]; picking the same one again takes it back.
  AnswerFixDraft withChoice(AnswerChoice choice) => AnswerFixDraft(
    grid: grid,
    column: column,
    question: question,
    choice: this.choice == choice ? null : choice,
  );

  /// The draft after the correction was added: the same cell, no mark.
  AnswerFixDraft cleared() =>
      AnswerFixDraft(grid: grid, column: column, question: question);

  /// Adds the picked mark to [corrections]; unchanged without a mark.
  AnswerCorrections addTo(AnswerCorrections corrections) {
    final picked = choice;
    if (picked == null) return corrections;
    return corrections.add(cell, read: read, to: picked);
  }

  @override
  bool operator ==(Object other) =>
      other is AnswerFixDraft &&
      other.grid == grid &&
      other.column == column &&
      other.question == question &&
      other.choice == choice;

  @override
  int get hashCode => Object.hash(grid, column, question, choice);
}
