import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/new_meeting_flow.dart';
import 'package:smap/features/coach/application/student_profile.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of Öğrenci Profili (pano 10.4; flow 13.11; spec §4.C "10.4").
///
/// - **The student.** The route carries the student's id; the facts (name,
///   login, grade, field) come from the coach's student list
///   (`CoachStudentsService`, shared with "Öğrencilerim"): from what it holds
///   when the student is in it, otherwise it is read first, under the 15 s
///   skeleton limit. A
///   student who is not in the list is [SectionState.empty] ("Öğrenci
///   bulunamadı"), a list that cannot be read is an error with "Tekrar Dene".
///   [initial] is the profile a caller already has (a link from the list), so
///   nothing is read.
/// - **Tabs.** Analiz, Denemeler, Program. A tab is built the first time it
///   is opened and kept afterwards ([visited]), so going back to it shows
///   what it loaded and the scroll position is the page's.
/// - **Görüşme Planla.** The bar action runs the new meeting flow with the
///   student chosen ([NewMeetingFlow]).
///
/// What each tab shows is its own ViewModel (`AnalyticsViewModel` for Analiz
/// and Denemeler, `ProgramListViewModel` and `ProgramDetailViewModel` for
/// Program): every request of them carries the student's id.
class StudentProfileViewModel extends BaseViewModel {
  StudentProfileViewModel({
    required this.studentId,
    required CoachStudentsService students,
    required NewMeetingFlow newMeeting,
    StudentProfile? initial,
    StudentProfileTab initialTab = StudentProfileTab.analysis,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _students = students,
       _newMeeting = newMeeting,
       _timeout = timeout,
       _tab = initialTab,
       _analytics = initialTab == StudentProfileTab.program
           ? StudentProfileTab.analysis
           : initialTab,
       _visited = {initialTab},
       _profile = initial == null
           ? const AsyncSection<StudentProfile>.loading()
           : AsyncSection<StudentProfile>.ready(initial);

  /// The student's Mongo id (route `:studentId`).
  final String studentId;

  final CoachStudentsService _students;
  final NewMeetingFlow _newMeeting;
  final Duration _timeout;

  AsyncSection<StudentProfile> _profile;
  StudentProfileTab _tab;
  StudentProfileTab _analytics;
  final Set<StudentProfileTab> _visited;
  bool _started = false;
  bool _disposed = false;

  /// The student; loading, ready, empty (not in the list) or error.
  AsyncSection<StudentProfile> get profile => _profile;

  /// The tab on show.
  StudentProfileTab get tab => _tab;

  /// The last of Analiz and Denemeler that was on show: the one the shared
  /// analytics body keeps while Program is on show.
  StudentProfileTab get analyticsTab => _analytics;

  /// The tabs that were opened (and are kept built).
  Set<StudentProfileTab> get visited => Set.unmodifiable(_visited);

  /// Starts the screen; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    if (_profile.isLoading) await _load();
  }

  /// "Tekrar Dene" of the screen error: back to the skeleton and a new read
  /// of the list.
  Future<void> retry() async {
    _profile = const AsyncSection<StudentProfile>.loading();
    notifyListeners();
    await _load(force: true);
  }

  Future<void> _load({bool force = false}) async {
    // A list that is already loaded answers at once, also offline (a student
    // the coach just opened from it is there).
    final known = force ? null : _fromList();
    if (known != null) {
      _profile = AsyncSection.ready(known);
      notifyListeners();
      return;
    }
    final next = await AsyncSection.load<StudentProfile?>(() async {
      final loaded = await _students.load(forceRefresh: force);
      return loaded.fold(
        (AppException failure) => throw failure,
        (_) => _fromList(),
      );
    }, timeout: _timeout);
    if (_disposed) return;
    final found = next.data;
    _profile = switch (next.state) {
      SectionState.ready when found != null => AsyncSection.ready(found),
      SectionState.ready || SectionState.empty => const AsyncSection.empty(),
      SectionState.loading => const AsyncSection.loading(),
      SectionState.error => AsyncSection.error(next.error),
      SectionState.offline => const AsyncSection.offline(),
    };
    notifyListeners();
  }

  StudentProfile? _fromList() {
    final dto = _students.byId(studentId);
    return dto == null ? null : StudentProfile.of(dto);
  }

  /// A tab of the bar was tapped.
  void selectTab(StudentProfileTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    if (tab != StudentProfileTab.program) _analytics = tab;
    _visited.add(tab);
    notifyListeners();
  }

  /// "Görüşme Planla": the new meeting sheet with this student chosen. A
  /// saved meeting needs nothing refreshed here (the profile shows no
  /// meetings).
  Future<void> planMeeting() => _newMeeting.run(studentId: studentId);

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
