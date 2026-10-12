part of '../card_deck_view.dart';

/// The deck area: the cards with their buttons, or what stands in their place
/// (the skeleton, the error, an empty state).
class _DeckStage
    extends SelectorViewModelWidget<CardDeckViewModel, DeckStageData> {
  const _DeckStage();

  @override
  DeckStageData selector(CardDeckViewModel viewModel) => viewModel.stage;

  @override
  Widget build(BuildContext context, DeckStageData data) {
    if (data.empty != null) return _DeckEmpty(data: data);
    return switch (data.state) {
      SectionState.loading => const _DeckSkeleton(),
      SectionState.error || SectionState.offline => const _DeckError(),
      SectionState.ready || SectionState.empty => _DeckCards(data: data),
    };
  }
}

/// The cards and the buttons under them (pano 8.1 kare 1 and 3).
///
/// The deck sits 16 under the progress (the front card's top at y=258); the
/// buttons sit 26 under the front card's bottom, which leaves room for the
/// edge that peeks out 12 below it.
class _DeckCards extends StatelessWidget {
  const _DeckCards({required this.data});

  final DeckStageData data;

  /// Space between the deck and the progress.
  static const double _top = AppSpacing.s16;

  /// Space between the front card's bottom edge and the buttons (pano 8.1:
  /// card to y=650, buttons from y=676).
  static const double _toButtons = 26;

  @override
  Widget build(BuildContext context) {
    final front = data.front;
    if (front == null) return _noSliver;
    final viewModel = getParentViewModel<CardDeckViewModel>(
      context,
      listen: false,
    );
    final next = data.next;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          _top,
          AppSpacing.gutter,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardDeck(
              frontKey: front.key,
              controller: viewModel.deck,
              behind: data.behind,
              canSwipe: data.canSwipe,
              onExit: viewModel.onSwiped,
              onNext: viewModel.next,
              onPrevious: viewModel.previous,
              front: (context, dragging) => _StudyFace(
                card: front,
                lessonId: viewModel.lessonId,
                dragging: dragging,
                announce: true,
                onFavoriteTap: front.canFavorite
                    ? viewModel.toggleFavorite
                    : null,
              ),
              next: next == null
                  ? null
                  : IgnorePointer(
                      child: _StudyFace(
                        card: next,
                        lessonId: viewModel.lessonId,
                      ),
                    ),
            ),
            const SizedBox(height: _toButtons),
            _DeckActions(canLearn: front.canLearn),
          ],
        ),
      ),
    );
  }
}

/// A card of the deck (C52 "StudyCard"): the shared [InfoCardFace] with the
/// lesson's name and color from the card's own lesson, or the deck's.
class _StudyFace extends StatelessWidget {
  const _StudyFace({
    required this.card,
    required this.lessonId,
    this.dragging = false,
    this.announce = false,
    this.onFavoriteTap,
  });

  final DeckCard card;
  final String? lessonId;
  final bool dragging;
  final bool announce;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final lesson = card.lessonId ?? lessonId;
    final body = card.body;
    return InfoCardFace(
      subject: DeckLessons.subjectOf(lesson),
      subjectName:
          DeckLessons.nameOf(lesson) ?? card.card.mainSubjectName ?? '',
      title: card.title,
      body: body.isEmpty ? null : body,
      isMissing: card.status == CardStatus.missing,
      isFavorite: card.isFavorite,
      onFavoriteTap: onFavoriteTap,
      dragging: dragging,
      announce: announce,
    );
  }
}

/// The buttons under the deck (pano 8.1 y=676): "Detay" (outlined, 120 wide)
/// and the primary "Öğrendim"; on a card that is not missing only "Detay".
class _DeckActions extends StatelessWidget {
  const _DeckActions({required this.canLearn});

  final bool canLearn;

  /// Width of "Detay" next to "Öğrendim" (pano 8.1 `.bo` 120).
  static const double _detailWidth = 120;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CardDeckViewModel>(
      context,
      listen: false,
    );
    final detail = AppButton(
      label: l10n.cardDeck_detail,
      variant: AppButtonVariant.outline,
      expand: true,
      onPressed: viewModel.openDetail,
    );
    if (!canLearn) return detail;
    return Row(
      children: [
        SizedBox(width: _detailWidth, child: detail),
        const SizedBox(width: AppSpacing.s12),
        Expanded(
          child: AppButton(
            label: l10n.cardDeck_learned,
            expand: true,
            onPressed: viewModel.requestLearn,
          ),
        ),
      ],
    );
  }
}
