import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/meeting_list_logic.dart';
import 'package:smap/features/coach/application/meeting_models.dart';
import 'package:smap/features/coach/application/meeting_schedule_logic.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/interview_page.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_dialogs.dart';
import 'package:smap/features/coach/presentation/meetings/meetings_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What the list of Görüşmelerim draws (pano 10.5 kare 1, 4): the state of
/// the first load, and when it is [SectionState.ready] the sections with the
/// footer's state. A selector value, equal by content.
@immutable
class MeetingListData {
  const MeetingListData({
    required this.state,
    this.sections = const MeetingSections(),
    this.hasMore = false,
    this.loadingMore = false,
    this.moreFailed = false,
    this.query = '',
    this.kind = MeetingWith.all,
  });

  /// Loading (skeleton), ready, empty ("Henüz görüşme yok"), error, offline.
  final SectionState state;

  /// The meetings the search and the "Kiminle" choice keep.
  final MeetingSections sections;

  /// Another page may follow.
  final bool hasMore;

  /// The next page is loading: a small spinner under the list.
  final bool loadingMore;

  /// The next page failed: a section error with "Tekrar Dene" under the list.
  final bool moreFailed;

  /// The search text, trimmed.
  final String query;

  /// The "Kiminle" choice.
  final MeetingWith kind;

  @override
  bool operator ==(Object other) =>
      other is MeetingListData &&
      other.state == state &&
      other.sections == sections &&
      other.hasMore == hasMore &&
      other.loadingMore == loadingMore &&
      other.moreFailed == moreFailed &&
      other.query == query &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(
    state,
    sections,
    hasMore,
    loadingMore,
    moreFailed,
    query,
    kind,
  );
}

/// The logic of Görüşmelerim (pano 10.5 kare 1 to 4; flow 13.11).
///
/// - **Load:** `getInterviews` page by page (8 a page), under the 15 s
///   skeleton limit. The "Kiminle" choice goes to the server as
///   `filter.types`, so a change reloads from the first page. A first page
///   that is empty with "Tümü" chosen is [SectionState.empty] (kare 4: no
///   search and no chips, one action).
/// - **Search:** the server has no search parameter (spec §6.3 #31), so the
///   student name is matched here, on the loaded pages, with the Turkish
///   folding of "Öğrencilerim". While a search is on, the remaining pages
///   are fetched in turn (a bounded walk), so the result is the whole list.
/// - **Sections:** "Yaklaşan" (nearest first) and the past ones (newest
///   first), see [MeetingListLogic].
/// - **Yeni görüşme:** the sheet saves the meeting (and its note, which
///   needs a second call: `addNewInterview` takes none); then the list is
///   read again from the first page and the toast says "Görüşme
///   kaydedildi.".
class MeetingsViewModel extends BaseViewModel {
  MeetingsViewModel({
    required InterviewRepository interviews,
    required MeetingsNavigator navigator,
    required MeetingsDialogs dialogs,
    required ToastService toast,
    required ValueListenable<bool> online,
    CoachStudentsService? students,
    DateTime Function()? clock,
    Duration timeout = SmapDurations.skeletonTimeout,
    this.maxSearchPages = 30,
  }) : _interviews = interviews,
       _navigator = navigator,
       _dialogs = dialogs,
       _toast = toast,
       _online = online,
       _students = students,
       _clock = clock ?? DateTime.now,
       _timeout = timeout;

  final InterviewRepository _interviews;
  final MeetingsNavigator _navigator;
  final MeetingsDialogs _dialogs;
  final ToastService _toast;
  final ValueListenable<bool> _online;
  final CoachStudentsService? _students;
  final DateTime Function() _clock;
  final Duration _timeout;

  /// The most pages a search walks to read the whole list.
  final int maxSearchPages;

  SectionState _state = SectionState.loading;
  List<MeetingEntry> _entries = const [];
  int _page = 0;
  bool _hasMore = false;
  bool _loadingMore = false;
  bool _moreFailed = false;
  MeetingWith _kind = MeetingWith.all;
  String _query = '';
  int _token = 0;
  Future<void>? _more;
  bool _creating = false;
  bool _noteFailed = false;
  bool _started = false;
  bool _disposed = false;
  MeetingListData? _data;

  /// The device has no link: the band squares its corners under the offline
  /// strip.
  bool get offline => !_online.value;

  /// Counts up whenever the search text must be cleared in the field ("Aramayı
  /// Temizle"); the page's controller listens.
  final ValueNotifier<int> searchCleared = ValueNotifier<int>(0);

  /// The list section.
  MeetingListData get list => _data ??= _build();

  /// The state of the first load, for the controls above the list.
  SectionState get state => _state;

  /// The "Kiminle" choice.
  MeetingWith get kind => _kind;

  MeetingListData _build() => MeetingListData(
    state: _state,
    sections: _state == SectionState.ready
        ? MeetingListLogic.sections(
            _entries,
            now: _clock(),
            query: _query,
            kind: _kind,
          )
        : const MeetingSections(),
    hasMore: _hasMore,
    loadingMore: _loadingMore,
    moreFailed: _moreFailed,
    query: _query,
    kind: _kind,
  );

  void _publish() {
    _data = null;
    if (!_disposed) notifyListeners();
  }

  // ── Load ─────────────────────────────────────────────────────────────

  /// Starts the screen; the view calls it once.
  void init() {
    if (_started) return;
    _started = true;
    _online.addListener(_onConnectivity);
    unawaited(_reload());
  }

  /// "Tekrar Dene" on the list's error.
  void retry() => unawaited(_reload());

  /// Pull to refresh: the first page again, the list stays while it loads.
  Future<void> refresh() => _reload(skeleton: false);

  InterviewFilter get _filter =>
      InterviewFilter(types: _kind.type == null ? const [] : [_kind.type!]);

  Future<void> _reload({bool skeleton = true}) async {
    final token = ++_token;
    final quiet = !skeleton && _state == SectionState.ready;
    if (!quiet) {
      _state = SectionState.loading;
      _entries = const [];
      _page = 0;
      _hasMore = false;
      _loadingMore = false;
      _moreFailed = false;
      _publish();
    }
    final first = await AsyncSection.load<InterviewPage>(
      () => _unwrap(_interviews.getInterviews(filter: _filter)),
      timeout: _timeout,
    );
    if (token != _token || _disposed) return;
    final page = first.data;
    if (page == null) {
      if (quiet) {
        _toast.error((l) => l.coachMeetings_refreshFailed);
        return;
      }
      _state = first.isOffline ? SectionState.offline : SectionState.error;
      _publish();
      return;
    }
    _entries = _read(page);
    _page = 1;
    _hasMore = page.hasMore;
    _loadingMore = false;
    _moreFailed = false;
    _state = _entries.isEmpty && _kind == MeetingWith.all
        ? SectionState.empty
        : SectionState.ready;
    _publish();
    if (_query.isNotEmpty) unawaited(_loadForSearch());
  }

  List<MeetingEntry> _read(InterviewPage page) => [
    for (final dto in page.items) ?MeetingEntry.fromDto(dto),
  ];

  /// The list reached its end: the next page ("Sonsuz kaydırma, 8'erli
  /// sayfa"). A call while a page is loading joins it; after a failed page
  /// nothing more is asked for until [retryMore] (the screen would otherwise
  /// ask again at every layout).
  Future<void> loadMore() {
    final running = _more;
    if (running != null) return running;
    late final Future<void> mine;
    mine = _loadMore().whenComplete(() {
      if (identical(_more, mine)) _more = null;
    });
    return _more = mine;
  }

  /// The "Tekrar Dene" of a failed page.
  Future<void> retryMore() {
    _moreFailed = false;
    return loadMore();
  }

  Future<void> _loadMore() async {
    if (_state != SectionState.ready || !_hasMore || _moreFailed || _disposed) {
      return;
    }
    final token = _token;
    _loadingMore = true;
    _moreFailed = false;
    _publish();
    final result = await _interviews.getInterviews(
      page: _page + 1,
      filter: _filter,
    );
    if (token != _token || _disposed) return;
    _loadingMore = false;
    result.fold((_) => _moreFailed = true, (page) {
      _entries = MeetingListLogic.merge(_entries, _read(page));
      _page = page.page;
      _hasMore = page.hasMore;
    });
    _publish();
  }

  // ── Search and "Kiminle" ─────────────────────────────────────────────

  /// The search text, after the field's debounce.
  void setQuery(String query) {
    final next = query.trim();
    if (next == _query) return;
    _query = next;
    _publish();
    if (next.isNotEmpty) unawaited(_loadForSearch());
  }

  /// "Aramayı Temizle".
  void clearSearch() {
    searchCleared.value++;
    setQuery('');
  }

  /// A "Kiminle" chip: reloads from the first page with the server filter.
  void selectKind(MeetingWith kind) {
    if (kind == _kind) return;
    _kind = kind;
    unawaited(_reload());
  }

  /// With a search on, reads the pages that are still missing so the result
  /// is the whole list (bounded by [maxSearchPages]).
  Future<void> _loadForSearch() async {
    var walked = 0;
    while (_hasMore &&
        _query.isNotEmpty &&
        _state == SectionState.ready &&
        !_moreFailed &&
        !_disposed &&
        walked++ < maxSearchPages) {
      await loadMore();
    }
  }

  // ── Opening and creating ─────────────────────────────────────────────

  /// A row: Görüşme Detayı.
  Future<void> openMeeting(MeetingEntry meeting) =>
      _navigator.openMeeting(meeting);

  /// The Plus of the band and "Yeni Görüşme": the sheet. [studentId] opens it
  /// with that student chosen (Öğrenci Profili's "Görüşme Planla").
  Future<void> newMeeting({String? studentId}) async {
    if (_creating) return;
    _creating = true;
    try {
      final students = await _loadStudents();
      if (students == null || _disposed) return;
      if (students.isEmpty) {
        _toast.info((l) => l.coachMeetings_noStudents);
        return;
      }
      _noteFailed = false;
      final saved = await _dialogs.newMeeting(
        students: students,
        submit: _save,
        studentId: studentId,
      );
      if (!saved || _disposed) return;
      if (_noteFailed) {
        _toast.error((l) => l.coachMeetings_savedWithoutNote);
      } else {
        _toast.success((l) => l.coachMeetings_saved);
      }
      unawaited(_reload(skeleton: false));
    } finally {
      _creating = false;
    }
  }

  /// The coach's students, in Turkish order; `null` (after a toast) when
  /// they could not be loaded.
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

  // ── Plumbing ─────────────────────────────────────────────────────────

  void _onConnectivity() => _publish();

  /// A repository answer as a value; a failure is thrown for
  /// [AsyncSection.load] to turn into a state.
  Future<T> _unwrap<T>(Future<AppResult<T>> answer) async =>
      (await answer).fold((AppException failure) => throw failure, (v) => v);

  @override
  void dispose() {
    _disposed = true;
    if (_started) _online.removeListener(_onConnectivity);
    searchCleared.dispose();
    super.dispose();
  }
}
