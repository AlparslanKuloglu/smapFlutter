part of '../login_view.dart';

/// What the form needs to redraw: the running sign-in, the last failure, and
/// the two counters the fields react to (a failure clears the password and
/// moves the focus; a prefill fills the user name).
typedef _FormData = ({
  bool submitting,
  AppErrorCode? failure,
  int failureCount,
  int prefillCount,
});

/// The form of "Giriş yap" (pano 2.3 kare 1 to 4): the one section of the
/// screen that follows the ViewModel. Sits 20 under the title.
class _LoginFormSection
    extends SelectorViewModelWidget<LoginViewModel, _FormData> {
  const _LoginFormSection();

  @override
  _FormData selector(LoginViewModel viewModel) => (
    submitting: viewModel.isSubmitting,
    failure: viewModel.failure,
    failureCount: viewModel.failureCount,
    prefillCount: viewModel.prefillCount,
  );

  @override
  Widget build(BuildContext context, _FormData data) {
    final viewModel = getParentViewModel<LoginViewModel>(
      context,
      listen: false,
    );
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutterAuth,
        _formGap,
        AppSpacing.gutterAuth,
        0,
      ),
      sliver: SliverToBoxAdapter(
        child: _LoginFields(
          data: data,
          forgotPasswordOpen: viewModel.forgotPasswordEnabled,
          socialLoginOpen: viewModel.socialLoginEnabled,
          prefillUsername: viewModel.prefillUsername,
        ),
      ),
    );
  }
}

/// The fields and buttons, with the controllers and focus nodes the screen
/// owns (a ViewModel holds none).
///
/// - Focus starts on the user name (kare 1); "ileri" goes to the password and
///   "git" on the password sends the form (spec §4.A "Davranış").
/// - After a failed attempt the focus returns: to the password, cleared, when
///   the pair was wrong (kare 3); to the user name when it was empty. A
///   failure of the connection keeps what was typed.
/// - While the sign-in runs the fields are locked and the button spins
///   (kare 2).
class _LoginFields extends StatefulWidget {
  const _LoginFields({
    required this.data,
    required this.forgotPasswordOpen,
    required this.socialLoginOpen,
    required this.prefillUsername,
  });

  final _FormData data;
  final bool forgotPasswordOpen;
  final bool socialLoginOpen;
  final String? prefillUsername;

  @override
  State<_LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<_LoginFields> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefillUsername;
    if (prefill != null) _username.text = prefill;
  }

  @override
  void didUpdateWidget(_LoginFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    final data = widget.data;
    final before = oldWidget.data;
    final prefill = widget.prefillUsername;
    if (data.prefillCount != before.prefillCount && prefill != null) {
      _username.text = prefill;
      _focusAfterBuild(_passwordFocus);
    }
    final failure = data.failure;
    if (data.failureCount != before.failureCount && failure != null) {
      _onFailure(failure);
    }
  }

  void _onFailure(AppErrorCode failure) {
    if (_username.text.trim().isEmpty) {
      _focusAfterBuild(_usernameFocus);
      return;
    }
    if (LoginViewModel.isCredentialFailure(failure)) _password.clear();
    _focusAfterBuild(_passwordFocus);
  }

  /// The fields are locked while the sign-in runs; the focus can only move
  /// once they are enabled again.
  void _focusAfterBuild(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) node.requestFocus();
    });
  }

  void _submit() {
    getParentViewModel<LoginViewModel>(
      context,
      listen: false,
    ).submit(username: _username.text, password: _password.text);
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final submitting = widget.data.submitting;
    final failure = widget.data.failure;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.socialLoginOpen) ...[
            const _LoginSocial(),
            const SizedBox(height: _formGap),
          ],
          AppTextField(
            label: l10n.login_usernameLabel,
            controller: _username,
            focusNode: _usernameFocus,
            autofocus: true,
            enabled: !submitting,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: _formGap),
          AppTextField(
            label: l10n.login_passwordLabel,
            controller: _password,
            focusNode: _passwordFocus,
            password: true,
            enabled: !submitting,
            textInputAction: TextInputAction.go,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _submit(),
          ),
          if (widget.forgotPasswordOpen) ...[
            // The board pulls the link up by 8 (margin-top -8) and the text
            // button's own side padding is pushed out of the 24 gutter.
            const SizedBox(height: _formGap - AppSpacing.s8),
            Align(
              alignment: Alignment.centerRight,
              child: Transform.translate(
                offset: const Offset(AppSpacing.s12, 0),
                child: AppButton(
                  label: l10n.login_forgot,
                  variant: AppButtonVariant.text,
                  onPressed: submitting
                      ? null
                      : getParentViewModel<LoginViewModel>(
                          context,
                          listen: false,
                        ).openForgotPassword,
                ),
              ),
            ),
          ],
          if (failure != null) ...[
            const SizedBox(height: _formGap),
            _LoginErrorBox(
              code: failure,
              forgotPasswordOpen: widget.forgotPasswordOpen,
            ),
          ],
          const SizedBox(height: _formGap),
          AppButton(
            label: submitting ? l10n.login_submitting : l10n.login_submit,
            loading: submitting,
            expand: true,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
