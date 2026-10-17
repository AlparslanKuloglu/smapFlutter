import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/config/feature_flags.dart';
import 'package:smap/features/schedule/application/program_summary.dart';
import 'package:smap/features/schedule/application/schedule_service.dart';
import 'package:smap/features/schedule/application/schedule_snapshot.dart';
import 'package:smap/features/schedule/presentation/program_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What the list screen draws (pano 3.4, 3.7).
enum ProgramListPhase {
  /// First load: the title and the search field at once, rows as a skeleton
  /// (pano 3.7 kare 2).
  loading,

  /// Programs to show (pano 3.4).
  content,

  /// The student has no program (pano 3.7 kare 1).
  empty,

  /// The programs could not be loaded and none is saved (pano 3.7 kare 3).
  error,
}

/// The list screen's logic (screen "Programım"; pano 3.4 kare 1 and 2, 3.7).
///
/// The programs come from `ScheduleService`: a snapshot already loaded in the
/// session shows at once (also offline: "Kayıtlı programını görebilirsin"),
/// and a failed refresh never empties it. With no snapshot the first load runs
/// under the 15 s skeleton limit and fails into [ProgramListPhase.error];
/// "Tekrar Dene" returns to the skeleton. When the connection comes back
/// while the list shows an error, it loads again by itself.
///
/// **Coach.** With a [studentId] the list is the student's: every request
/// carries the id, the list runs newest to oldest (this week's program only
/// carries its "Bu hafta" tag, brief T12.4) and the coach may set up a new
/// program while `FeatureFlags.coachProgramWriteEnabled` is on
/// ([coachWriteEnabled]). After a program was saved the coach comes back to
/// the Program tab (brief T12.6): a list that is itself the tab stays on it,
/// a list pushed from it closes ([leaveAfterCreate]); a student's own list
/// opens the new program.
///
/// The search field reports its query (debounced by the field);
/// [visible] is the match list: name and motto, case and Turkish letters
/// folded.
class ProgramListViewModel extends ReactiveViewModel {
  ProgramListViewModel({
    required ScheduleService schedule,
    required ProgramNavigator navigator,
    required ValueListenable<bool> online,
    this.studentId,
    this.readOnly = false,
    this.leaveAfterCreate = false,
    this.coachWriteEnabled = FeatureFlags.coachProgramWriteEnabled,
    DateTime Function()? clock,
  }) : _schedule = schedule,
       _navigator = navigator,
       _online = online,
       _clock = clock ?? DateTime.now {
    _online.addListener(_onConnectivity);
  }

  final ScheduleService _schedule;
  final ProgramNavigator _navigator;
  final ValueListenable<bool> _online;
  final DateTime Function() _clock;

  /// The student whose programs these are; `null` for the signed-in user's
  /// own.
  final String? studentId;

  /// No "Yeni Program": a screen that only reads. A coach is not read only
  /// (Tur 12 A overrules pano 3.4 "Koçta salt okunur"): the Program tab sets
  /// up and edits the student's programs.
  final bool readOnly;

  /// A coach's list that was pushed over the Program tab: it closes after a
  /// program was saved, which is the way back to the tab (brief T12.6).
  final bool leaveAfterCreate;

  /// A coach may write a student's program (`FeatureFlags
  /// .coachProgramWriteEnabled`); off, the list only reads.
  final bool coachWriteEnabled;

  /// A coach looks at a student's programs.
  bool get isCoachView => studentId != null;

  int _revision = 0;
  AsyncSection<ScheduleSnapshot> _load =
      const AsyncSection<ScheduleSnapshot>.loading();
  bool _loading = false;
  bool _disposed = false;
  String _query = '';

  ScheduleSnapshot? _listedFrom;
  DateTime? _listedOn;
  ProgramList _listed = const ProgramList([]);

  @override
  List<ListenableServiceMixin> get listenableServices => [_schedule];

  /// `true` while the device has a link.
  bool get online => _online.value;

  /// Counts the times the screen that owns this list asked to be shown anew
  /// ([refreshView]); the Program tab keys its program section by it.
  int get revision => _revision;

  /// The screen came back from one that may have changed the programs (the
  /// list pushed over the Program tab): whoever keys by [revision] rebuilds.
  void refreshView() {
    _revision++;
    notifyListeners();
  }

  /// The query the list is filtered with (trimmed).
  String get query => _query;

  /// "Yeni Program" and the empty state's action exist.
  bool get canCreate => !readOnly && (!isCoachView || coachWriteEnabled);

  /// "Yeni Program" can be pressed: it needs a connection to save.
  bool get canCreateNow => canCreate && online;

  ProgramListPhase get phase {
    if (_schedule.snapshot(studentId: studentId) != null) {
      return all.isEmpty ? ProgramListPhase.empty : ProgramListPhase.content;
    }
    return switch (_load.state) {
      SectionState.error || SectionState.offline => ProgramListPhase.error,
      _ => ProgramListPhase.loading,
    };
  }

  /// Every program: this week's first, then the newest (a coach's list is
  /// plain newest to oldest).
  ProgramList get all {
    final snapshot = _schedule.snapshot(studentId: studentId);
    if (snapshot == null) return const ProgramList([]);
    final today = _clock();
    final day = DateTime(today.year, today.month, today.day);
    if (!identical(snapshot, _listedFrom) || _listedOn != day) {
      _listed = ProgramList.of(
        snapshot.weeklies,
        today: day,
        thisWeekFirst: !isCoachView,
      );
      _listedFrom = snapshot;
      _listedOn = day;
    }
    return _listed;
  }

  /// The programs that match [query].
  ProgramList get visible => all.matching(_query);

  /// Loads the programs (the first load, or after "Tekrar Dene"). A fresh
  /// snapshot of the session answers at once.
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    _loading = true;
    if (_schedule.snapshot(studentId: studentId) == null) {
      _load = const AsyncSection<ScheduleSnapshot>.loading();
      notifyListeners();
    }
    final result = await AsyncSection.load<ScheduleSnapshot>(() async {
      final answer = await _schedule.load(
        studentId: studentId,
        forceRefresh: force,
      );
      return answer.fold((failure) => throw failure, (snapshot) => snapshot);
    });
    _loading = false;
    if (_disposed) return;
    _load = result;
    notifyListeners();
  }

  /// "Tekrar Dene": back to the skeleton and a new request.
  Future<void> retry() => load(force: true);

  /// The search field's query.
  void setQuery(String value) {
    final next = value.trim();
    if (next == _query) return;
    _query = next;
    notifyListeners();
  }

  /// A row was tapped: the program opens on today (or its first day).
  void openProgram(ProgramSummary program) => _navigator.openDetail(program.id);

  /// "Yeni Program": the full-screen flow. A student's saved program opens
  /// when the flow returns it (pano 13.3: "Programı Kaydet" → Program · gün);
  /// a coach goes back to the Program tab (brief T12.6), where the new
  /// program is in the list.
  Future<void> startNewProgram() async {
    if (!canCreateNow) return;
    final created = await _navigator.openNewProgram();
    if (created == null || _disposed) return;
    if (!isCoachView) {
      _navigator.openDetail(created);
    } else if (leaveAfterCreate) {
      _navigator.close();
    }
  }

  void _onConnectivity() {
    if (_online.value && phase == ProgramListPhase.error) {
      unawaited(load(force: true));
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onConnectivity);
    super.dispose();
  }
}
