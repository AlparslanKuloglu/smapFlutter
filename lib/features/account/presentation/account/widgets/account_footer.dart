part of '../account_view.dart';

/// The version line at the bottom of Hesap (pano 9.1 kare 2): "Sürüm 3.0.0
/// (300)", 13/20 `textSecondary`, centered. A long press copies it for a
/// support request ("Sürüm kopyalandı."). Drawn once the version is read; it
/// is never typed in.
class _AccountVersion
    extends SelectorViewModelWidget<AccountViewModel, AppVersion?> {
  const _AccountVersion();

  @override
  AppVersion? selector(AccountViewModel viewModel) => viewModel.version;

  @override
  Widget build(BuildContext context, AppVersion? version) {
    if (version == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final label = version.hasBuild
        ? l10n.account_version(version.version, version.build)
        : l10n.account_versionNoBuild(version.version);
    final viewModel = getParentViewModel<AccountViewModel>(
      context,
      listen: false,
    );
    return Semantics(
      label: label,
      hint: l10n.account_versionCopyHint,
      excludeSemantics: true,
      onLongPress: () => unawaited(viewModel.copyVersion()),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () => unawaited(viewModel.copyVersion()),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSize.touch),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.appText.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
