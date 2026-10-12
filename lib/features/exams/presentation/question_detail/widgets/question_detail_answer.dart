part of '../question_detail_view.dart';

/// The answer card (pano 5.7 "Cevap kartı"): how the question came out.
///
/// With the letters (the backend does not send them yet, so the board's
/// "İşaretin C · Doğru cevap A" cannot be drawn today) the card writes both,
/// 32/40 · 800, each with its 24 pt chip; without them it writes the outcome
/// as one sentence beside the chip ("İşaretin doğru cevap." for a right
/// question). A question the result does not list has no card.
class _AnswerSection
    extends SelectorViewModelWidget<QuestionDetailViewModel, QuestionPlace?> {
  const _AnswerSection();

  @override
  QuestionPlace? selector(QuestionDetailViewModel viewModel) => viewModel.place;

  @override
  Widget build(BuildContext context, QuestionPlace? data) {
    final outcome = data?.outcome;
    if (data == null || outcome == null) return _noSliver;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _sectionGap,
        AppSpacing.gutter,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: AppCard(
          child: data.hasLetters
              ? _LetterAnswer(place: data, outcome: outcome)
              : _OutcomeAnswer(outcome: outcome),
        ),
      ),
    );
  }
}

/// The chip kind of an outcome.
DybKind _kindOf(QuestionOutcome outcome) => switch (outcome) {
  QuestionOutcome.correct => DybKind.correct,
  QuestionOutcome.wrong => DybKind.wrong,
  QuestionOutcome.blank => DybKind.blank,
};

/// The outcome as a chip and one sentence (pano 5.7 kare 2: 15/24 · 600).
class _OutcomeAnswer extends StatelessWidget {
  const _OutcomeAnswer({required this.outcome});

  final QuestionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sentence = switch (outcome) {
      QuestionOutcome.correct => l10n.examDetail_answerCorrectSentence,
      QuestionOutcome.wrong => l10n.examDetail_answerWrongSentence,
      QuestionOutcome.blank => l10n.examDetail_answerBlankSentence,
    };
    return Semantics(
      container: true,
      label: sentence,
      excludeSemantics: true,
      child: Row(
        children: [
          DybGlyph(kind: _kindOf(outcome), size: DybGlyphSize.regular),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Text(
              sentence,
              style: context.appText.bodyStrong.copyWith(
                color: context.appColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "İşaretin" and "Doğru cevap" with their letters (pano 5.7 kare 1): two
/// columns, 12 apart, the label 13 · 600 and under it, 6 below, the chip and
/// the letter 32/40 · 800 (10 apart). A blank question has no marked letter;
/// a right one has one column.
class _LetterAnswer extends StatelessWidget {
  const _LetterAnswer({required this.place, required this.outcome});

  final QuestionPlace place;
  final QuestionOutcome outcome;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final marked = place.markedOption?.trim() ?? '';
    final correct = place.correctOption?.trim() ?? '';
    final showCorrect =
        outcome != QuestionOutcome.correct && correct.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (marked.isNotEmpty)
          Expanded(
            child: _LetterColumn(
              label: l10n.examDetail_answerMarked,
              letter: marked,
              kind: _kindOf(outcome),
            ),
          ),
        if (marked.isNotEmpty && showCorrect)
          const SizedBox(width: AppSpacing.s12),
        if (showCorrect)
          Expanded(
            child: _LetterColumn(
              label: l10n.examDetail_answerCorrect,
              letter: correct,
              kind: DybKind.correct,
            ),
          ),
      ],
    );
  }
}

class _LetterColumn extends StatelessWidget {
  const _LetterColumn({
    required this.label,
    required this.letter,
    required this.kind,
  });

  final String label;
  final String letter;
  final DybKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    return Semantics(
      container: true,
      label: '$label $letter',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              DybGlyph(kind: kind, size: DybGlyphSize.regular),
              const SizedBox(width: 10),
              Text(
                letter,
                style: text.display.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
