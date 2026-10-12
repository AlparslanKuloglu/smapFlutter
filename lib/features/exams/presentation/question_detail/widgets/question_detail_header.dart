part of '../question_detail_view.dart';

/// The line under the title (pano 5.7: "Türk Dili ve Edebiyatı–Sosyal Bilimler 1
/// · Tarih", 13/20 · 600 `textSecondary`, wraps): the test's name and the
/// question's lesson; the lesson is left out when the form layout does not
/// cover it. Nothing while the result is not here.
class _QuestionContext
    extends SelectorViewModelWidget<QuestionDetailViewModel, QuestionPlace?> {
  const _QuestionContext();

  @override
  QuestionPlace? selector(QuestionDetailViewModel viewModel) => viewModel.place;

  @override
  Widget build(BuildContext context, QuestionPlace? data) {
    if (data == null) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final test = examTestName(l10n, data.testLabel, data.testIndex);
    final lesson = data.lessonName;
    final line = lesson == null
        ? test
        : l10n.examDetail_questionContext(test, lesson);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          2,
          AppSpacing.gutter,
          0,
        ),
        child: Text(
          line,
          style: context.appText.caption.copyWith(
            color: context.appColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
