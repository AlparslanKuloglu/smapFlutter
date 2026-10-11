part of '../login_view.dart';

/// "Hesabın yok mu? Kayıt Ol" at the bottom of the screen (pano 2.3 kare 1 to
/// 4: 34 from the bottom, the sentence 15/24 secondary, the text button 2
/// beside it).
///
/// It takes the space the form leaves and sits at its foot; when the keyboard
/// or a large text size leaves no room it scrolls under the form instead.
class _LoginFooter extends StatelessWidget {
  const _LoginFooter();

  /// Room above the line when the form fills the screen.
  static const double _minTop = AppSpacing.s24;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            top: _minTop,
            bottom: bottom < AppSpacing.s16 ? AppSpacing.s16 : bottom,
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 2,
            children: [
              Text(
                l10n.login_noAccount,
                style: context.appText.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              AppButton(
                label: l10n.login_register,
                variant: AppButtonVariant.text,
                onPressed: getParentViewModel<LoginViewModel>(
                  context,
                  listen: false,
                ).openRegister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
