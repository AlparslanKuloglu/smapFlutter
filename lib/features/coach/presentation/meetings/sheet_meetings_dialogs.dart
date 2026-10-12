import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/presentation/meetings/detail/sheets/note_sheet.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/sheets/new_meeting_sheet.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/sheets/app_confirm_sheet.dart';

/// [MeetingsDialogs] as the app's sheets (UI guide §6 rule 15).
///
/// A ViewModel has no `BuildContext`, so the sheets open on the root
/// navigator (`AppSheet.navigatorKey`); [l10n] gives the texts of the confirm
/// sheet (the app is Turkish only, so the localizations do not depend on a
/// widget).
class SheetMeetingsDialogs implements MeetingsDialogs {
  const SheetMeetingsDialogs({required this.l10n});

  final AppLocalizations l10n;

  @override
  Future<bool> newMeeting({
    required List<CoachStudentDto> students,
    required MeetingSubmit submit,
    String? studentId,
  }) => NewMeetingSheet.show(
    students: students,
    submit: submit,
    studentId: studentId,
  );

  @override
  Future<bool> writeNote({
    required NoteSubmit submit,
    String? initialText,
    DateTime? date,
    String? studentName,
  }) => NoteSheet.show(
    submit: submit,
    initialText: initialText,
    date: date,
    studentName: studentName,
  );

  @override
  Future<bool> confirmDeleteNote({required String text}) async {
    final result = await AppConfirmSheet.show(
      title: l10n.coachMeetings_noteDeleteTitle,
      message: l10n.coachMeetings_noteDeleteBody(text),
      confirmLabel: l10n.coachMeetings_noteDeleteAction,
      cancelLabel: l10n.common_cancel,
      danger: true,
    );
    return result.confirmed;
  }
}
