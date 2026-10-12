import 'package:flutter/foundation.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

/// What the answer check shows: the reading with the student's corrections
/// laid over it (pano 4.7; spec §4.C 4.7).
///
/// A cell shows the correction when there is one, the reading otherwise. The
/// counts are over what is shown: a blank reading that was corrected is no
/// longer a blank ("0 boş · 2 düzeltme", pano 4.7 kare 4).
@immutable
class FormCheckModel {
  const FormCheckModel(this.grid, {this.corrections = AnswerCorrections.none});

  final AnswerGrid grid;
  final AnswerCorrections corrections;

  /// This check with [corrections] instead.
  FormCheckModel withCorrections(AnswerCorrections corrections) =>
      FormCheckModel(grid, corrections: corrections);

  /// The choice shown for [question] of [column] (1-based).
  AnswerChoice effective(int column, int question) =>
      corrections.of(AnswerCell(column, question))?.to ??
      grid.at(column, question);

  /// What the cell of the grid shows (read, blank read or corrected).
  FormCheckStatus statusOf(int column, int question) {
    if (corrections.of(AnswerCell(column, question)) != null) {
      return FormCheckStatus.corrected;
    }
    return grid.at(column, question) == AnswerChoice.blank
        ? FormCheckStatus.blankRead
        : FormCheckStatus.read;
  }

  /// The letter drawn in the cell; `null` draws the dash.
  String? markOf(int column, int question) =>
      effective(column, question).letter;

  /// "160 cevap okundu": every question of the form.
  int get readCount => grid.totalCells;

  /// Blank cells as shown, over the whole form.
  int get blankCount => [
    for (var c = 1; c <= grid.columnCount; c++) blanksIn(c),
  ].fold(0, (sum, count) => sum + count);

  /// Blank cells as shown in [column].
  int blanksIn(int column) {
    var count = 0;
    for (var q = 1; q <= grid.questionCount(column); q++) {
      if (effective(column, q) == AnswerChoice.blank) count++;
    }
    return count;
  }

  int get correctionCount => corrections.count;

  /// The first blank reading (column then question order), where the fix
  /// sheet opens from the "Düzelt" button; the first cell when nothing is
  /// blank.
  AnswerCell get firstToCheck {
    for (var c = 1; c <= grid.columnCount; c++) {
      for (var q = 1; q <= grid.questionCount(c); q++) {
        if (effective(c, q) == AnswerChoice.blank) return AnswerCell(c, q);
      }
    }
    return const AnswerCell(1, 1);
  }

  @override
  bool operator ==(Object other) =>
      other is FormCheckModel &&
      other.grid == grid &&
      other.corrections == corrections;

  @override
  int get hashCode => Object.hash(grid, corrections);
}
