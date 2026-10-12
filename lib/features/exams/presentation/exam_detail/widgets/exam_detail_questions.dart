part of '../exam_detail_view.dart';

/// What the Sorular tab selects: the section's state, the questions and the
/// filter.
typedef _QuestionsData = (SectionState, ExamQuestionsModel?, QuestionFilter);

/// The Sorular tab (pano 5.4, 5.9 kare 2): the counted filter, then one
/// accordion per test holding a 5-column grid of question cells. Only the
/// result is needed, so the tab has no request of its own; a result without
/// questions says "Bu deneme için soru ayrıntısı yok." (pano 5.8).
class _QuestionsTab
    extends SelectorViewModelWidget<ExamDetailViewModel, _QuestionsData> {
  const _QuestionsTab();

  @override
  _QuestionsData selector(ExamDetailViewModel viewModel) =>
      (viewModel.screenState, viewModel.questions, viewModel.filter);

  @override
  Widget build(BuildContext context, _QuestionsData data) {
    final (_, model, filter) = data;
    final l10n = AppLocalizations.of(context);
    if (model == null) return const _CardSkeleton();
    if (model.isEmpty) {
      return _SectionEmpty(message: l10n.examDetail_questionsEmpty);
    }
    final tests = model.filtered(filter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterSegment(model: model, filter: filter),
        const SizedBox(height: _sectionGap),
        if (tests.isEmpty)
          _FilterEmptyCard(filter: filter, total: model.total)
        else
          for (final (i, test) in tests.indexed) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            _TestAccordion(
              key: ValueKey(test.index),
              test: test,
              filter: filter,
              initiallyExpanded: i == 0,
            ),
          ],
      ],
    );
  }
}

/// The counted segment (C04; pano 5.4 "Soru süzgeci"): "Tümü · 160 soru",
/// "Yanlışlar · 74 yanlış", "Boşlar · boş yok".
class _FilterSegment extends StatelessWidget {
  const _FilterSegment({required this.model, required this.filter});

  final ExamQuestionsModel model;
  final QuestionFilter filter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final wrong = model.wrong;
    final blank = model.blank;
    return Semantics(
      container: true,
      label: l10n.examDetail_filterA11y,
      child: AppSegmented<QuestionFilter>(
        value: filter,
        onChanged: viewModel.selectFilter,
        segments: [
          AppSegment(
            value: QuestionFilter.all,
            label: l10n.examDetail_filterAll,
            counter: l10n.exams_questionCount(model.total),
          ),
          AppSegment(
            value: QuestionFilter.wrong,
            label: l10n.examDetail_filterWrong,
            counter: wrong > 0
                ? l10n.examDetail_counterWrong(TrFormat.sira(wrong))
                : l10n.examDetail_counterNoWrong,
          ),
          AppSegment(
            value: QuestionFilter.blank,
            label: l10n.examDetail_filterBlank,
            counter: blank > 0
                ? l10n.examDetail_counterBlank(TrFormat.sira(blank))
                : l10n.examDetail_counterNoBlank,
          ),
        ],
      ),
    );
  }
}

/// One test (C50 `Accordion`; pano 5.4): the full name, the lettered counter
/// and "40 soru" under it, a plain caret at the right; open it holds the
/// grid (padding 0 / 8 / 8, 6 between cells).
class _TestAccordion extends StatelessWidget {
  const _TestAccordion({
    required this.test,
    required this.filter,
    required this.initiallyExpanded,
    super.key,
  });

  final TestQuestions test;
  final QuestionFilter filter;
  final bool initiallyExpanded;

  /// Header padding (pano 5.4: 12 12 12 16).
  static const EdgeInsets _headerPadding = EdgeInsets.fromLTRB(
    AppSpacing.s16,
    AppSpacing.s12,
    AppSpacing.s12,
    AppSpacing.s12,
  );

  /// Grid padding (pano 5.4: 0 8 8).
  static const EdgeInsets _bodyPadding = EdgeInsets.fromLTRB(
    AppSpacing.s8,
    0,
    AppSpacing.s8,
    AppSpacing.s8,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return AppAccordion(
      title: examTestName(l10n, test.label, test.index),
      indicator: AppAccordionIndicator.plain,
      initiallyExpanded: initiallyExpanded,
      headerPadding: _headerPadding,
      bodyPadding: _bodyPadding,
      // One reading for the header: "23 doğru, 17 yanlış, 0 boş, 40 soru".
      summaryLabel: [
        l10n.exams_dybA11y(
          test.counts.correct,
          test.counts.wrong,
          test.counts.blank,
        ),
        l10n.exams_questionCount(test.questionCount),
      ].join(', '),
      summary: Wrap(
        spacing: AppSpacing.s12,
        runSpacing: AppSpacing.s4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DybCounter(counts: test.counts),
          Text(
            l10n.exams_questionCount(test.questionCount),
            style: context.appText.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
      child: _QuestionGrid(
        testIndex: test.index,
        questions: test.questions,
        filter: filter,
      ),
    );
  }
}

/// The 5-column grid of a test (pano 5.4): 76 high cells, 6 apart. A change of
/// the filter cross-fades the grid in 150 ms.
class _QuestionGrid extends StatelessWidget {
  const _QuestionGrid({
    required this.testIndex,
    required this.questions,
    required this.filter,
  });

  final int testIndex;
  final List<QuestionResult> questions;
  final QuestionFilter filter;

  @override
  Widget build(BuildContext context) {
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return AnimatedSwitcher(
      duration: context.motion(AppMotion.fast, reduced: AppMotion.reducedFade),
      child: GridView.builder(
        key: ValueKey(filter),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: QuestionCell.gridDelegate(context),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionCell.result(
            key: ValueKey(question.order),
            number: question.order,
            outcome: question.outcome,
            marked: question.markedOption,
            correctAnswer: question.correctOption,
            onTap: () => viewModel.openQuestion(
              testIndex: testIndex,
              questionOrder: question.order,
            ),
          );
        },
      ),
    );
  }
}

/// The section's empty card of a filter with no question (pano 5.4 kare 3):
/// a 32 pt chip, "Boş bıraktığın soru yok", "Bu denemedeki 160 sorunun hepsini
/// işaretledin." and the text button "Tüm Soruları Göster". The wrong filter
/// has the same card with its own words.
class _FilterEmptyCard extends StatelessWidget {
  const _FilterEmptyCard({required this.filter, required this.total});

  final QuestionFilter filter;
  final int total;

  /// Edge of the chip and of its glyph (pano 5.4: 32, glyph 18).
  static const double _chip = 32;
  static const double _glyph = 18;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final blank = filter == QuestionFilter.blank;
    final count = TrFormat.sira(total);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s24,
        vertical: 28,
      ),
      child: Semantics(
        container: true,
        liveRegion: true,
        child: Column(
          children: [
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: blank ? colors.dybBlank : colors.dybCorrect,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: _chip,
                  child: Center(
                    child: PhosphorIcon(
                      blank ? PhosphorIconsBold.minus : PhosphorIconsBold.check,
                      size: _glyph,
                      color: colors.dybOn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s12),
            Semantics(
              header: true,
              child: Text(
                blank
                    ? l10n.examDetail_noBlankTitle
                    : l10n.examDetail_noWrongTitle,
                textAlign: TextAlign.center,
                style: text.bodyStrong.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s4),
            Text(
              blank
                  ? l10n.examDetail_noBlankBody(count)
                  : l10n.examDetail_noWrongBody(count),
              textAlign: TextAlign.center,
              style: text.caption.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s8),
            AppButton(
              label: l10n.examDetail_showAllQuestions,
              variant: AppButtonVariant.text,
              onPressed: () => viewModel.selectFilter(QuestionFilter.all),
            ),
          ],
        ),
      ),
    );
  }
}
