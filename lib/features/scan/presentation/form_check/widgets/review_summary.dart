part of '../scan_review_view.dart';

typedef _SummaryData = ({int read, int blank, int corrections});

/// The summary line (pano 4.7): "160 cevap okundu" (16/24 · 700), a 20 pt grey
/// disc with a dash and "2 boş", and, once there are corrections, a pencil in
/// `primary` with "2 düzeltme" (16 apart, 16 from the sides). The counts are
/// of what the grid shows: a blank that was corrected is no longer blank.
class _ReviewSummary
    extends SelectorViewModelWidget<ScanReviewViewModel, _SummaryData> {
  const _ReviewSummary();

  @override
  _SummaryData selector(ScanReviewViewModel viewModel) => (
    read: viewModel.model.readCount,
    blank: viewModel.model.blankCount,
    corrections: viewModel.model.correctionCount,
  );

  static const double _disc = 20;
  static const double _glyph = 12;
  static const double _pencil = 18;

  @override
  Widget build(BuildContext context, _SummaryData data) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final readLabel = l10n.scan_answersRead(TrFormat.sira(data.read));
    final blankLabel = l10n.scan_blankCount(TrFormat.sira(data.blank));
    final fixLabel = l10n.scan_correctionCount(TrFormat.sira(data.corrections));
    final strong = text.bodyLg.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final plain = text.bodyLg.copyWith(color: colors.textPrimary);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        0,
      ),
      child: Semantics(
        container: true,
        liveRegion: true,
        label: [
          readLabel,
          blankLabel,
          if (data.corrections > 0) fixLabel,
        ].join(', '),
        excludeSemantics: true,
        child: Wrap(
          spacing: AppSpacing.s16,
          runSpacing: AppSpacing.s8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(readLabel, style: strong),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.dybBlank,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox.square(
                    dimension: _disc,
                    child: Center(
                      child: PhosphorIcon(
                        PhosphorIconsBold.minus,
                        size: _glyph,
                        color: colors.dybOn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Text(blankLabel, style: plain),
              ],
            ),
            if (data.corrections > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PhosphorIcon(
                    PhosphorIconsRegular.pencilSimple,
                    size: _pencil,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  Text(fixLabel, style: plain),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
