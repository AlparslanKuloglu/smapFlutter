part of '../register_view.dart';

typedef _SubmitData = (bool, SectionState, RegisterNotice?);

/// What is under the consent line: the notice of a failed submit, "Kayıt Ol"
/// and "Hesabın var mı? Giriş Yap" (pano 2.5 kare 2; the closed button with
/// "Metinler yüklenince kayıt açılır." pano 2.6 kare 3).
class _SubmitSection
    extends SelectorViewModelWidget<RegisterViewModel, _SubmitData> {
  const _SubmitSection();

  @override
  _SubmitData selector(RegisterViewModel viewModel) =>
      (viewModel.submitting, viewModel.legal.state, viewModel.notice);

  @override
  Widget build(BuildContext context, _SubmitData data) {
    final (submitting, legal, notice) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    final closed = legal == SectionState.error || legal == SectionState.offline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (notice != null) ...[
          AppNoticeBox(
            tone: AppNoticeTone.error,
            message: registerNoticeText(l10n, notice),
            actionLabel: notice.kind == RegisterNoticeKind.signInFailed
                ? l10n.register_signInFailedAction
                : null,
            onAction: viewModel.openLogin,
          ),
          const SizedBox(height: _registerFieldGap),
        ],
        AppButton(
          label: l10n.register_submit,
          expand: true,
          loading: submitting,
          onPressed: legal == SectionState.ready ? viewModel.submit : null,
          disabledReason: closed ? l10n.register_legalRegisterLocked : null,
        ),
        const SizedBox(height: _registerLoginGap),
        const _LoginRow(),
      ],
    );
  }
}

/// The gap above the sign-in row: the 20 between sections pulled up by 8
/// (pano 2.5 "üst boşluk -8").
const double _registerLoginGap = _registerFieldGap - AppSpacing.s8;

/// "Hesabın var mı?" and the text button "Giriş Yap" (pano 2.5 kare 2).
class _LoginRow extends StatelessWidget {
  const _LoginRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            l10n.register_hasAccount,
            style: context.appText.body.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ),
        AppButton(
          label: l10n.register_loginLink,
          variant: AppButtonVariant.text,
          size: AppButtonSize.md40,
          onPressed: viewModel.openLogin,
        ),
      ],
    );
  }
}
