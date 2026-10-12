import 'dart:async';
import 'dart:ui' show Rect;

import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/account/application/account_header.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_home_models.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/data/dtos/interview_dtos.dart';
import 'package:smap/features/coach/data/interview_repository.dart';
import 'package:smap/features/coach/domain/attention_item.dart';
import 'package:smap/features/coach/domain/interview_filter.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/services/current_user_service.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The coach home screen's logic (pano 10.1 kare 1 to 4; spec §4.C "10.1";
/// flow 13.11).
///
/// Independent sections, each with its own [SectionState] (the board: "bölüm
/// hataları kendi yerinde"):
///
/// - [students] from `CoachStudentsService` (the session's list, shared with
///   "Öğrencilerim"), alphabetical;
/// - [meetings] from `InterviewRepository`: the interviews of the next seven
///   days, earliest first;
/// - [attention] only when an `AttentionRepository` is given, which is when
///   `FeatureFlags.attentionListEnabled` is open (spec §6.3 #28, #29). Without
///   one the section does not exist: it is not drawn, not even as a skeleton or
///   an empty card.
///
/// The band's data (the first name, the avatar and the coaching code) is on
/// the device; the two counts in its second line come from the sections
/// ([studentCount] once the students are in, [meetingCount] once the meetings
/// are; a failed section leaves its part out). A coach with no student gets the
/// whole page of pano 10.1 kare 3 ([hasNoStudents]) with the coaching code card
/// instead of the sections.
///
/// Every first load is limited to 15 s (`SmapDurations.skeletonTimeout`): no
/// answer by then is the section's error state. A refresh that fails keeps the
/// data on screen. The ViewModel never touches a `BuildContext`: copying and
/// sharing the code go through the injected [CoachCodeActions]; the screens it
/// opens are opened by the view (`coach_home_view.dart`).
class CoachHomeViewModel extends ReactiveViewModel {
  CoachHomeViewModel({
    required CoachStudentsService students,
    required InterviewRepository interviews,
    required CurrentUserService currentUser,
    required CoachCodeActions codeActions,
    AttentionRepository? attention,
    DateTime Function()? clock,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _students = students,
       _interviews = interviews,
       _currentUser = currentUser,
       _codeActions = codeActions,
       _attention = attention,
       _clock = clock ?? DateTime.now,
       _timeout = timeout {
    _derive();
  }

  final CoachStudentsService _students;
  final InterviewRepository _interviews;
  final CurrentUserService _currentUser;
  final CoachCodeActions _codeActions;
  final AttentionRepository? _attention;
  final DateTime Function() _clock;
  final Duration _timeout;

  /// The interviews asked for per page, and the pages read at most, when
  /// looking for the next seven days (the list holds only those days).
  static const int _meetingsPageSize = 24;
  static const int _meetingsMaxPages = 3;

  @override
  List<ListenableServiceMixin> get listenableServices => [
    _students,
    _currentUser,
  ];

  // ── Band ──────────────────────────────────────────────────────────────

  String _firstName = '';
  String? _photo;
  String? _coachCode;

  /// The first word of the coach's name ("Mehmet"): the greeting does not
  /// depend on the hour.
  String get firstName => _firstName;

  /// The coach's avatar file name; `null` draws the initials.
  String? get photo => _photo;

  /// The coaching code as the design writes it (`MOZK-4821`); `null` when the
  /// server did not send one (the code card is then not drawn).
  String? get coachCode => _coachCode;

  /// How many students the coach has; `null` until the list is in.
  int? get studentCount => _studentCount;
  int? _studentCount;

  /// The interviews in the next seven days; `null` until they are in (or when
  /// the load failed).
  int? get meetingCount => _meetingCount;
  int? _meetingCount;

  // ── Öğrencilerin ──────────────────────────────────────────────────────

  AsyncSection<StudentStrip> _studentsSection = const AsyncSection.loading();
  Object? _studentsFailure;
  List<CoachStudentDto>? _stripSource;
  StudentStrip _strip = const StudentStrip([]);

  /// "Öğrencilerin": loading until the list arrives, empty for a coach with
  /// no student (the whole page changes, [hasNoStudents]), ready otherwise.
  AsyncSection<StudentStrip> get students => _studentsSection;

  /// A loaded list with nobody in it: pano 10.1 kare 3.
  bool get hasNoStudents => _studentsSection.isEmpty;

  // ── Dikkat gerektirenler ──────────────────────────────────────────────

  AsyncSection<List<AttentionItem>> _attentionSection =
      const AsyncSection.loading();

  /// Whether the attention list exists on this screen.
  bool get attentionEnabled => _attention != null;

  /// "Dikkat gerektirenler"; always loading and meaningless while
  /// [attentionEnabled] is false (the view does not read it then).
  AsyncSection<List<AttentionItem>> get attention => _attentionSection;

  // ── Yaklaşan görüşmeler ───────────────────────────────────────────────

  List<InterviewDto>? _interviewList;
  Object? _meetingsFailure;
  AsyncSection<UpcomingMeetings> _meetingsSection =
      const AsyncSection.loading();

  /// "Yaklaşan görüşmeler": the rows of the next seven days; empty when there
  /// is none.
  AsyncSection<UpcomingMeetings> get meetings => _meetingsSection;

  bool _studentsBusy = false;
  bool _meetingsBusy = false;
  bool _attentionBusy = false;

  /// Loads the sections; the view calls it once when the screen is built.
  Future<void> init() => Future.wait([
    _loadStudents(),
    _loadMeetings(),
    if (attentionEnabled) _loadAttention(),
  ]);

  /// Pull to refresh: fetches everything again. The selection haptic plays on
  /// release (pano 3.2 "Çekip yenileme: bırakınca selectionClick").
  Future<void> refresh() {
    AppHaptics.selection();
    return Future.wait([
      _loadStudents(force: true),
      _loadMeetings(),
      if (attentionEnabled) _loadAttention(),
    ]);
  }

  /// "Tekrar Dene" of "Öğrencilerin": only this section fetches.
  Future<void> retryStudents() {
    _studentsFailure = null;
    notifyListeners();
    return _loadStudents(force: true);
  }

  /// Reads the student list again after the add-student sheet closed (a new
  /// student joins the strip and the band's count); the sections stay on
  /// screen while it runs.
  Future<void> reloadStudents() => _loadStudents(force: true);

  /// "Tekrar Dene" of "Yaklaşan görüşmeler".
  Future<void> retryMeetings() {
    _meetingsFailure = null;
    notifyListeners();
    return _loadMeetings();
  }

  /// "Tekrar Dene" of "Dikkat gerektirenler".
  Future<void> retryAttention() {
    _attentionSection = const AsyncSection.loading();
    notifyListeners();
    return _loadAttention();
  }

  /// "Kopyala" of the code card: the code on the clipboard and the toast.
  Future<void> copyCode() async {
    final code = _coachCode;
    if (code == null) return;
    await _codeActions.copy(code);
  }

  /// "Paylaş" of the code card: the system share sheet; [origin] is the
  /// button's rectangle (an iPad anchors its popover there).
  Future<void> shareCode(AppLocalizations l10n, {Rect? origin}) async {
    final code = _coachCode;
    if (code == null) return;
    await _codeActions.share(
      l10n.coachWidgets_codeShareText(code),
      origin: origin,
    );
  }

  // ── Loading ───────────────────────────────────────────────────────────

  Future<void> _loadStudents({bool force = false}) async {
    if (_studentsBusy) return;
    _studentsBusy = true;
    try {
      final result = await withSkeletonTimeout(
        _students.load(forceRefresh: force),
        timeout: _timeout,
      );
      _studentsFailure = result.leftOrNull;
    } on Object catch (error) {
      _studentsFailure = error;
    } finally {
      _studentsBusy = false;
    }
    notifyListeners();
  }

  Future<void> _loadMeetings() async {
    if (_meetingsBusy) return;
    _meetingsBusy = true;
    try {
      _interviewList = await withSkeletonTimeout(
        _fetchInterviews(),
        timeout: _timeout,
      );
      _meetingsFailure = null;
    } on Object catch (error) {
      // A failed refresh keeps what is on screen.
      if (_interviewList == null) _meetingsFailure = error;
    } finally {
      _meetingsBusy = false;
    }
    notifyListeners();
  }

  /// The interviews of the next seven days' calendar days, page by page.
  Future<List<InterviewDto>> _fetchInterviews() async {
    final filter = InterviewFilter(dates: UpcomingMeetings.daysOf(_clock()));
    final found = <InterviewDto>[];
    for (var page = 1; page <= _meetingsMaxPages; page++) {
      final result = await _interviews.getInterviews(
        page: page,
        limit: _meetingsPageSize,
        filter: filter,
      );
      final failure = result.leftOrNull;
      if (failure != null) throw failure;
      final fetched = result.rightOrNull!;
      found.addAll(fetched.items);
      if (!fetched.hasMore) break;
    }
    return found;
  }

  Future<void> _loadAttention() async {
    final source = _attention;
    if (source == null || _attentionBusy) return;
    _attentionBusy = true;
    try {
      final result = await withSkeletonTimeout(
        source.getAttentionList(),
        timeout: _timeout,
      );
      _attentionSection = result.fold(
        AsyncSection.failed,
        (items) => items.isEmpty
            ? const AsyncSection.empty()
            : AsyncSection.ready(List.unmodifiable(items)),
      );
    } on Object catch (error) {
      if (!_attentionSection.isReady) {
        _attentionSection = AsyncSection.failed(error);
      }
    } finally {
      _attentionBusy = false;
    }
    notifyListeners();
  }

  // ── Derived state ─────────────────────────────────────────────────────

  /// Works every value the sections read out again from the services; called
  /// on each change so the selectors compare ready-made immutable values.
  @override
  void notifyListeners() {
    if (disposed) return;
    _derive();
    super.notifyListeners();
  }

  void _derive() {
    final user = _currentUser.user;
    _firstName = _firstNameOf(user?.firstName, user?.name);
    _photo = user?.photo;
    _coachCode = user == null ? null : AccountHeader.of(user).coachCode;
    _deriveStudents();
    _deriveMeetings();
  }

  void _deriveStudents() {
    if (_students.isLoaded) {
      final list = _students.students;
      if (!identical(list, _stripSource)) {
        _stripSource = list;
        _strip = StudentStrip.of(_students.sortedStudents);
      }
      _studentCount = list.length;
      _studentsSection = list.isEmpty
          ? const AsyncSection.empty()
          : AsyncSection.ready(_strip);
      return;
    }
    _studentCount = null;
    final failure = _studentsFailure;
    _studentsSection = failure == null
        ? const AsyncSection.loading()
        : AsyncSection.failed(failure);
  }

  void _deriveMeetings() {
    final list = _interviewList;
    if (list == null) {
      _meetingCount = null;
      final failure = _meetingsFailure;
      _meetingsSection = failure == null
          ? const AsyncSection.loading()
          : AsyncSection.failed(failure);
      return;
    }
    final upcoming = UpcomingMeetings.of(
      list,
      _clock(),
      studentOf: _students.byId,
    );
    _meetingCount = upcoming.count;
    _meetingsSection = upcoming.count == 0
        ? const AsyncSection.empty()
        : AsyncSection.ready(upcoming);
  }

  /// "Mehmet Özkan" → "Mehmet"; the profile's `firstName` wins.
  static String _firstNameOf(String? firstName, String? name) {
    final first = firstName?.trim();
    if (first != null && first.isNotEmpty) return first;
    final words = name?.trim().split(RegExp(r'\s+'));
    return words == null || words.isEmpty ? '' : words.first;
  }
}
