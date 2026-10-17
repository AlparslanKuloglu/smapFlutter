part of '../add_student_sheet.dart';

typedef _SaveData = (bool, bool);

/// The gap between the passive button and its reason (pano 14.8 kare 4: 16
/// between the rows less 6).
const double _offlineReasonGap = 10;

/// What is under the fields: the primary "Öğrenciyi Kaydet" (pano 10.3 kare 1
/// and 2). While the student is saved the button shows its spinner and the
/// frame is busy. The button stays live with a field missing: a press shows
/// what is wrong under each field and moves focus to the first. Offline it is
/// passive and the reason stands under it, "Öğrenci eklemek için bağlantı
/// gerekiyor. Kod kartı çevrimdışında da çalışır." (pano 14.8 kare 4; the form
/// and the avatar stay as they were typed). A failed save is a toast, not
/// something drawn here (kare 5).
class _SaveSection
    extends SelectorViewModelWidget<AddStudentViewModel, _SaveData> {
  const _SaveSection();

  @override
  _SaveData selector(AddStudentViewModel viewModel) =>
      (viewModel.submitting, viewModel.canSubmit);

  @override
  Widget build(BuildContext context, _SaveData data) {
    final (submitting, canSubmit) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: l10n.addStudent_save,
          expand: true,
          loading: submitting,
          focusGapColor: context.appColors.bgRaised,
          onPressed: canSubmit
              ? () async {
                  final added = await viewModel.submit();
                  if (added != null && context.mounted) {
                    Navigator.of(context).pop(added);
                  }
                }
              : null,
        ),
        if (!canSubmit) ...[
          const SizedBox(height: _offlineReasonGap),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.addStudent_saveOfflineReason,
              style: context.appText.caption.copyWith(
                color: context.appColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
