part of '../profile_view.dart';

/// The read-only form (pano 9.2 kare 1): Ad Soyad, Kullanıcı adı (with the
/// lock), E-posta, Telefon, Sınıf and Alan in the `bgSunken` boxes of the
/// "salt okunur" look, 16 apart. A value the account does not have is not
/// drawn (no empty boxes, no placeholder text); a coach has no Sınıf and
/// Alan. Drawn only while reading.
class _ProfileViewFields
    extends SelectorViewModelWidget<ProfileViewModel, ProfileViewData?> {
  const _ProfileViewFields();

  @override
  ProfileViewData? selector(ProfileViewModel viewModel) =>
      viewModel.mode == ProfileMode.view ? viewModel.viewData : null;

  @override
  Widget build(BuildContext context, ProfileViewData? data) {
    if (data == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final draft = data.draft;
    final grade = draft.grade;
    final track = data.hasGradeFields && grade != null && grade.requiresTrack
        ? draft.track
        : null;
    final rows = <Widget>[
      if (draft.name.isNotEmpty)
        _ReadOnlyField(label: l10n.account_fieldName, value: draft.name),
      if (data.userName case final userName? when userName.isNotEmpty)
        _ReadOnlyField(
          label: l10n.account_fieldUserName,
          value: userName,
          locked: true,
        ),
      if (draft.email.isNotEmpty)
        _ReadOnlyField(label: l10n.account_fieldEmail, value: draft.email),
      if (PhoneNumber.display(draft.phone) case final phone?)
        _ReadOnlyField(label: l10n.account_fieldPhone, value: phone),
      if (data.hasGradeFields && grade != null)
        _ReadOnlyField(
          label: l10n.account_fieldGrade,
          value: accountGradeLabel(l10n, grade),
        ),
      if (track != null)
        _ReadOnlyField(
          label: l10n.account_fieldTrack,
          value: accountTrackLabel(l10n, track),
        ),
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

/// One read-only box: the label above it and the value in the 16/24 input
/// type, with a 20 pt Lock at the right when [locked] (the user name).
class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    this.locked = false,
    this.helperText,
  });

  final String label;
  final String value;
  final bool locked;

  /// The line under the box ("Kullanıcı adı değiştirilemez.").
  final String? helperText;

  @override
  Widget build(BuildContext context) {
    return AppFieldFrame(
      label: label,
      readOnly: true,
      helperText: helperText,
      trailing: locked ? const _LockMark() : null,
      inputBuilder: (context, node, style, cursor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Text(value, style: style),
      ),
    );
  }
}

/// The lock of a field that cannot be changed: 20 pt in `textSecondary` in a
/// 48 pt square (like `AppTextField(readOnly: true)`).
class _LockMark extends StatelessWidget {
  const _LockMark();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: AppSize.touch,
    child: Center(
      child: PhosphorIcon(
        PhosphorIconsRegular.lock,
        size: AppSize.iconInButton,
        color: context.appColors.textSecondary,
      ),
    ),
  );
}
