import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/coach/application/interview_locator.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/application/note_delete_hold.dart';
import 'package:smap/features/coach/application/note_rules.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What the "Notlar" card draws (pano 10.6): the state of the notes and, when
/// it is [SectionState.ready], the notes that are on the screen (a note that
/// waits out "Geri Al" is already gone from it).
@immutable
class MeetingNotesData {
  const MeetingNotesData(this.state, [this.notes = const []]);

  final SectionState state;
  final List<MeetingNote> notes;

  @override
  bool operator ==(Object other) =>
      other is MeetingNotesData &&
      other.state == state &&
      listEquals(other.notes, notes);

  @override
  int get hashCode => Object.hash(state, Object.hashAll(notes));
}

/// The logic of Görüşme Detayı and its notes (pano 10.5 kare 3, 10.6 kare 1
/// to 4; flow 13.11).
///
/// - **Load:** the header (student, kind, date and time) is drawn at once from
///   the meeting the list passed in. The *notes* are always read again from
///   the server before they are shown, because a note is addressed by its
///   position in the list (`editIndex`, `deleteIndex`) and a position the
///   list screen saw earlier may be stale. A link that carries only the id
///   starts on the skeleton and finds the meeting in the list
///   ([InterviewLocator]). The server has no "get interview" call.
/// - **Not ekle / düzenle:** the note sheet saves while it is busy; a failure
///   leaves it open with the text and toasts. After every write the meeting is
///   read again, so the positions are the server's.
/// - **Sil:** the confirmation, then the note leaves the screen and the
///   request waits 6 s behind the toast "Not silindi." with "Geri Al"
///   ([NoteDeleteHold]; the server cannot take a deleted note back). Any other
///   write, and leaving the screen, sends a waiting deletion first, so a
///   position is never used after it moved.
/// - There is no call to edit or delete the meeting itself (spec §6.3 #31),
///   so the bar's "Düzenle" is not drawn.
class MeetingDetailViewModel extends BaseViewModel {
  MeetingDetailViewModel({
    required this.meetingId,
    required InterviewRepository interviews,
    required InterviewLocator locator,
    required MeetingsNavigator navigator,
    required MeetingsDialogs dialogs,
    required ToastService toast,
    required ValueListenable<bool> online,
    MeetingEntry? meeting,
    Duration undoWindow = SmapDurations.undoToast,
    Duration timeout = SmapDurations.skeletonTimeout,
    HoldTimerFactory? timerFactory,
  }) : _interviews = interviews,
       _locator = locator,
       _navigator = navigator,
       _dialogs = dialogs,
       _toast = toast,
       _online = online,
       _timeout = timeout,
       _meeting = meeting {
    _hold = NoteDeleteHold(
      delay: undoWindow,
      commit: _commitDelete,
      timerFactory: timerFactory,
    );
  }

  /// The meeting's id (the route's path parameter).
  final String meetingId;

  final InterviewRepository _interviews;
  final InterviewLocator _locator;
  final MeetingsNavigator _navigator;
  final MeetingsDialogs _dialogs;
  final ToastService _toast;
  final ValueListenable<bool> _online;
  final Duration _timeout;
  late final NoteDeleteHold _hold;

  MeetingEntry? _meeting;
  SectionState _screen = SectionState.ready;
  SectionState _notesState = SectionState.loading;
  List<MeetingNote> _notes = const [];
  PendingNoteDelete? _inFlight;
  Future<void>? _commitFuture;
  int _token = 0;
  bool _started = false;
  bool _disposed = false;
  MeetingNotesData? _notesData;

  /// The meeting; `null` while a link without a hint is still loading.
  MeetingEntry? get meeting => _meeting;

  /// The state of the screen as a whole: loading (no header yet), ready, error
  /// or offline; [SectionState.empty] means the meeting is not in the list
  /// any more.
  SectionState get screenState => _screen;

  /// The device has no link.
  bool get offline => !_online.value;

  /// The notes section.
  MeetingNotesData get notes => _notesData ??= _buildNotes();

  MeetingNotesData _buildNotes() {
    if (_notesState != SectionState.ready &&
        _notesState != SectionState.empty) {
      return MeetingNotesData(_notesState);
    }
    final hidden = _hold.pending ?? _inFlight;
    final shown = [
      for (final note in _notes)
        if (hidden == null || note.index != hidden.index) note,
    ];
    return MeetingNotesData(
      shown.isEmpty ? SectionState.empty : SectionState.ready,
      List.unmodifiable(shown),
    );
  }

  void _publish() {
    _notesData = null;
    if (!_disposed) notifyListeners();
  }

  // ── Load ─────────────────────────────────────────────────────────────

  /// Starts the screen; the view calls it once.
  void init() {
    if (_started) return;
    _started = true;
    _screen = _meeting == null ? SectionState.loading : SectionState.ready;
    _online.addListener(_onConnectivity);
    unawaited(_load());
  }

  /// "Tekrar Dene" on the screen or the notes.
  void retry() {
    if (_meeting == null) {
      _screen = SectionState.loading;
    } else {
      _notesState = SectionState.loading;
    }
    _publish();
    unawaited(_load());
  }

  /// Reads the meeting from the server. [quiet] keeps the notes on screen
  /// while it runs (after a write); otherwise they show their skeleton.
  Future<void> _load({bool quiet = false}) async {
    final token = ++_token;
    if (!quiet && _meeting != null) {
      _notesState = SectionState.loading;
      _publish();
    }
    final loaded = await AsyncSection.load<InterviewDto?>(
      () => _unwrap(_locator.find(meetingId, hint: _meeting?.moment)),
      timeout: _timeout,
    );
    if (token != _token || _disposed) return;
    if (loaded.isError || loaded.isOffline) {
      if (_meeting == null) {
        _screen = loaded.state;
      } else {
        _notesState = loaded.state;
      }
      _publish();
      return;
    }
    final found = loaded.data == null
        ? null
        : MeetingEntry.fromDto(loaded.data!);
    if (found == null) {
      _screen = SectionState.empty;
      _publish();
      return;
    }
    _screen = SectionState.ready;
    _meeting = found;
    _notes = found.notes;
    _notesState = SectionState.ready;
    _publish();
  }

  // ── Links ────────────────────────────────────────────────────────────

  /// "Öğrencinin verileri": the student's own data in the coach's view.
  Future<void> openStudentData() {
    final meeting = _meeting;
    final id = meeting?.studentId;
    if (meeting == null || id == null) return Future.value();
    return _navigator.openStudentData(
      studentId: id,
      name: meeting.studentName ?? '',
      photo: meeting.photo,
    );
  }

  // ── Notes ────────────────────────────────────────────────────────────

  /// Whether a note can be written now: the notes are loaded.
  bool get canWrite =>
      _notesState == SectionState.ready || _notesState == SectionState.empty;

  /// "Not Ekle": the sheet, then the note is added.
  Future<void> addNote() async {
    if (!canWrite) return;
    await _settle();
    if (_disposed) return;
    final meeting = _meeting;
    final saved = await _dialogs.writeNote(
      date: meeting?.moment,
      studentName: meeting?.studentName,
      submit: (text) => _saveNew(text),
    );
    if (saved && !_disposed) await _load(quiet: true);
  }

  Future<bool> _saveNew(String text) async {
    final result = await _interviews.addNote(
      interviewId: meetingId,
      note: NoteRules.normalize(text),
    );
    if (result.isLeft()) {
      _toast.error((l) => l.coachMeetings_noteSaveFailed);
      return false;
    }
    _toast.success((l) => l.coachMeetings_noteAdded);
    return true;
  }

  /// "Düzenle" on a note: the sheet with its text, then the note is replaced.
  Future<void> editNote(MeetingNote note) async {
    if (!canWrite) return;
    await _settle();
    final target = _fresh(note);
    if (target == null || _disposed) return;
    final saved = await _dialogs.writeNote(
      initialText: target.text,
      submit: (text) => _saveEdit(target.index, text),
    );
    if (saved && !_disposed) await _load(quiet: true);
  }

  Future<bool> _saveEdit(int index, String text) async {
    final result = await _interviews.editNote(
      interviewId: meetingId,
      index: index,
      note: NoteRules.normalize(text),
    );
    if (result.isLeft()) {
      _toast.error((l) => l.coachMeetings_noteSaveFailed);
      return false;
    }
    _toast.success((l) => l.coachMeetings_noteUpdated);
    return true;
  }

  /// "Sil" on a note: the confirmation, then the note leaves the screen and
  /// its request waits behind "Geri Al".
  Future<void> deleteNote(MeetingNote note) async {
    if (!canWrite) return;
    await _settle();
    final target = _fresh(note);
    if (target == null || _disposed) return;
    final confirmed = await _dialogs.confirmDeleteNote(text: target.text);
    if (!confirmed || _disposed) return;
    _hold.hold(PendingNoteDelete(index: target.index, text: target.text));
    _publish();
    _toast.undo((l) => l.coachMeetings_noteDeleted, onUndo: _undoDelete);
  }

  /// "Geri Al": the note comes back and its request never goes out.
  void _undoDelete() {
    if (_hold.cancel() == null) return;
    _publish();
  }

  Future<void> _commitDelete(PendingNoteDelete note) {
    _inFlight = note;
    return _commitFuture = _runDelete(note);
  }

  Future<void> _runDelete(PendingNoteDelete note) async {
    final result = await _interviews.deleteNote(
      interviewId: meetingId,
      index: note.index,
    );
    if (result.isLeft()) _toast.error((l) => l.coachMeetings_noteDeleteFailed);
    // Whether or not it went through, the screen shows what the server holds.
    _inFlight = null;
    if (_disposed) return;
    await _load(quiet: true);
  }

  /// Sends a waiting deletion and waits for it, so the notes the screen holds
  /// are the server's before a position is used.
  Future<void> _settle() async {
    await _hold.flush();
    await _commitFuture;
  }

  /// [note] as the (fresh) list holds it now: the same position when the text
  /// still matches, else the note with the same text nearest to it; `null`
  /// when it is gone.
  MeetingNote? _fresh(MeetingNote note) {
    MeetingNote? best;
    for (final candidate in _notes) {
      if (candidate.text != note.text) continue;
      if (best == null ||
          (candidate.index - note.index).abs() <
              (best.index - note.index).abs()) {
        best = candidate;
      }
    }
    return best;
  }

  // ── Plumbing ─────────────────────────────────────────────────────────

  void _onConnectivity() => _publish();

  Future<T> _unwrap<T>(Future<AppResult<T>> answer) async =>
      (await answer).fold((AppException failure) => throw failure, (v) => v);

  @override
  void dispose() {
    _disposed = true;
    if (_started) _online.removeListener(_onConnectivity);
    // A deletion that still waits is not lost by leaving the screen.
    unawaited(_hold.flush());
    _hold.dispose();
    super.dispose();
  }
}
