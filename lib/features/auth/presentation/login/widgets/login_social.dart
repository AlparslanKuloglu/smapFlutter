part of '../login_view.dart';

/// "Apple ile Devam Et" and "Google ile Devam Et" with the divider "ya da
/// kullanıcı adınla" (pano 2.3 kare 4; D-17), above the user name.
///
/// Drawn only while `FeatureFlags.socialLoginEnabled` is on. Two equal outline
/// buttons 12 apart; the official logo assets are not in the project yet (spec
/// §6.5 #3), so the buttons carry the text alone. They have no action yet:
/// the flag must stay closed until the sign-in with Apple and Google is wired
/// (`google_sign_in` is a dependency, the Apple package and the server
/// endpoint are not there; spec §4.A "2.3" "Veri").
class _LoginSocial extends StatelessWidget {
  const _LoginSocial();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.login_apple,
          variant: AppButtonVariant.outline,
          expand: true,
          onPressed: null,
        ),
        const SizedBox(height: AppSpacing.s12),
        AppButton(
          label: l10n.login_google,
          variant: AppButtonVariant.outline,
          expand: true,
          onPressed: null,
        ),
        const SizedBox(height: _formGap),
        const _OrUsernameDivider(),
      ],
    );
  }
}

/// The hair lines with "ya da kullanıcı adınla" in the middle (pano 2.3
/// kare 4: 13/20 · 600, secondary color).
class _OrUsernameDivider extends StatelessWidget {
  const _OrUsernameDivider();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final line = Expanded(
      child: SizedBox(height: 1, child: ColoredBox(color: colors.borderSubtle)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
          child: Text(
            AppLocalizations.of(context).login_orUsername,
            style: context.appText.labelMd.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
