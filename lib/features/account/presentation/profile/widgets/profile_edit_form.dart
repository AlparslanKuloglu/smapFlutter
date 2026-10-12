part of '../profile_view.dart';

/// The open form (pano 9.2 kare 2 and 4): drawn only while editing. It holds
/// the three text fields' controllers (the UI owns them, the ViewModel only
/// hears the text) and starts from the account's values each time it opens.
class _ProfileEditFields
    extends SelectorViewModelWidget<ProfileViewModel, ProfileEditData?> {
  const _ProfileEditFields();

  @override
  ProfileEditData? selector(ProfileViewModel viewModel) =>
      viewModel.mode == ProfileMode.edit ? viewModel.editData : null;

  @override
  Widget build(BuildContext context, ProfileEditData? data) {
    if (data == null) return const SizedBox.shrink();
    final initial = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    ).draft;
    return _EditForm(data: data, initial: initial);
  }
}

class _EditForm extends StatefulWidget {
  const _EditForm({required this.data, required this.initial});

  final ProfileEditData data;

  /// The values the fields start with; read once.
  final ProfileDraft initial;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial.name,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initial.email,
  );
  late final TextEditingController _phone = TextEditingController(
    text: widget.initial.phone,
  );

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<ProfileViewModel>(
      context,
      listen: false,
    );
    final data = widget.data;
    String? issueText(ProfileIssue issue) =>
        data.issues.contains(issue) ? profileIssueText(l10n, issue) : null;
    final grade = data.grade;
    final trackEnabled = grade == null || grade.requiresTrack;
    final rows = <Widget>[
      AppTextField(
        label: l10n.account_fieldName,
        controller: _name,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        errorText: issueText(ProfileIssue.nameMissing),
        onChanged: viewModel.setName,
      ),
      if (data.userName case final userName? when userName.isNotEmpty)
        _ReadOnlyField(
          label: l10n.account_fieldUserName,
          value: userName,
          locked: true,
          helperText: l10n.account_userNameLocked,
        ),
      AppTextField(
        label: l10n.account_fieldEmail,
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        errorText: issueText(ProfileIssue.emailInvalid),
        onChanged: viewModel.setEmail,
      ),
      AppTextField(
        label: l10n.account_fieldPhone,
        controller: _phone,
        prefixText: PhoneNumber.countryPrefix,
        hintText: l10n.account_phoneHint,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        inputFormatters: [AppInputMasks.phone],
        errorText: issueText(ProfileIssue.phoneInvalid),
        onChanged: viewModel.setPhone,
      ),
      if (data.hasGradeFields) ...[
        AppSelectField<SchoolGrade>(
          label: l10n.account_fieldGrade,
          value: grade,
          options: [
            for (final value in SchoolGrade.values)
              AppSelectOption(
                value: value,
                label: accountGradeLabel(l10n, value),
              ),
          ],
          sheetNote: l10n.account_gradeNote,
          onChanged: viewModel.setGrade,
        ),
        AppSelectField<StudyTrack>(
          label: l10n.account_fieldTrack,
          value: data.track,
          options: [
            for (final value in StudyTrack.selectable)
              AppSelectOption(
                value: value,
                label: accountTrackLabel(l10n, value),
              ),
          ],
          enabled: trackEnabled,
          disabledValueText: l10n.account_trackDisabledValue,
          helperText: trackEnabled ? null : l10n.account_trackDisabledHelper,
          onChanged: viewModel.setTrack,
        ),
      ],
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, row) in rows.indexed) ...[
          if (i > 0) const SizedBox(height: _fieldGap),
          row,
        ],
      ],
    );
  }
}
