part of '../exam_detail_view.dart';

/// What the Kartlar tab selects: the section and whether a coach is looking.
typedef _CardsData = (AsyncSection<ExamCardsModel>, bool);

/// The Kartlar tab (pano 5.6): "23 bilgi kartı eklendi", the primary "Kartları
/// Çalış" and the lessons the cards came from. It loads when first shown and
/// has its own skeleton, "Bu denemeden kart eklenmedi." and error with "Tekrar
/// Dene".
///
/// The answer (`getMexamItemDetail`) counts cards per lesson and does not
/// list them, so the board's card previews are not drawn: each lesson is a row
/// with its subject tile, its name and its count, and opens that lesson's
/// deck (open question to the backend, see the report).
class _CardsTab
    extends SelectorViewModelWidget<ExamDetailViewModel, _CardsData> {
  const _CardsTab();

  @override
  _CardsData selector(ExamDetailViewModel viewModel) =>
      (viewModel.cards, viewModel.isCoachView);

  @override
  Widget build(BuildContext context, _CardsData data) {
    final (section, coach) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return switch (section.state) {
      SectionState.loading => const _CardSkeleton(),
      SectionState.empty => _SectionEmpty(message: l10n.examDetail_cardsEmpty),
      SectionState.error || SectionState.offline => _SectionError(
        message: l10n.examDetail_cardsError,
        onRetry: viewModel.retryCards,
      ),
      SectionState.ready => _CardsContent(model: section.data!, coach: coach),
    };
  }
}

/// The info card, the button and the lesson rows.
class _CardsContent extends StatelessWidget {
  const _CardsContent({required this.model, required this.coach});

  final ExamCardsModel model;
  final bool coach;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CardsInfo(total: model.total),
        if (!coach && model.groups.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s12),
          AppButton(
            label: l10n.examDetail_studyCards,
            expand: true,
            onPressed: viewModel.studyCards,
          ),
        ],
        for (final group in model.groups) ...[
          const SizedBox(height: AppSpacing.s12),
          _CardGroupRow(group: group, coach: coach),
        ],
      ],
    );
  }
}

/// "23 bilgi kartı eklendi" (pano 5.6): a 40 pt `infoBg` circle with the Cards
/// icon, the title 17/24 · 700 and "Bu denemede yanlış ve boş bıraktığın
/// sorulardan."
class _CardsInfo extends StatelessWidget {
  const _CardsInfo({required this.total});

  final int total;

  /// Edge of the circle and of its icon (pano 5.6: 40, icon 22).
  static const double _circle = 40;
  static const double _icon = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return AppCard(
      child: Semantics(
        container: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.examDetail_cardsAdded(TrFormat.sira(total)),
                    style: text.headline.copyWith(color: colors.textPrimary),
                  ),
                  Text(
                    l10n.examDetail_cardsAddedBody,
                    style: text.caption.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One lesson with cards (pano 5.6 group header: the 32 pt subject tile and
/// "Tarih" 17/24 · 700), its count at the far end; it opens the lesson's deck
/// (a coach's row is static).
class _CardGroupRow extends StatelessWidget {
  const _CardGroupRow({required this.group, required this.coach});

  final ExamCardGroup group;
  final bool coach;

  /// Gap between the tile and the name (pano 5.6: 10).
  static const double _tileGap = 10;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<ExamDetailViewModel>(
      context,
      listen: false,
    );
    final count = TrFormat.sira(group.count);
    return AppCard(
      onTap: coach ? null : () => viewModel.studyLessonCards(group),
      semanticLabel: l10n.examDetail_cardGroupA11y(group.name, count),
      child: Row(
        children: [
          SubjectGlyph(subject: group.subject, size: SubjectGlyphSize.preview),
          const SizedBox(width: _tileGap),
          Expanded(
            child: Text(
              group.name,
              style: text.headline.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
          Text(
            l10n.examDetail_cardGroupCount(count),
            style: text.caption.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
