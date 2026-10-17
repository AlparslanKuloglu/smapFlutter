import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/coach/application/student_list_logic.dart';
import 'package:smap/features/coach/data/add_student_outcome.dart';
import 'package:smap/features/coach/data/coach_student_repository.dart';
import 'package:smap/features/coach/data/dtos/coach_student_dto.dart';
import 'package:smap/features/coach/domain/new_student.dart';
import 'package:smap/features/coach/domain/username_check.dart';

/// The coach's students as a reactive value for ViewModels. Coach only: touch
/// it from the coach shell, never from the student side.
///
/// Lives in the `session` DI scope, so it is dropped with the session and can
/// never show the previous coach's students. Several screens need the same
/// list (home, "Öğrencilerim", the interview form's student picker), so it is
/// loaded once and shared:
///
/// - [load] answers from the cache while it is younger than [staleAfter] and
///   fetches otherwise; a refresh that is already running is joined, not
///   repeated. `forceRefresh: true` (pull to refresh) always fetches.
/// - A failed refresh keeps the previous list and reports the failure.
/// - [addStudent] puts the created student into the list.
///
/// Listen with `ListenableServiceMixin` (`listenToServices`) in a ViewModel.
class CoachStudentsService with ListenableServiceMixin {
  CoachStudentsService({
    required CoachStudentRepository repository,
    DateTime Function()? clock,
    this.staleAfter = const Duration(minutes: 5),
  }) : _repository = repository,
       _clock = clock ?? DateTime.now {
    listenToReactiveValues([_students, _loadedAt]);
  }

  final CoachStudentRepository _repository;
  final DateTime Function() _clock;

  /// How long a loaded list counts as current.
  final Duration staleAfter;

  final ReactiveValue<List<CoachStudentDto>?> _students =
      ReactiveValue<List<CoachStudentDto>?>(null);
  final ReactiveValue<DateTime?> _loadedAt = ReactiveValue<DateTime?>(null);

  Future<AppResult<List<CoachStudentDto>>>? _inFlight;

  /// The students in server order; empty until the first load succeeds.
  List<CoachStudentDto> get students => _students.value ?? const [];

  /// The students in Turkish alphabetical order.
  List<CoachStudentDto> get sortedStudents => sortStudentsByName(students);

  /// `true` once a load has succeeded (an empty list included).
  bool get isLoaded => _students.value != null;

  /// When the list was last loaded.
  DateTime? get loadedAt => _loadedAt.value;

  /// The student with [id], or `null`.
  CoachStudentDto? byId(String id) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  /// The loaded students whose name matches [query]
  /// (see [searchStudents]); alphabetical.
  List<CoachStudentDto> search(String query) =>
      searchStudents(sortedStudents, query);

  /// Loads the list (see the class comment for the cache rules).
  Future<AppResult<List<CoachStudentDto>>> load({bool forceRefresh = false}) {
    final loadedAt = _loadedAt.value;
    final cached = _students.value;
    if (!forceRefresh &&
        cached != null &&
        loadedAt != null &&
        _clock().difference(loadedAt) < staleAfter) {
      return Future.value(Right(cached));
    }
    return _inFlight ??= _fetch();
  }

  /// Checks that [userName] is free (not cached).
  Future<AppResult<UsernameCheck>> checkUsername(String userName) =>
      _repository.checkUsername(userName);

  /// Creates the student; a created one joins the list at the end.
  ///
  /// The avatar the coach chose (Tur 12 D, pano 14.8 kare 3) shows in the list
  /// at once: when the server's answer carries no `photo`, the file name that
  /// was sent stands in until the next refresh. The outcome returned is the
  /// one that joined the list.
  Future<AppResult<AddStudentOutcome>> addStudent(NewStudent input) async {
    final result = await _repository.addStudent(input);
    return result.map((outcome) {
      if (outcome is! StudentAdded) return outcome;
      final created = outcome.student;
      final sent = input.photo?.trim().split('/').last;
      final joined =
          (created.photo?.trim().isNotEmpty ?? false) ||
              sent == null ||
              sent.isEmpty
          ? created
          : created.copyWith(photo: sent);
      _students.value = [...students, joined];
      return identical(joined, created) ? outcome : StudentAdded(joined);
    });
  }

  /// Forgets the list; the next [load] fetches.
  void invalidate() {
    _loadedAt.value = null;
  }

  /// Forgets everything (sign-out).
  void clear() {
    _students.value = null;
    _loadedAt.value = null;
  }

  void dispose() => clear();

  Future<AppResult<List<CoachStudentDto>>> _fetch() async {
    try {
      final result = await _repository.getMyStudents();
      return result.map((list) {
        final stored = List<CoachStudentDto>.unmodifiable(list);
        _students.value = stored;
        _loadedAt.value = _clock();
        return stored;
      });
    } finally {
      _inFlight = null;
    }
  }
}
