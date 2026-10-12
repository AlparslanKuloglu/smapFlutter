part of '../add_student_sheet.dart';

/// "Avatar" with the seven avatars in one row (Tur 12 D, brief 14.8 kare 1;
/// the sign-up's in-row picker, pano 2.5 kare 1; C57). The label row carries
/// "7 avatar" at the right; the picker draws no count of its own. The first
/// avatar is chosen when the sheet opens; choosing is not required.
class _AvatarSection extends SelectorViewModelWidget<AddStudentViewModel, int> {
  const _AvatarSection();

  static final List<ImageProvider> _avatars = [
    for (var i = 0; i < StudentAvatars.files.length; i++)
      AssetImage(StudentAvatars.assetOf(i)!),
  ];

  @override
  int selector(AddStudentViewModel viewModel) => viewModel.avatarIndex;

  @override
  Widget build(BuildContext context, int selected) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final text = context.appText;
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    return Semantics(
      container: true,
      label: l10n.addStudent_avatarPickerA11y,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.addStudent_avatarLabel,
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
              gapColor: colors.bgRaised,
            ),
          ),
        ],
      ),
    );
  }
}
