part of '../card_deck_view.dart';

/// The bar: Back, and the title once the one under it has scrolled away.
class _DeckBar
    extends SelectorViewModelWidget<CardDeckViewModel, DeckHeaderData> {
  const _DeckBar();

  @override
  DeckHeaderData selector(CardDeckViewModel viewModel) => viewModel.header;

  @override
  Widget build(BuildContext context, DeckHeaderData data) =>
      AppDetailBar(title: _deckTitle(AppLocalizations.of(context), data));
}

/// The large title (pano 8.1 y=102: "Tarih Kartları" 24/32 · 700).
class _DeckTitle
    extends SelectorViewModelWidget<CardDeckViewModel, DeckHeaderData> {
  const _DeckTitle();

  @override
  DeckHeaderData selector(CardDeckViewModel viewModel) => viewModel.header;

  @override
  Widget build(BuildContext context, DeckHeaderData data) =>
      LargeTitleSliver(title: _deckTitle(AppLocalizations.of(context), data));
}

/// The segment under the title (pano 8.1 y=150): "Eksiklerim · 23 kart",
/// "Bildiklerim · 41 kart", "Favorilerim · 6 kart"; an empty group says "kart
/// yok". It is drawn once the cards are known, and only with cards.
class _DeckSegments
    extends SelectorViewModelWidget<CardDeckViewModel, DeckSegmentData> {
  const _DeckSegments();

  @override
  DeckSegmentData selector(CardDeckViewModel viewModel) => viewModel.segments;

  @override
  Widget build(BuildContext context, DeckSegmentData data) {
    if (!data.visible) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<CardDeckViewModel>(
      context,
      listen: false,
    );
    String counter(int count) => count == 0
        ? l10n.cardDeck_countNone
        : l10n.cardDeck_count(TrFormat.sira(count));
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        child: AppSegmented<DeckGroup>(
          value: data.group,
          onChanged: viewModel.selectGroup,
          segments: [
            AppSegment(
              value: DeckGroup.missing,
              label: l10n.cardDeck_groupMissing,
              counter: counter(data.counts.missing),
            ),
            AppSegment(
              value: DeckGroup.known,
              label: l10n.cardDeck_groupKnown,
              counter: counter(data.counts.known),
            ),
            AppSegment(
              value: DeckGroup.favorite,
              label: l10n.cardDeck_groupFavorite,
              counter: counter(data.counts.favorite),
            ),
          ],
        ),
      ),
    );
  }
}

/// The session progress (pano 8.1 y=222): the orange bar and "12/23". Drawn
/// only while a card is on top.
class _DeckProgress
    extends SelectorViewModelWidget<CardDeckViewModel, DeckProgressData> {
  const _DeckProgress();

  @override
  DeckProgressData selector(CardDeckViewModel viewModel) => viewModel.progress;

  @override
  Widget build(BuildContext context, DeckProgressData data) {
    if (!data.visible) return _noSliver;
    final l10n = AppLocalizations.of(context);
    final position = TrFormat.sira(data.position);
    final total = TrFormat.sira(data.total);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s16,
          AppSpacing.gutter,
          0,
        ),
        child: AppSessionProgress(
          value: data.position,
          total: data.total,
          counter: l10n.cardDeck_progress(position, total),
          semanticLabel: l10n.cardDeck_progressA11y(position, total),
        ),
      ),
    );
  }
}
