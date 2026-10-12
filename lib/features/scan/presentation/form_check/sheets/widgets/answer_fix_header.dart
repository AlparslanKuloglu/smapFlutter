part of '../answer_fix_sheet.dart';

/// The head of the fix sheet (pano 4.7 kare 2): "Cevap
/// Düzelt" (20/28 · 700) with the correction counter under it (13/20 · 600,
/// `textSecondary`: "Düzeltme yok" or "2 düzeltme", always there) and the
/// Kapat button. Padding 12 / 24 left and 12 right, as every sheet title (the frame draws
/// the handle above it).
class _FixHeader extends StatelessWidget {
  const _FixHeader({required this.count, required this.onClose});

  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final text = context.appText;
    final l10n = AppLocalizations.of(context);
    final counter = count == 0
        ? l10n.scan_noCorrection
        : l10n.scan_correctionCount(TrFormat.sira(count));
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s24,
            AppSpacing.s12,
            AppSpacing.s12,
            0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.scan_fixSheetTitle,
                        style: text.titleMd.copyWith(color: colors.textPrimary),
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        counter,
                        style: text.caption.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppSize.touch,
                height: _closeBox,
                child: OverflowBox(
                  minHeight: AppSize.touch,
                  maxHeight: AppSize.touch,
                  child: AppIconButton(
                    icon: PhosphorIconsRegular.x,
                    semanticLabel: l10n.common_close,
                    variant: AppIconButtonVariant.close,
                    focusGapColor: colors.bgRaised,
                    onPressed: onClose,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The close button is pulled up 8 pt like every sheet's (C71).
  static const double _closeBox = 32;
}
