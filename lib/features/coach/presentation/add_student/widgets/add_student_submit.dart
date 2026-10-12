part of '../add_student_sheet.dart';

typedef _SaveData = (bool, AppException?);

/// What is under the fields: the notice of a failed save (the sheet stays
/// open with what was typed) and the primary "Öğrenciyi Kaydet" (pano 10.3
/// kare 1 and 2). While the student is saved the button shows its spinner and
/// the frame is busy. The button stays live with a field missing: a press
/// shows what is wrong under each field and moves focus to the first.
class _SaveSection
    extends SelectorViewModelWidget<AddStudentViewModel, _SaveData> {
  const _SaveSection();

  @override
  _SaveData selector(AddStudentViewModel viewModel) =>
      (viewModel.submitting, viewModel.failure);

  @override
  Widget build(BuildContext context, _SaveData data) {
    final (submitting, failure) = data;
    final l10n = AppLocalizations.of(context);
    final viewModel = getParentViewModel<AddStudentViewModel>(
      context,
      listen: false,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (failure != null) ...[
          AppNoticeBox(
            tone: AppNoticeTone.error,
            message: addStudentFailureText(l10n, failure),
          ),
          const SizedBox(height: _addStudentGap),
        ],
        AppButton(
          label: l10n.addStudent_save,
          expand: true,
          loading: submitting,
          focusGapColor: context.appColors.bgRaised,
          onPressed: () async {
            final added = await viewModel.submit();
            if (added != null && context.mounted) {
              Navigator.of(context).pop(added);
            }
          },
        ),
      ],
    );
  }
}
