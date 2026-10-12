import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/data/interview_page.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/domain/interview_type.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_navigator.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

/// Shared fakes of the meetings tests. Values follow pano 10.5 and 10.6 and
/// Ek C: Alparslan Kuloğlu (Öğrenci, 12 Ekim 2026 Pazartesi 16:00), Elif
/// Şahin (Veli, 15 Ekim 2026 Perşembe 19:30), the note "Tarih eksikleri için
/// haftada 3 saat ayrıldı.".

const AppException offline = AppException(code: AppErrorCode.offline);
const AppException serverDown = AppException(
  code: AppErrorCode.server,
  statusCode: 500,
);

/// The clock of the tests: Monday 12 October 2026, 08:00, so Alparslan's 16:00
/// meeting is still ahead.
final DateTime morning = DateTime(2026, 10, 12, 8);

const String noteText = 'Tarih eksikleri için haftada 3 saat ayrıldı.';

/// An interview document as the server holds it.
InterviewDto interview({
  required String id,
  required String studentId,
  required String first,
  required String last,
  required DateTime date,
  InterviewType type = InterviewType.student,
  List<String> notes = const [],
}) => InterviewDto(
  id: id,
  type: type.code,
  date: date,
  student: InterviewStudentDto(
    id: studentId,
    firstName: first,
    surname: last,
    photo: '1avatarN3.png',
  ),
  notes: [for (final text in notes) InterviewNoteDto(note: text)],
);

InterviewDto alparslanMeeting({List<String> notes = const [noteText]}) =>
    interview(
      id: 'iv-1',
      studentId: 'student-1',
      first: 'Alparslan',
      last: 'Kuloğlu',
      date: DateTime(2026, 10, 12, 16),
      notes: notes,
    );

InterviewDto elifMeeting() => interview(
  id: 'iv-2',
  studentId: 'student-2',
  first: 'Elif',
  last: 'Şahin',
  date: DateTime(2026, 10, 15, 19, 30),
  type: InterviewType.parent,
);

/// An in-memory `getInterviews` and note service.
class FakeInterviewRepository implements InterviewRepository {
  FakeInterviewRepository(List<InterviewDto> interviews)
    : interviews = List.of(interviews);

  /// The server's list, in the order it answers.
  final List<InterviewDto> interviews;

  /// Every call, in order: `list:1`, `create:student-1`, `addNote:iv-1`, ...
  final List<String> log = [];

  /// The filters the list was asked with.
  final List<InterviewFilter> filters = [];

  AppException? listFailure;

  /// Fails the list call for this page only (a later page).
  int? failPage;
  AppException? createFailure;
  AppException? noteFailure;
  AppException? deleteFailure;

  /// Whether `addNewInterview` echoes the created interview.
  bool echoCreated = true;

  /// What the last note call carried: `(id, index, text)`.
  final List<(String, int?, String)> noteCalls = [];

  /// How many times each list page was asked for.
  int listCalls = 0;

  int _next = 100;

  @override
  Future<AppResult<InterviewPage>> getInterviews({
    int page = 1,
    int limit = InterviewRepository.defaultPageSize,
    InterviewFilter filter = const InterviewFilter(),
  }) async {
    log.add('list:$page');
    filters.add(filter);
    listCalls++;
    final failure = listFailure;
    if (failure != null || failPage == page) {
      return Left(failure ?? serverDown);
    }
    final kept = [
      for (final item in interviews)
        if ((filter.types.isEmpty ||
                filter.types.any((t) => t.code == item.type)) &&
            (filter.dates.isEmpty ||
                filter.dates.any((d) => _sameDay(d, item.date))))
          item,
    ];
    final from = (page - 1) * limit;
    final items = from >= kept.length
        ? <InterviewDto>[]
        : kept.sublist(from, (from + limit).clamp(0, kept.length));
    return Right(InterviewPage(items: items, page: page, limit: limit));
  }

  static bool _sameDay(DateTime day, DateTime? date) =>
      date != null &&
      day.year == date.year &&
      day.month == date.month &&
      day.day == date.day;

  @override
  Future<AppResult<InterviewDto?>> createInterview({
    required String studentId,
    required InterviewType type,
    required DateTime date,
  }) async {
    log.add('create:$studentId:${date.toIso8601String()}:${type.code}');
    final failure = createFailure;
    if (failure != null) return Left(failure);
    final created = InterviewDto(
      id: 'iv-${_next++}',
      type: type.code,
      date: date,
      student: InterviewStudentDto(id: studentId, firstName: 'Yeni'),
    );
    interviews.insert(0, created);
    return Right(echoCreated ? created : null);
  }

  int _indexOf(String id) => interviews.indexWhere((i) => i.id == id);

  @override
  Future<AppResult<Unit>> addNote({
    required String interviewId,
    required String note,
  }) async {
    log.add('addNote:$interviewId');
    noteCalls.add((interviewId, null, note));
    final failure = noteFailure;
    if (failure != null) return Left(failure);
    final at = _indexOf(interviewId);
    final item = interviews[at];
    interviews[at] = item.copyWith(
      notes: [
        ...item.notes,
        InterviewNoteDto(note: note),
      ],
    );
    return const Right(unit);
  }

  @override
  Future<AppResult<Unit>> editNote({
    required String interviewId,
    required int index,
    required String note,
  }) async {
    log.add('editNote:$interviewId:$index');
    noteCalls.add((interviewId, index, note));
    final failure = noteFailure;
    if (failure != null) return Left(failure);
    final at = _indexOf(interviewId);
    final item = interviews[at];
    final notes = [...item.notes];
    notes[index] = InterviewNoteDto(note: note);
    interviews[at] = item.copyWith(notes: notes);
    return const Right(unit);
  }

  @override
  Future<AppResult<Unit>> deleteNote({
    required String interviewId,
    required int index,
  }) async {
    log.add('deleteNote:$interviewId:$index');
    final failure = deleteFailure;
    if (failure != null) return Left(failure);
    final at = _indexOf(interviewId);
    final item = interviews[at];
    final notes = [...item.notes]..removeAt(index);
    interviews[at] = item.copyWith(notes: notes);
    return const Right(unit);
  }
}

/// Answers the dialogs the ViewModels ask.
class FakeMeetingsDialogs implements MeetingsDialogs {
  /// What the new-meeting sheet saves; `null` closes it without saving.
  MeetingDraft? draft;

  /// What the note sheet saves; `null` closes it without saving.
  String? noteToSave;
  bool confirmDelete = true;

  final List<String> asked = [];
  List<CoachStudentDto>? lastStudents;
  String? lastStudentId;
  String? lastInitialText;
  DateTime? lastNoteDate;
  String? lastNoteStudent;
  String? lastDeleteQuote;

  /// What the submit callbacks answered: `true` closes the sheet.
  final List<bool> submitted = [];

  @override
  Future<bool> newMeeting({
    required List<CoachStudentDto> students,
    required MeetingSubmit submit,
    String? studentId,
  }) async {
    asked.add('newMeeting');
    lastStudents = students;
    lastStudentId = studentId;
    final input = draft;
    if (input == null) return false;
    final saved = await submit(input);
    submitted.add(saved);
    return saved;
  }

  @override
  Future<bool> writeNote({
    required NoteSubmit submit,
    String? initialText,
    DateTime? date,
    String? studentName,
  }) async {
    asked.add(initialText == null ? 'addNote' : 'editNote');
    lastInitialText = initialText;
    lastNoteDate = date;
    lastNoteStudent = studentName;
    final text = noteToSave;
    if (text == null) return false;
    final saved = await submit(text);
    submitted.add(saved);
    return saved;
  }

  @override
  Future<bool> confirmDeleteNote({required String text}) async {
    asked.add('confirmDelete');
    lastDeleteQuote = text;
    return confirmDelete;
  }
}

class FakeMeetingsNavigator implements MeetingsNavigator {
  final List<MeetingEntry> opened = [];
  final List<String> studentData = [];

  @override
  Future<void> openMeeting(MeetingEntry meeting) async => opened.add(meeting);

  @override
  Future<void> openStudentData({
    required String studentId,
    required String name,
    String? photo,
  }) async => studentData.add('$studentId:$name');
}

/// A coach's student list for the sheet's picker.
class FakeCoachStudents implements CoachStudentRepository {
  FakeCoachStudents(this.students);

  List<CoachStudentDto> students;
  AppException? failure;

  @override
  Future<AppResult<List<CoachStudentDto>>> getMyStudents() async =>
      failure != null ? Left(failure!) : Right(students);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

CoachStudentsService studentsService(FakeCoachStudents repository) =>
    CoachStudentsService(repository: repository);

const CoachStudentDto alparslanStudent = CoachStudentDto(
  id: 'student-1',
  firstName: 'Alparslan',
  surname: 'Kuloğlu',
  photo: '1avatarN3.png',
);

const CoachStudentDto elifStudent = CoachStudentDto(
  id: 'student-2',
  firstName: 'Elif',
  surname: 'Şahin',
);

class FakeToastPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

/// A toast service whose current text can be read back in Turkish.
class ToastProbe {
  ToastProbe() : service = ToastService(presenter: FakeToastPresenter());

  final ToastService service;
  final AppLocalizationsTr l10n = AppLocalizationsTr();

  /// The toast on screen, or `null`.
  String? get text => service.slot.current.value?.title(l10n);

  bool get isError => service.slot.current.value?.kind == AppToastKind.error;
  bool get hasUndo => service.slot.current.value?.hasUndo ?? false;

  /// Presses "Geri Al" on the toast on screen.
  bool pressUndo() {
    final entry = service.slot.current.value;
    return entry != null && service.slot.undo(entry.id);
  }

  void dispose() => service.dispose();
}

/// A timer the test fires by hand: the "Geri Al" window.
class ManualTimers {
  final List<_ManualTimer> _timers = [];

  Timer create(Duration delay, void Function() run) {
    final timer = _ManualTimer(run);
    _timers.add(timer);
    return timer;
  }

  /// How many timers are still waiting.
  int get waiting => _timers.where((t) => t.isActive).length;

  /// Fires the oldest waiting timer.
  void fire() {
    final timer = _timers.firstWhere((t) => t.isActive);
    timer.fire();
  }
}

class _ManualTimer implements Timer {
  _ManualTimer(this._run);

  final void Function() _run;
  bool _active = true;

  void fire() {
    if (!_active) return;
    _active = false;
    _run();
  }

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

/// A list call that never answers (the 15 s limit).
class FakeInterviewRepositoryHanging extends FakeInterviewRepository {
  FakeInterviewRepositoryHanging() : super(const []);

  @override
  Future<AppResult<InterviewPage>> getInterviews({
    int page = 1,
    int limit = InterviewRepository.defaultPageSize,
    InterviewFilter filter = const InterviewFilter(),
  }) => Completer<AppResult<InterviewPage>>().future;
}
