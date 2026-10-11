part of '../register_view.dart';

/// The role segment "Öğrenci" | "Öğrenci Koçu" (pano 2.5 kare 1; 2.5 kare 3
/// for the coach). It sits in the content under the large title and, once the
/// title has scrolled away, stays pinned under the bar with a 1 pt
/// `borderSubtle` rule below it ("Rol segmenti sabit kalır", padding
/// 0 24 12).
class _RoleBar extends SelectorViewModelWidget<RegisterViewModel, UserRole> {
  const _RoleBar();

  @override
  UserRole selector(RegisterViewModel viewModel) => viewModel.role;

  @override
  Widget build(BuildContext context, UserRole role) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return ValueListenableBuilder<bool>(
      valueListenable: scope.roleStuck,
      builder: (context, stuck, child) => DecoratedBox(
        decoration: BoxDecoration(
          color: colors.bgCanvas,
          border: Border(
            bottom: BorderSide(
              color: stuck ? colors.borderSubtle : colors.bgCanvas,
            ),
          ),
        ),
        child: child,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _registerGutter,
          0,
          _registerGutter,
          AppSpacing.s12,
        ),
        child: AppSegmented<UserRole>(
          value: role,
          onChanged: viewModel.setRole,
          segments: [
            AppSegment(
              value: UserRole.student,
              label: l10n.register_roleStudent,
            ),
            AppSegment(value: UserRole.coach, label: l10n.register_roleCoach),
          ],
        ),
      ),
    );
  }
}
