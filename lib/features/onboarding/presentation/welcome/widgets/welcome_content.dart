part of '../welcome_view.dart';

/// The picture, the title and the sentence, centered (pano 2.2 kare 5: the
/// picture 150 from the top, the title 28 under it, the sentence 12 under
/// that). Scrolls when the text is large.
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  /// The picture sits 150 from the top of the board's screen; 62 of that is
  /// the safe area, which the screen already skips.
  static const double _top = 88;

  /// The gap between the picture and the title.
  static const double _pictureGap = 28;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutterAuth,
        _top,
        AppSpacing.gutterAuth,
        AppSpacing.s24,
      ),
      child: Column(
        children: [
          const AppClay.large(ClayPicture.harita),
          const SizedBox(height: _pictureGap),
          Semantics(
            header: true,
            child: Text(
              l10n.onboarding_welcomeTitle,
              textAlign: TextAlign.center,
              style: text.display.copyWith(color: colors.textPrimary),
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Text(
            l10n.onboarding_welcomeBody,
            textAlign: TextAlign.center,
            style: text.bodyReading.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// "Kayıt Ol" (primary, the one the board stresses) over "Giriş Yap"
/// (outline), 12 apart.
class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = getParentViewModel<WelcomeViewModel>(context, listen: false);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.onboarding_welcomeRegister,
          expand: true,
          onPressed: vm.register,
        ),
        const SizedBox(height: AppSpacing.s12),
        AppButton(
          label: l10n.onboarding_welcomeLogin,
          variant: AppButtonVariant.outline,
          expand: true,
          onPressed: vm.login,
        ),
      ],
    );
  }
}
