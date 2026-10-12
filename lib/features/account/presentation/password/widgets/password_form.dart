part of '../password_view.dart';

/// The gap between the fields (pano 9.3: "alanlar arası 20"). Not on the 4-pt
/// scale of `AppSpacing`.
const double _fieldGap = 20;

typedef _FormData = ({bool sending, PasswordIssue? issue, int focusRequests});

/// The three fields and the button (pano 9.3 kare 1 and 2).
class _PasswordFormSection
    extends SelectorViewModelWidget<PasswordViewModel, _FormData> {
  const _PasswordFormSection();

  @override
  _FormData selector(PasswordViewModel viewModel) => (
    sending: viewModel.isSending,
    issue: viewModel.issue,
    focusRequests: viewModel.focusRequests,
  );

  @override
  Widget build(BuildContext context, _FormData data) => SliverPadding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.gutter,
      _fieldGap,
      AppSpacing.gutter,
      0,
    ),
    sliver: SliverToBoxAdapter(child: _PasswordForm(data: data)),
  );
}

/// The form with the controllers and focus nodes the screen owns.
///
/// "Mevcut şifre" and "Yeni şifre" move on with "ileri"; "bitti" on the last
/// field sends the form. When the ViewModel counts a new focus request the
/// field of the issue takes the focus (kare 2: "Odak mevcut şifrede kalır").
class _PasswordForm extends StatefulWidget {
  const _PasswordForm({required this.data});

  final _FormData data;

  @override
  State<_PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<_PasswordForm> {
  final TextEditingController _current = TextEditingController();
  final TextEditingController _next = TextEditingController();
  final TextEditingController _repeat = TextEditingController();
  final FocusNode _currentFocus = FocusNode();
  final FocusNode _nextFocus = FocusNode();
  final FocusNode _repeatFocus = FocusNode();

  PasswordViewModel get _viewModel =>
      getParentViewModel<PasswordViewModel>(context, listen: false);

  @override
  void initState() {
    super.initState();
    for (final controller in [_current, _next, _repeat]) {
      controller.addListener(_edited);
    }
  }

  @override
  void didUpdateWidget(_PasswordForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final issue = widget.data.issue;
    if (issue != null &&
        widget.data.focusRequests != oldWidget.data.focusRequests) {
      _focusNodeOf(issue.field).requestFocus();
    }
  }

  @override
  void dispose() {
    for (final controller in [_current, _next, _repeat]) {
      controller
        ..removeListener(_edited)
        ..dispose();
    }
    _currentFocus.dispose();
    _nextFocus.dispose();
    _repeatFocus.dispose();
    super.dispose();
  }

  FocusNode _focusNodeOf(PasswordField field) => switch (field) {
    PasswordField.current => _currentFocus,
    PasswordField.next => _nextFocus,
    PasswordField.repeat => _repeatFocus,
  };

  void _edited() => _viewModel.edited(
    current: _current.text,
    next: _next.text,
    repeat: _repeat.text,
  );

  void _submit() => _viewModel.submit(
    current: _current.text,
    next: _next.text,
    repeat: _repeat.text,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = widget.data;
    final issue = data.issue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: l10n.password_currentLabel,
          controller: _current,
          focusNode: _currentFocus,
          password: true,
          enabled: !data.sending,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.password],
          errorText: issue == PasswordIssue.wrongCurrent
              ? l10n.password_errWrongCurrent
              : null,
          onSubmitted: (_) => _nextFocus.requestFocus(),
        ),
        const SizedBox(height: _fieldGap),
        AppTextField(
          label: l10n.password_newLabel,
          controller: _next,
          focusNode: _nextFocus,
          password: true,
          enabled: !data.sending,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.newPassword],
          helperText: l10n.password_newRule,
          errorText: switch (issue) {
            PasswordIssue.tooShort => l10n.password_newRule,
            PasswordIssue.sameAsCurrent => l10n.password_errSame,
            _ => null,
          },
          onSubmitted: (_) => _repeatFocus.requestFocus(),
        ),
        const SizedBox(height: _fieldGap),
        AppTextField(
          label: l10n.password_repeatLabel,
          controller: _repeat,
          focusNode: _repeatFocus,
          password: true,
          enabled: !data.sending,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          errorText: issue == PasswordIssue.mismatch
              ? l10n.password_errMismatch
              : null,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: _fieldGap),
        ValueListenableBuilder<bool>(
          valueListenable: _viewModel.canSubmit,
          builder: (context, canSubmit, _) => AppButton(
            label: l10n.password_submit,
            loading: data.sending,
            expand: true,
            onPressed: canSubmit ? _submit : null,
          ),
        ),
      ],
    );
  }
}
