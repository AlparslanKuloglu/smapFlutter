part of 'question_cell.dart';

/// The face of a result cell: fill by status, number, chip, mark and the
/// right answer.
class _ResultCell extends StatelessWidget {
  const _ResultCell({
    required this.number,
    required this.outcome,
    required this.marked,
    required this.correctAnswer,
    required this.pressed,
  });

  final int number;
  final QuestionOutcome outcome;
  final String? marked;
  final String? correctAnswer;
  final bool pressed;

  /// How far a pressed wrong or blank cell moves toward its chip color
  /// (pano 5.4: `#FCEAEA` becomes `#F6D7D7`).
  static const double _pressedTint = 0.1;

  /// The "Doğru A" line, in points before the text scale.
  static const double _keyLine = 16;

  /// Side and top padding of the cell content.
  static const double _padding = 6;

  /// Distance of the status chip from the right edge, and from the top edge
  /// once the 6 pt cell padding is counted (8 - 6 = 2).
  static const double _chipInset = AppSpacing.s8;
  static const double _chipTopLift = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final (fill, kind, pressedTarget, pressedAmount) = switch (outcome) {
      QuestionOutcome.correct => (
        colors.bgSurface,
        DybKind.correct,
        colors.bgSunken,
        0.5,
      ),
      QuestionOutcome.wrong => (
        colors.dybWrongBg,
        DybKind.wrong,
        colors.dybWrong,
        _pressedTint,
      ),
      QuestionOutcome.blank => (
        colors.dybBlankBg,
        DybKind.blank,
        colors.dybBlank,
        _pressedTint,
      ),
    };
    final background = pressed
        ? Color.lerp(fill, pressedTarget, pressedAmount)!
        : fill;
    final letter = marked?.trim() ?? '';
    final key = correctAnswer?.trim() ?? '';
    final showKey = outcome.showsCorrectAnswer && key.isNotEmpty;
    final markStyle = text.titleMd.copyWith(
      color: letter.isEmpty ? colors.textSecondary : colors.textPrimary,
      height: 24 / 20,
      letterSpacing: 0,
    );
    final small = text.caption.copyWith(
      fontWeight: FontWeight.w600,
      height: 16 / 13,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderSm,
        border: outcome == QuestionOutcome.correct
            ? Border.all(color: colors.borderSubtle)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s8,
          _padding,
          _chipInset,
          _padding,
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$number',
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(top: _chipTopLift),
                  child: DybGlyph(kind: kind),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Text(
                  letter.isEmpty ? QuestionCell.blankMark : letter,
                  style: markStyle,
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.textScalerOf(context).scale(_keyLine),
              child: showKey
                  ? Text(
                      l10n.exams_correctAnswer(key),
                      maxLines: 1,
                      style: small.copyWith(color: colors.dybCorrect),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
