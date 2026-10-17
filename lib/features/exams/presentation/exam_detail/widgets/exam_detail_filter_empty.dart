part of '../exam_detail_view.dart';

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
