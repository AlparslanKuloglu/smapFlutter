import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';

/// "Yeni görüşme" from start to finish (pano 10.5 kare 2; "Görüşme Planla" of
/// Öğrenci Profili, pano 10.4; "Yeni Görüşme" of Koç Anasayfa, pano 10.1): the
/// coach's students are read, the sheet asks for the meeting, the meeting is
/// saved (and its note, which needs a second call: `addNewInterview` takes
/// none) and the toast says what happened.
///
/// Context-free: the sheet comes from [MeetingsDialogs] and the words from
/// the toast lambdas, so Görüşmelerim, the profile and the home screen use the
/// same flow and a test can drive it. [run] never throws.
class NewMeetingFlow {
  NewMeetingFlow({
    required MeetingsDialogs dialogs,
    required InterviewRepository interviews,
    required ToastService toast,
    CoachStudentsService? students,
  }) : _dialogs = dialogs,
       _interviews = interviews,
       _toast = toast,
       _students = students;

  final MeetingsDialogs _dialogs;
  final InterviewRepository _interviews;
  final ToastService _toast;
  final CoachStudentsService? _students;

  bool _running = false;
  bool _noteFailed = false;

  /// Opens the sheet ([studentId] opens it with that student chosen) and
  /// saves. `true` when a meeting was saved (the caller reads its list again),
  /// `false` when nothing was saved: the sheet was dismissed, the coach has no
  /// student, the students could not be read, or another run is on.
  Future<bool> run({String? studentId}) async {
    if (_running) return false;
    _running = true;
    try {
      final students = await _loadStudents();
      if (students == null) return false;
      if (students.isEmpty) {
        _toast.info((l) => l.coachMeetings_noStudents);
        return false;
      }
      _noteFailed = false;
      final saved = await _dialogs.newMeeting(
        students: students,
        submit: _save,
        studentId: studentId,
      );
      if (!saved) return false;
      if (_noteFailed) {
        _toast.error((l) => l.coachMeetings_savedWithoutNote);
      } else {
        _toast.success((l) => l.coachMeetings_saved);
      }
      return true;
    } finally {
      _running = false;
    }
  }

  /// The coach's students, in Turkish order; `null` (after a toast) when they
  /// could not be loaded.
  Future<List<CoachStudentDto>?> _loadStudents() async {
    final service = _students;
    if (service == null) {
      _toast.error((l) => l.coachMeetings_studentsFailed);
      return null;
    }
    final loaded = await service.load();
    if (loaded.isLeft()) {
      _toast.error((l) => l.coachMeetings_studentsFailed);
      return null;
    }
    return service.sortedStudents;
  }

  /// The sheet's "Görüşmeyi Kaydet": the meeting, then its note.
  Future<bool> _save(MeetingDraft draft) async {
    final created = await _interviews.createInterview(
      studentId: draft.studentId,
      type: draft.type,
      date: draft.moment,
    );
    if (created.isLeft()) {
      _toast.error((l) => l.coachMeetings_saveFailed);
      return false;
    }
    final note = draft.note;
    if (note == null) return true;
    final id = created.rightOrNull?.id;
    if (id == null) {
      // The server accepted the meeting without echoing it: there is no id
      // to put the note under.
      _noteFailed = true;
      return true;
    }
    final added = await _interviews.addNote(interviewId: id, note: note);
    _noteFailed = added.isLeft();
    return true;
  }
}
