import 'package:stacked/stacked.dart';

import 'package:smap/features/scan/application/answer_fix_draft.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

/// The logic of the fix sheet "Cevap Düzelt" (pano 4.7 kare 2 and 3).
///
/// One form for the three things that identify a cell and a mark: the column
/// (a segment), the question (a stepper) and the option of the printed form
/// (A to E, "Boş"). "Düzeltmeyi Ekle" puts the correction at the head of the
/// list below (it slides in) and clears the mark for the next one; a
/// correction in the list can be taken back. The list and its count are
/// always visible. The sheet hands the corrections back when it closes,
/// however it is closed.
class AnswerFixSheetViewModel extends BaseViewModel {
  AnswerFixSheetViewModel({
    required AnswerGrid grid,
    required AnswerCorrections corrections,
    required AnswerCell start,
  }) : _draft = AnswerFixDraft.at(grid, start),
       _corrections = corrections;

  AnswerFixDraft _draft;
  AnswerCorrections _corrections;

  /// Where the form points and which mark is picked.
  AnswerFixDraft get draft => _draft;

  /// The corrections so far, newest first.
  AnswerCorrections get corrections => _corrections;

  void selectColumn(int column) {
    _draft = _draft.withColumn(column);
    notifyListeners();
  }

  /// Minus and plus of the stepper ([delta] -1 or 1).
  void step(int delta) {
    _draft = _draft.stepped(delta);
    notifyListeners();
  }

  void pick(AnswerChoice choice) {
    _draft = _draft.withChoice(choice);
    notifyListeners();
  }

  /// "Düzeltmeyi Ekle".
  void add() {
    if (!_draft.canAdd) return;
    _corrections = _draft.addTo(_corrections);
    _draft = _draft.cleared();
    notifyListeners();
  }

  /// The X of a row of the list.
  void remove(AnswerCell cell) {
    _corrections = _corrections.remove(cell);
    notifyListeners();
  }
}
