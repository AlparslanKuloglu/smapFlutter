part of '../scan_review_view.dart';

/// The top of the check (pano 4.7): Kapat (X 24 in a 48 pt target, 54 from the
/// top of the board's phone), the title "Form Kontrol" (24/32 · 700) and
/// "Okunan cevapları formunla karşılaştır." (15/24, `textSecondary`) under it,
/// 16 from the sides.
class _ReviewHeader extends ViewModelWidget<ScanReviewViewModel> {
  const _ReviewHeader();

  @override
  bool get reactive => false;

  /// The X sits 8 above the safe area edge on the board.
  static const double _lift = 8;

  @override
  Widget build(BuildContext context, ScanReviewViewModel viewModel) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final safe = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.only(top: safe > _lift ? safe - _lift : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.s4),
            child: AppIconButton(
              icon: PhosphorIconsRegular.x,
              semanticLabel: l10n.common_close,
              onPressed: () => unawaited(viewModel.exit()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.scan_reviewTitle,
                    style: text.titleLg.copyWith(color: colors.textPrimary),
                  ),
                ),
                Text(
                  l10n.scan_reviewSub,
                  style: text.body.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
        ],
      ),
    );
  }
}
