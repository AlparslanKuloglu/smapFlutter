part of '../question_detail_view.dart';

/// "Soru Analizi", the related cards and the copyright note (pano 5.7).
///
/// The explanation and the cards come from one request and have one state: a
/// skeleton while it runs, the section error with "Tekrar Dene" when it
/// failed, and otherwise the explanation (or "Bu soru için çözüm açıklaması
/// yok."), the carousel only when there is a card, and "Kartları Çalış" under
/// it for a student. The copyright note ends the screen in every state.
class _AnalysisSection
    extends
        SelectorViewModelWidget<
          QuestionDetailViewModel,
          (SectionState, SectionState, QuestionDetail?, bool)
        > {
  const _AnalysisSection();

  @override
  (SectionState, SectionState, QuestionDetail?, bool) selector(
    QuestionDetailViewModel viewModel,
  ) => (
    viewModel.screenState,
    viewModel.question.state,
    viewModel.question.data,
    viewModel.canStudyCards,
  );

  @override
  Widget build(
    BuildContext context,
    (SectionState, SectionState, QuestionDetail?, bool) data,
  ) {
    final (screen, state, detail, canStudy) = data;
    if (screen == SectionState.error || screen == SectionState.offline) {
      return _noSliver;
    }
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<QuestionDetailViewModel>(
      context,
      listen: false,
    );
    final Widget body;
    if (screen == SectionState.loading || state == SectionState.loading) {
      body = const _AnalysisSkeleton();
    } else if (detail == null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: AppErrorState.section(
          message: l10n.examDetail_questionLoadError,
          onRetry: viewModel.retryQuestion,
        ),
      );
    } else {
      body = _AnalysisContent(detail: detail, canStudy: canStudy);
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: _sectionGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [body, const _CopyrightNote()],
        ),
      ),
    );
  }
}

/// The explanation, the cards and the button.
class _AnalysisContent extends StatelessWidget {
  const _AnalysisContent({required this.detail, required this.canStudy});

  final QuestionDetail detail;
  final bool canStudy;

  /// Gap between the explanation and the cards heading (pano 5.7: 410 → 430).
  static const double _cardsGap = AppSpacing.s24;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<QuestionDetailViewModel>(
      context,
      listen: false,
    );
    final explanation = detail.description?.trim() ?? '';
    final cards = detail.cards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.examDetail_analysisTitle,
                  style: text.headline.copyWith(color: colors.textPrimary),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                explanation.isEmpty
                    ? l10n.examDetail_analysisEmpty
                    : explanation,
                style: explanation.isEmpty
                    ? text.body.copyWith(color: colors.textSecondary)
                    : text.body.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
        if (cards.isNotEmpty) ...[
          const SizedBox(height: _cardsGap),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.examDetail_relatedCards,
                      style: text.headline.copyWith(color: colors.textPrimary),
                    ),
                  ),
                ),
                Text(
                  l10n.examDetail_relatedCount(TrFormat.sira(cards.length)),
                  style: text.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          _CardCarousel(cards: cards),
          if (canStudy) ...[
            const SizedBox(height: _sectionGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.gutter,
              ),
              child: AppButton(
                label: l10n.examDetail_studyCards,
                expand: true,
                onPressed: viewModel.studyCards,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// The related cards in a row that scrolls sideways (pano 5.7: left 16, 8
/// between, 264 wide, padding 16; the second card runs off the edge so the
/// row reads as scrollable). The cards are as high as the tallest one.
class _CardCarousel extends StatelessWidget {
  const _CardCarousel({required this.cards});

  final List<QuestionTopicCard> cards;

  /// Width of a card (pano 5.7).
  static const double _cardWidth = 264;

  /// Lines of a card's text before it is cut (the sheet has all of it).
  static const int _previewLines = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<QuestionDetailViewModel>(
      context,
      listen: false,
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: AppSpacing.gutter),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, card) in cards.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s8),
              SizedBox(
                width: _cardWidth,
                child: AppCard(
                  onTap: () => viewModel.openCard(card),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.title,
                        style: text.headline.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      if (card.text.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          card.text,
                          maxLines: _previewLines,
                          overflow: TextOverflow.ellipsis,
                          style: text.body.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.gutter),
          ],
        ),
      ),
    );
  }
}

/// "Sorunun fotoğrafı telif hakları nedeniyle paylaşılamıyor." (pano 5.7): an
/// Image icon 20 in `textSecondary` and the note 13/20, 10 apart; 24 above.
class _CopyrightNote extends StatelessWidget {
  const _CopyrightNote();

  /// Gap above the note and between its icon and text (pano 5.7).
  static const double _above = AppSpacing.s24;
  static const double _iconGap = 10;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        _above,
        AppSpacing.gutter,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: PhosphorIcon(
              PhosphorIconsRegular.image,
              size: 20,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: _iconGap),
          Expanded(
            child: Text(
              AppLocalizations.of(context).examDetail_copyrightNote,
              style: context.appText.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
