import 'package:smap/core/utils/turkish_text.dart';

/// What a question of an exam came out as (C43 `QuestionCell`, `result`
/// variant). Three states, never more: the cell color, the status chip and
/// the reading all follow it.
enum QuestionOutcome {
  /// Doğru: the marked option is the right one.
  correct,

  /// Yanlış: an option was marked, and it is not the right one.
  wrong,

  /// Boş: nothing was marked.
  blank;

  /// Works out the outcome from the letters.
  ///
  /// Nothing marked (null, empty or spaces) is [blank], whatever the key is.
  /// Otherwise the letters are compared ignoring case and surrounding spaces
  /// (through `TurkishText.fold`, so a stray Turkish capital cannot make a
  /// right answer wrong): equal is [correct], different is [wrong].
  static QuestionOutcome resolve({
    required String? marked,
    required String correct,
  }) {
    final given = marked?.trim() ?? '';
    if (given.isEmpty) return QuestionOutcome.blank;
    return TurkishText.fold(given) == TurkishText.fold(correct.trim())
        ? QuestionOutcome.correct
        : QuestionOutcome.wrong;
  }

  /// Whether the cell tells the right answer under the mark ("Doğru A"):
  /// only for a wrong or blank question; a right one keeps the room empty.
  bool get showsCorrectAnswer => this != QuestionOutcome.correct;
}

/// What a cell of the form check shows (C43 `QuestionCell`, `formCheck`
/// variant; screen 4.7).
enum FormCheckStatus {
  /// Okundu: the reader found a mark.
  read,

  /// Boş okundu: the reader saw no mark; the student is asked to check it.
  blankRead,

  /// Düzeltildi: the student replaced the reading.
  corrected;

  /// Works out the status from the reading and the student's correction. A
  /// non-empty [correction] wins; an empty [read] is [blankRead].
  static FormCheckStatus resolve({String? read, String? correction}) {
    if ((correction?.trim() ?? '').isNotEmpty) return FormCheckStatus.corrected;
    if ((read?.trim() ?? '').isEmpty) return FormCheckStatus.blankRead;
    return FormCheckStatus.read;
  }

  /// The letter the cell shows for this status, or null for the blank-read
  /// dash: the correction when corrected, the reading otherwise.
  static String? markOf({String? read, String? correction}) {
    final fixed = correction?.trim() ?? '';
    if (fixed.isNotEmpty) return fixed;
    final reading = read?.trim() ?? '';
    return reading.isEmpty ? null : reading;
  }
}
