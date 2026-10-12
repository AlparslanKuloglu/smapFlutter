part of '../result_moment_view.dart';

/// What the cards row selects: the screen state and the card count.
typedef _CardsData = (SectionState, int?);

/// The row "Bu denemeden 23 bilgi kartı eklendi" (pano 5.1 kare 1): a card
/// button, at least 64 high, 12 / 16 padding, 12 between a 40 pt `infoBg`
/// circle with the Cards icon, the text 15/24 · 600 and a CaretRight 20. It
/// opens Deneme Detay on its Kartlar tab. Not drawn when the count is unknown
/// or zero (kare 2: no card count in the data, no row).
class _MomentCardsSection
    extends SelectorViewModelWidget<ResultMomentViewModel, _CardsData> {
  const _MomentCardsSection();

  @override
  _CardsData selector(ResultMomentViewModel viewModel) =>
      (viewModel.screenState, viewModel.cardTotal);

  @override
  Widget build(BuildContext context, _CardsData data) {
    final (state, total) = data;
    if (state != SectionState.ready || total == null) return _noSliver;
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.s24,
          AppSpacing.gutter,
          0,
        ),
        child: _CardsRow(total: total, onTap: viewModel.openCards),
      ),
    );
  }
}

class _CardsRow extends StatelessWidget {
  const _CardsRow({required this.total, required this.onTap});

  final int total;
  final VoidCallback onTap;

  /// Row height floor, the circle and its icon, the caret (pano 5.1: 64, 40,
  /// 22, 20).
  static const double _minHeight = 64;
  static const double _circle = 40;
  static const double _icon = 22;
  static const double _caret = 20;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final label = AppLocalizations.of(
      context,
    ).resultMoment_cards(TrFormat.sira(total));
    return AppCard(
      onTap: onTap,
      semanticLabel: label,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s12,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: _minHeight - 2 * AppSpacing.s12,
        ),
        child: Row(
          children: [
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.infoBg,
                  shape: BoxShape.circle,
                ),
                child: SizedBox.square(
                  dimension: _circle,
                  child: Center(
                    child: PhosphorIcon(
                      PhosphorIconsRegular.cards,
                      size: _icon,
                      color: colors.info,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                label,
                style: text.bodyStrong.copyWith(color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            ExcludeSemantics(
              child: PhosphorIcon(
                PhosphorIconsRegular.caretRight,
                size: _caret,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
