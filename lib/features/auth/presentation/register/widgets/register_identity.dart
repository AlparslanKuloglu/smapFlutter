part of '../register_view.dart';

/// "Avatarın" with the seven avatars in one row (pano 2.5 kare 1; C57).
/// The title row carries "7 avatar" on the right; the picker draws no count
/// of its own.
class _AvatarSection extends SelectorViewModelWidget<RegisterViewModel, int> {
  const _AvatarSection();

  static final List<ImageProvider> _avatars = [
    for (final file in RegisterViewModel.avatarFiles)
      AssetImage('assets/avatars/$file'),
  ];

  @override
  int selector(RegisterViewModel viewModel) => viewModel.avatarIndex;

  @override
  Widget build(BuildContext context, int selected) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return Semantics(
      container: true,
      label: l10n.register_avatarPickerA11y,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.register_avatarLabel,
                  style: text.labelMd.copyWith(color: colors.textPrimary),
                ),
              ),
              Text(
                l10n.kit_avatarCount(_avatars.length),
                style: text.caption.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          SizedBox(
            width: double.infinity,
            child: AppAvatarPicker(
              avatars: _avatars,
              selectedIndex: selected,
              onChanged: viewModel.setAvatar,
              showCount: false,
            ),
          ),
        ],
      ),
    );
  }
}

/// "Ad Soyad" (pano 2.5 kare 1).
class _FullNameField
    extends SelectorViewModelWidget<RegisterViewModel, RegisterIssue?> {
  const _FullNameField();

  @override
  RegisterIssue? selector(RegisterViewModel viewModel) =>
      viewModel.issueFor(RegisterField.fullName);

  @override
  Widget build(BuildContext context, RegisterIssue? issue) {
    final l10n = AppLocalizations.of(context);
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return KeyedSubtree(
      key: scope.anchors[RegisterField.fullName],
      child: AppTextField(
        label: l10n.register_fieldFullName,
        controller: scope.fullName,
        focusNode: scope.focus[RegisterField.fullName],
        errorText: issue == null ? null : registerIssueText(l10n, issue),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        textCapitalization: TextCapitalization.words,
        autofillHints: const [AutofillHints.name],
        onChanged: viewModel.onFullName,
      ),
    );
  }
}

typedef _UsernameData = (UsernameCheckState, RegisterIssue?);

/// "Kullanıcı adı" with its live check (pano 2.5 kare 1 "Bu kullanıcı adı
/// boşta."; pano 2.6 kare 1 "Bu kullanıcı adı alınmış." and the free-name
/// chip). A spinner at the right while the server is asked.
class _UsernameField
    extends SelectorViewModelWidget<RegisterViewModel, _UsernameData> {
  const _UsernameField();

  @override
  _UsernameData selector(RegisterViewModel viewModel) =>
      (viewModel.usernameCheck, viewModel.issueFor(RegisterField.username));

  @override
  Widget build(BuildContext context, _UsernameData data) {
    final (check, issue) = data;
    final l10n = AppLocalizations.of(context);
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    final available = issue == null && check.status == UsernameStatus.available;
    final suggestion = issue == RegisterIssue.usernameTaken
        ? check.suggestion
        : null;
    return KeyedSubtree(
      key: scope.anchors[RegisterField.username],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: l10n.register_fieldUsername,
            controller: scope.username,
            focusNode: scope.focus[RegisterField.username],
            errorText: issue == null ? null : registerIssueText(l10n, issue),
            successText: available ? l10n.register_usernameFree : null,
            helperText: check.status == UsernameStatus.offline
                ? l10n.register_usernameOffline
                : null,
            checking: check.status == UsernameStatus.checking,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newUsername],
            inputFormatters: const [UserNameInputFormatter()],
            onChanged: viewModel.onUsername,
          ),
          if (suggestion != null) ...[
            const SizedBox(height: AppSpacing.s8),
            _UsernameSuggestion(
              name: suggestion,
              onPicked: () {
                scope.username.value = TextEditingValue(
                  text: suggestion,
                  selection: TextSelection.collapsed(offset: suggestion.length),
                );
                viewModel.onUsername(suggestion, immediately: true);
              },
            ),
          ],
        ],
      ),
    );
  }
}

/// "Boşta olan:" and the free name as a 40 pt chip; a tap writes it into the
/// field and runs the check again (pano 2.6 kare 1).
class _UsernameSuggestion extends StatelessWidget {
  const _UsernameSuggestion({required this.name, required this.onPicked});

  final String name;
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    return Row(
      children: [
        Text(
          l10n.register_usernameSuggest,
          style: context.appText.caption.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(width: AppSpacing.s8),
        Flexible(
          child: Semantics(
            label: l10n.register_usernameSuggestA11y(name),
            excludeSemantics: true,
            button: true,
            onTap: onPicked,
            child: AppChip(
              label: name,
              onTap: onPicked,
              size: AppChipSize.md40,
            ),
          ),
        ),
      ],
    );
  }
}

/// "E-posta" (pano 2.5 kare 1; error pano 2.6 kare 1).
class _EmailField
    extends SelectorViewModelWidget<RegisterViewModel, RegisterIssue?> {
  const _EmailField();

  @override
  RegisterIssue? selector(RegisterViewModel viewModel) =>
      viewModel.issueFor(RegisterField.email);

  @override
  Widget build(BuildContext context, RegisterIssue? issue) {
    final l10n = AppLocalizations.of(context);
    final scope = _RegisterScope.of(context);
    final viewModel = getParentViewModel<RegisterViewModel>(
      context,
      listen: false,
    );
    return KeyedSubtree(
      key: scope.anchors[RegisterField.email],
      child: AppTextField(
        label: l10n.register_fieldEmail,
        controller: scope.email,
        focusNode: scope.focus[RegisterField.email],
        errorText: issue == null ? null : registerIssueText(l10n, issue),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        onChanged: viewModel.onEmail,
      ),
    );
  }
}
