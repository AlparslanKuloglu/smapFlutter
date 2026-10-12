part of '../result_moment_view.dart';

/// The two buttons pinned to the bottom (pano 5.1 "Eylem satırı, alta sabit,
/// aralık 12", y=778): the quiet "Anasayfa" (132 wide) and the one primary
/// "Detaylı Analiz" (the rest). The quiet button's width grows with the text
/// scale so "Anasayfa" is never clipped at 1,35. They work in every state:
/// the detail reads the result itself when the moment could not.
class _MomentActions extends StatelessWidget {
  const _MomentActions();

  /// Width of "Anasayfa" (pano 5.1: 132).
  static const double _homeWidth = 132;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ResultMomentViewModel>(
      context,
      listen: false,
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.s12,
        AppSpacing.gutter,
        MediaQuery.paddingOf(context).bottom + AppSpacing.s16,
      ),
      child: Row(
        children: [
          SizedBox(
            width: MediaQuery.textScalerOf(context).scale(_homeWidth),
            child: AppButton(
              label: l10n.resultMoment_home,
              variant: AppButtonVariant.quiet,
              expand: true,
              onPressed: viewModel.openHome,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: AppButton(
              label: l10n.resultMoment_detail,
              expand: true,
              onPressed: viewModel.openDetail,
            ),
          ),
        ],
      ),
    );
  }
}
