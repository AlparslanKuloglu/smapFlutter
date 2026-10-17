part of '../add_student_sheet.dart';

/// "Avatar" with the seven avatars in one row (Tur 12 D, pano 14.8 kare 1 and
/// 14.12 kare 1; the picker's row variant, C57 / 1.17). The label row carries
/// "Avatar" (14/20 · 600) and, at the right, the counter "4 / 7" (13/20 · 600
/// `textSecondary`: chosen position over the total); under it 7 avatars of 44
/// pt, evenly spread, each in a 48 pt touch slot. The chosen one has a 2 pt gap
/// in the sheet's color and a 2 pt `primary` ring that fades in over 150 ms.
/// The first avatar is chosen when the sheet opens; choosing is not required
/// (T12.17).
///
/// Read as the radio group "Avatar, 7 seçenek" whose options are "Avatar 4 / 7,
/// seçili"; a tap plays the selection haptic.
class _AvatarSection extends SelectorViewModelWidget<AddStudentViewModel, int> {
  const _AvatarSection();

  /// The avatar's edge (pano 14.8 "7 × 44 pt").
  static const double _avatarSize = 44;

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
    final total = _avatars.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: false,
                child: Text(
                  l10n.addStudent_avatarLabel,
                  style: text.labelMd.copyWith(color: colors.textPrimary),
                ),
              ),
            ),
            ExcludeSemantics(
              child: Text(
                l10n.addStudent_avatarCounter(selected + 1, total),
                style: text.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        AppAvatarPicker(
          avatars: _avatars,
          selectedIndex: selected,
          onChanged: viewModel.setAvatar,
          size: _avatarSize,
          showCount: false,
          gapColor: colors.bgRaised,
          groupLabel: l10n.addStudent_avatarGroupA11y(total),
          optionLabelOf: (i) => l10n.addStudent_avatarOptionA11y(i + 1, total),
        ),
      ],
    );
  }
}
