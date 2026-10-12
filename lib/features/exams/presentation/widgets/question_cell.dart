import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:smap/core/theme/app_radius.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/core/theme/theme_context.dart';
import 'package:smap/features/exams/application/dyb_counts.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/presentation/widgets/dyb_glyph.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/buttons/app_focus_ring.dart';
import 'package:smap/shared/ui/buttons/app_pressable.dart';

part 'question_cell_form_check.dart';
part 'question_cell_result.dart';

/// The two looks of a question cell.
enum QuestionCellVariant {
  /// A question of a finished exam (screens 5.4, 5.7).
  result,

  /// A question being checked after the optical read (screen 4.7).
  formCheck,
}

/// One question in the 5-column grid (C43 "QuestionCell"; pano 1.14 "Soru
/// hücresi"; screens 5.4 and 4.7; `SmapQuestionCell`).
///
/// **[QuestionCell.result]** is 76 pt high (it grows with the text scale) and
/// has the question number at the top left (13/20 · 600), the status chip at
/// the top right, the student's mark in the middle (20/24 · 700, a dash when
/// blank) and, only for a wrong or blank question, "Doğru A" at the bottom
/// (13/16 · 600 in `dybCorrect`; a right answer keeps the room empty so the
/// cells line up). The fill is the status: right is `bgSurface` with a 1 pt
/// inner `borderSubtle` edge, wrong is `dybWrongBg`, blank is `dybBlankBg`.
/// Pressed: 0,97 scale in 100 ms and a deeper tint. Read as "Soru 7, yanlış,
/// işaretin C, doğru cevap A"; tapping opens the question detail.
///
/// **[QuestionCell.formCheck]** is 52 pt high: the number (13/16 · 600) and
/// the mark (20/24 · 700). A read mark is white; a blank reading is `eksikBg`
/// with a 2 pt dashed `eksik` edge and a dash; a corrected cell is `infoBg`
/// with a 2 pt inner `primary` edge, the new mark in `primary` and a 14 pt
/// pencil at the top right. Read as "12. soru, boş okundu, düzeltmek için
/// dokun" or "12. soru, düzeltildi: C"; tapping opens the correction sheet.
///
/// Both fill the width they are given; [gridDelegate] lays out the
/// 5 columns with the spacing of pano 5.4 and a row height that follows the
/// text scale.
class QuestionCell extends StatelessWidget {
  /// A cell of a finished exam. [correctAnswer] null hides the "Doğru A"
  /// line (the data has no answer key; the field is not drawn).
  const QuestionCell.result({
    required this.number,
    required QuestionOutcome outcome,
    this.marked,
    this.correctAnswer,
    this.onTap,
    super.key,
  }) : variant = QuestionCellVariant.result,
       _outcome = outcome,
       _formStatus = null;

  /// A cell of the form check; [status] says what it shows and [mark] is the
  /// letter (the correction when corrected, the reading otherwise).
  const QuestionCell.formCheck({
    required this.number,
    required FormCheckStatus status,
    this.marked,
    this.onTap,
    super.key,
  }) : variant = QuestionCellVariant.formCheck,
       correctAnswer = null,
       _outcome = null,
       _formStatus = status;

  final QuestionCellVariant variant;

  /// The question number, 1-based.
  final int number;

  /// The option the student marked ("C"); null or empty is blank.
  final String? marked;

  /// The right option ("A"), result variant only.
  final String? correctAnswer;

  /// Opens the question detail (result) or the correction sheet (formCheck).
  final VoidCallback? onTap;

  final QuestionOutcome? _outcome;
  final FormCheckStatus? _formStatus;

  /// The dash written for a blank mark.
  static const String blankMark = '–';

  /// Columns of the grid.
  static const int columns = 5;

  /// Gap between cells (pano 5.4 markup: 6; the note says 8).
  static const double gridSpacing = 6;

  /// Minimum height of a result cell.
  static const double resultHeight = 76;

  /// Minimum height of a form-check cell.
  static const double formCheckHeight = 52;

  /// The height of a result cell: 76 pt, or the room its four lines need at
  /// the current text scale.
  static double resultHeightFor(TextScaler scaler) => math.max(
    resultHeight,
    12 + scaler.scale(20) + scaler.scale(24) + scaler.scale(16),
  );

  /// The height of a form-check cell for [scaler].
  static double formCheckHeightFor(TextScaler scaler) =>
      math.max(formCheckHeight, 8 + scaler.scale(16) + scaler.scale(24));

  /// The 5-column grid of result cells, [gridSpacing] apart, each row tall
  /// enough for the text scale of [context].
  static SliverGridDelegate gridDelegate(
    BuildContext context, {
    QuestionCellVariant variant = QuestionCellVariant.result,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: gridSpacing,
      crossAxisSpacing: gridSpacing,
      mainAxisExtent: variant == QuestionCellVariant.result
          ? resultHeightFor(scaler)
          : formCheckHeightFor(scaler),
    );
  }

  String _semanticLabel(AppLocalizations l10n) {
    final letter = marked?.trim() ?? '';
    final key = correctAnswer?.trim() ?? '';
    if (_outcome case final outcome?) {
      // The data may not say which option was marked: the reading then names
      // the outcome only, never "işaretin" with nothing after it.
      return switch (outcome) {
        QuestionOutcome.correct =>
          letter.isEmpty
              ? l10n.examDetail_questionCorrectNoMarkA11y(number)
              : l10n.exams_questionCorrectA11y(number, letter),
        QuestionOutcome.wrong =>
          letter.isEmpty
              ? l10n.examDetail_questionWrongNoMarkA11y(number)
              : key.isEmpty
              ? l10n.exams_questionWrongNoKeyA11y(number, letter)
              : l10n.exams_questionWrongA11y(number, letter, key),
        QuestionOutcome.blank =>
          key.isEmpty
              ? l10n.exams_questionBlankNoKeyA11y(number)
              : l10n.exams_questionBlankA11y(number, key),
      };
    }
    return switch (_formStatus!) {
      FormCheckStatus.read => l10n.exams_formCheckReadA11y(number, letter),
      FormCheckStatus.blankRead => l10n.exams_formCheckBlankA11y(number),
      FormCheckStatus.corrected => l10n.exams_formCheckCorrectedA11y(
        number,
        letter,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final isResult = variant == QuestionCellVariant.result;
    return Semantics(
      button: onTap != null,
      label: _semanticLabel(l10n),
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox(
        height: isResult ? resultHeightFor(scaler) : formCheckHeightFor(scaler),
        child: AppPressable(
          onTap: onTap,
          scale: _pressedScale,
          builder: (context, states) => AppFocusRing(
            focused: states.contains(WidgetState.focused),
            borderRadius: AppRadius.borderSm,
            child: isResult
                ? _ResultCell(
                    number: number,
                    outcome: _outcome!,
                    marked: marked,
                    correctAnswer: correctAnswer,
                    pressed: states.contains(WidgetState.pressed),
                  )
                : _FormCheckCell(
                    number: number,
                    status: _formStatus!,
                    marked: marked,
                  ),
          ),
        ),
      ),
    );
  }

  /// The pressed scale of the cell (pano 5.4: 0,97 in 100 ms).
  static const double _pressedScale = 0.97;
}
