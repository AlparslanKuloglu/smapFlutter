part of '../profile_view.dart';

/// The line under the title of the open form while offline (pano 14.9 kare
/// 4): "Kaydetmek için bağlantı gerekiyor; girdiklerin korunuyor." in the 13/20
/// help type, `textSecondary`, with the gutter at the sides. "Kaydet" is off
/// for the same reason and switches on by itself when the connection returns.
/// Announced as a live region; drawn only while editing and offline.
class _ProfileOfflineNote
    extends SelectorViewModelWidget<ProfileViewModel, bool> {
  const _ProfileOfflineNote();

  @override
  bool selector(ProfileViewModel viewModel) => viewModel.showOfflineNote;

  @override
  Widget build(BuildContext context, bool show) {
    if (!show) return const SliverToBoxAdapter(child: SizedBox.shrink());
    final l10n = AppLocalizations.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.s8,
      ),
      sliver: SliverToBoxAdapter(
        child: Semantics(
          liveRegion: true,
          child: Text(
            l10n.account_profileOfflineNote,
            style: context.appText.caption.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
