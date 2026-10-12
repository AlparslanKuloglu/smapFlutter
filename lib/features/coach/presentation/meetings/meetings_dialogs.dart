import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';

/// Saves a new meeting while the sheet is busy; `true` when it was saved
/// (the sheet closes), `false` when it failed (the sheet stays open with the
/// input intact and the caller has toasted).
typedef MeetingSubmit = Future<bool> Function(MeetingDraft draft);

/// Saves a note's text while the sheet is busy; `true` closes the sheet,
/// `false` keeps it open with the text.
typedef NoteSubmit = Future<bool> Function(String text);

/// The sheets of the meeting screens (UI guide §6 rule 15: a sheet returns a
/// typed result; the ViewModel that asked does the writing). The ViewModels
/// hold this interface, the app gives them the sheets
/// (`SheetMeetingsDialogs`), tests give them answers.
abstract interface class MeetingsDialogs {
  /// "Yeni görüşme" (pano 10.5 kare 2): the student, who the meeting is with,
  /// the day and time and an optional note. [submit] saves while the sheet is
  /// busy. [studentId] opens it with that student chosen (Öğrenci Profili's
  /// "Görüşme Planla"). `true` when a meeting was saved.
  Future<bool> newMeeting({
    required List<CoachStudentDto> students,
    required MeetingSubmit submit,
    String? studentId,
  });

  /// The note sheet (pano 10.6 kare 1 and 2). [initialText] null is "Not
  /// ekle" (with the context line [date] · [studentName]), a text is "Notu
  /// düzenle". [submit] saves while the sheet is busy. `true` when it was
  /// saved.
  Future<bool> writeNote({
    required NoteSubmit submit,
    String? initialText,
    DateTime? date,
    String? studentName,
  });

  /// "Not silinsin mi?" (pano 10.6 kare 3): the dangerous confirmation that
  /// quotes [text]. `true` when the coach pressed "Notu Sil".
  Future<bool> confirmDeleteNote({required String text});
}
