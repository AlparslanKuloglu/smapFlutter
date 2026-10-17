part of '../card_deck_view.dart';

/// The skeleton of the deck screen while the cards load (15 s at most): the
/// segment, the progress line, a card and the two buttons.
class _DeckSkeleton extends StatelessWidget {
  const _DeckSkeleton();

  /// Heights of the pieces (pano 8.1: segment 56, bar, card 392, buttons 48).
  static const double _segment = 56;
  static const double _card = InfoCardFace.defaultMinHeight;

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        child: AppSkeleton(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SkeletonBox(height: _segment, radius: 12),
              SizedBox(height: AppSpacing.s16),
              SkeletonBox(height: 8),
              SizedBox(height: AppSpacing.s16),
              SkeletonBox(height: _card, radius: 24),
              SizedBox(height: AppSpacing.s24),
              SkeletonBox(height: AppSpacing.touch, radius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// The cards did not load: the screen-level error with "Tekrar Dene". Back is
/// always there, in the bar.
class _DeckError extends StatelessWidget {
  const _DeckError();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CardDeckViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: AppErrorState.screen(
        title: l10n.cardDeck_errorTitle,
        message: l10n.cardDeck_errorMessage,
        onRetry: viewModel.retry,
      ),
    );
  }
}

/// A deck with no card to show (pano 8.1 kare 4 and "Boş metinler"):
///
/// - Eksiklerim with every card learned: the clay picture, M 128 (the
///   lesson's own picture in a lesson deck, Harita in an exam's deck; none
///   for a lesson without one), "Bu derste
///   eksik kartın kalmadı.", "Bildiklerim'deki 64 kartı tekrar etmek istersen
///   oradan devam edebilirsin." and the text button "Bildiklerime Geç" (12
///   under the sentence);
/// - Bildiklerim: "Henüz öğrendiğin kart yok."; Favorilerim: "Favoriye
///   eklediğin kart yok." (one sentence in a card);
/// - no card anywhere: "Bu derste henüz kartın yok." and what fills it.
class _DeckEmpty extends StatelessWidget {
  const _DeckEmpty({required this.data});

  final DeckStageData data;

  /// Space above the picture (pano 8.1 kare 4: y=260, 54 under the segment).
  static const double _top = AppSpacing.s48;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (data.empty) {
      DeckEmptyKind.missingDone => _MissingDone(data: data),
      DeckEmptyKind.known => _sectionNote(l10n.cardDeck_knownEmpty),
      DeckEmptyKind.favorite => _sectionNote(l10n.cardDeck_favoriteEmpty),
      DeckEmptyKind.noCards || null => SliverToBoxAdapter(
        child: AppEmptyState.screen(
          title: data.isExam
              ? l10n.cardDeck_noCardsTitleExam
              : l10n.cardDeck_noCardsTitle,
          message: l10n.cardDeck_noCardsMessage,
          topPadding: _top,
        ),
      ),
    };
  }

  static Widget _sectionNote(String message) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      AppSpacing.s16,
      AppSpacing.gutter,
      0,
    ),
    sliver: SliverToBoxAdapter(child: AppEmptyState.section(message: message)),
  );
}

/// The empty Eksiklerim (pano 8.1 kare 4).
class _MissingDone extends StatelessWidget {
  const _MissingDone({required this.data});

  final DeckStageData data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CardDeckViewModel>(
      context,
      listen: false,
    );
    final known = data.knownCount;
    return SliverToBoxAdapter(
      child: Column(
        children: [
          AppEmptyState.screen(
            title: data.isExam
                ? l10n.cardDeck_missingDoneTitleExam
                : l10n.cardDeck_missingDoneTitle,
            message: known > 0
                ? l10n.cardDeck_missingDoneMessage(TrFormat.sira(known))
                : l10n.cardDeck_noCardsMessage,
            topPadding: _DeckEmpty._top,
            illustration: switch (data.picture) {
              final picture? => AppClay.medium(picture),
              null => null,
            },
          ),
          if (known > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s12),
              child: AppButton(
                label: l10n.cardDeck_goKnown,
                variant: AppButtonVariant.text,
                onPressed: viewModel.openKnown,
              ),
            ),
        ],
      ),
    );
  }
}
