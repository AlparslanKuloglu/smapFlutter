import 'dart:async';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/coach/application/coach_code_actions.dart';
import 'package:smap/features/coach/application/coach_students_service.dart';
import 'package:smap/features/coach/application/student_rows.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/presentation/students/students_navigator.dart';
import 'package:smap/l10n/app_localizations.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// What the list of Öğrencilerim draws: the state and, when it is
/// [SectionState.ready], the rows that match the query (a selector value,
/// equal by content).
///
/// [SectionState.empty] means the coach has no student at all (pano 10.2 kare
/// 4); a query that matches nobody is [SectionState.ready] with no [rows] and
/// the query in [query] (kare 3), so the search field stays where it is.
@immutable
class StudentsListData {
  const StudentsListData(
    this.state, {
    this.rows = const [],
    this.query = '',
    this.total = 0,
  });

  final SectionState state;

  /// The rows to show: all of them, or those that match [query].
  final List<StudentRowData> rows;

  /// The query the rows were matched with (trimmed); empty for none.
  final String query;

  /// How many students the coach has, matched or not.
  final int total;

  /// A search ran and nobody matched (pano 10.2 kare 3).
  bool get noMatch =>
      state == SectionState.ready && rows.isEmpty && query.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is StudentsListData &&
      other.state == state &&
      other.query == query &&
      other.total == total &&
      listEquals(other.rows, rows);

  @override
  int get hashCode => Object.hash(state, query, total, Object.hashAll(rows));
}

/// Opens the add-student flow (`AddStudentSheet.show`); the sheet adds the
/// student to the session's list itself and answers the student, or `null`
/// when the coach left without saving.
typedef AddStudentOpener = Future<CoachStudentDto?> Function();

/// The logic of Öğrencilerim (pano 10.2 kare 1 to 4; spec §4.I 10.2; flow
/// 13.11).
///
/// - The students come from the session's [CoachStudentsService], which the
///   coach home and the interview form share: a student added anywhere shows
///   here at once, and a failed refresh never empties a list that is there.
///   The first load is bounded by 15 s: after that the skeleton gives way to
///   the error state (a late answer still fills the list).
/// - Rows are in Turkish alphabetical order (decision 9.3); the search is the
///   client's and folds case and the Turkish marks ("aydin" finds "Kerem
///   Aydın"); it reads the name only. The field reports its query already
///   debounced (150 ms).
/// - No student at all is the empty state with "Öğrenci Ekle" and, when the
///   coach has a coaching code, "Kodunu Paylaş" (nothing is invented without
///   a code).
/// - A row opens the student's profile through the [StudentsNavigator]; the
///   Plus of the band and "Öğrenci Ekle" open the add-student flow.
/// - When the connection comes back while the list shows an error it loads
///   again by itself.
///
/// The ViewModel holds no `BuildContext`: sharing the code goes through the
/// injected [CoachCodeActions]; the sheet is opened by [openAddStudent].
class StudentsViewModel extends ReactiveViewModel {
  StudentsViewModel({
    required CoachStudentsService students,
    required StudentsNavigator navigator,
    required AddStudentOpener openAddStudent,
    required CoachCodeActions codeActions,
    required ValueListenable<bool> online,
    String? Function()? coachCode,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _students = students,
       _navigator = navigator,
       _openAddStudent = openAddStudent,
       _codeActions = codeActions,
       _online = online,
       _coachCode = coachCode ?? _noCode,
       _timeout = timeout;

  static String? _noCode() => null;

  final CoachStudentsService _students;
  final StudentsNavigator _navigator;
  final AddStudentOpener _openAddStudent;
  final CoachCodeActions _codeActions;
  final ValueListenable<bool> _online;
  final String? Function() _coachCode;
  final Duration _timeout;

  String _query = '';
  bool _settled = false;
  bool _started = false;
  bool _disposed = false;
  AppException? _failure;
  StudentsListData? _list;

  List<CoachStudentDto>? _builtFrom;
  List<StudentRowData> _allRows = const [];

  @override
  List<ListenableServiceMixin> get listenableServices => [_students];

  /// The query the list is matched with (trimmed).
  String get query => _query;

  /// The list section: skeleton, rows, "no match", the empty state or the
  /// error state.
  StudentsListData get list => _list ??= _buildList();

  /// The coach's coaching code as the account holds it; `null` without one.
  String? get coachCode {
    final code = _coachCode()?.trim();
    return code == null || code.isEmpty ? null : code;
  }

  /// "Kodunu Paylaş" exists only for a coach who has a code.
  bool get canShareCode => coachCode != null;

  List<StudentRowData> get _rows {
    final source = _students.students;
    if (!identical(source, _builtFrom)) {
      _allRows = StudentRows.build(source);
      _builtFrom = source;
    }
    return _allRows;
  }

  StudentsListData _buildList() {
    if (_students.isLoaded) {
      final all = _rows;
      if (all.isEmpty) return const StudentsListData(SectionState.empty);
      return StudentsListData(
        SectionState.ready,
        rows: StudentRows.search(all, _query),
        query: _query,
        total: all.length,
      );
    }
    if (!_settled) return const StudentsListData(SectionState.loading);
    final failure = _failure;
    return StudentsListData(
      failure != null && failure.isOffline
          ? SectionState.offline
          : SectionState.error,
    );
  }

  @override
  void notifyListeners() {
    _list = null;
    super.notifyListeners();
  }

  /// Starts loading; the view calls it once.
  Future<void> init() async {
    if (_started) return;
    _started = true;
    _online.addListener(_onOnlineChanged);
    await _load();
  }

  /// "Tekrar Dene": back to the skeleton and ask again.
  Future<void> retry() async {
    _settled = false;
    _failure = null;
    notifyListeners();
    await _load(force: true);
  }

  Future<void> _load({bool force = false}) async {
    try {
      final result = await withSkeletonTimeout(
        _students.load(forceRefresh: force),
        timeout: _timeout,
      );
      _failure = result.fold((failure) => failure, (_) => null);
    } on TimeoutException {
      // The skeleton gives way to the error state; a late answer still
      // arrives through the service.
      _failure = null;
    }
    if (_disposed) return;
    _settled = true;
    notifyListeners();
  }

  void _onOnlineChanged() {
    if (_online.value && !_students.isLoaded && _settled) {
      unawaited(retry());
    }
  }

  /// The search field's query (already debounced by the field).
  void setQuery(String value) {
    final next = value.trim();
    if (next == _query) return;
    _query = next;
    notifyListeners();
  }

  /// "Aramayı Temizle".
  void clearSearch() => setQuery('');

  /// A row was tapped: the student's profile opens.
  Future<void> openStudent(StudentRowData student) =>
      _navigator.openStudent(student);

  /// The Plus of the band and "Öğrenci Ekle" of the empty state: the add
  /// sheet. What it saves joins the session's list through the service, and
  /// the list refreshes itself from the server once the coach is done.
  Future<void> addStudent() async {
    await _openAddStudent();
  }

  /// "Kodunu Paylaş": the system share sheet with the code in a sentence;
  /// [origin] anchors an iPad's popover on the button.
  Future<void> shareCode(AppLocalizations l10n, {Rect? origin}) async {
    final code = coachCode;
    if (code == null) return;
    await _codeActions.share(
      l10n.coachWidgets_codeShareText(code),
      origin: origin,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _online.removeListener(_onOnlineChanged);
    super.dispose();
  }
}
