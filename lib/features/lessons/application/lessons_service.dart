import 'package:flutter/foundation.dart' show immutable, listEquals;
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/lessons/data/lesson_content_repository.dart';
import 'package:smap/features/lessons/domain/general_lesson.dart';

/// A lesson of the "Derslerin" strip with its missing counts.
@immutable
class LessonEntry {
  const LessonEntry({required this.lesson, this.missing});

  final GeneralLesson lesson;

  /// Missing items per track; `null` when the server has not counted this
  /// lesson (unknown, not zero; `SubjectOrdering` reads null as zero).
  final LessonMissing? missing;

  /// The count of [track]; `null` when unknown.
  int? missingOf(LessonTrack track) => missing?.of(track);

  /// All tracks added up; `null` when unknown.
  int? get totalMissing => missing?.total;

  LessonEntry withMissing(LessonMissing? value) =>
      LessonEntry(lesson: lesson, missing: value);

  @override
  bool operator ==(Object other) =>
      other is LessonEntry &&
      other.lesson == lesson &&
      other.missing == missing;

  @override
  int get hashCode => Object.hash(lesson, missing);
}

/// What [LessonsService] knows right now.
@immutable
class LessonsState {
  const LessonsState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
    this.studentId,
    this.loadedAt,
  });

  /// The lessons in strip order (`GeneralLesson.order`).
  final List<LessonEntry> entries;

  /// A fetch is running. [entries] still hold the earlier data meanwhile
  /// (pull-to-refresh keeps the strip on screen).
  final bool isLoading;

  /// The first failure of the last fetch, `null` after a clean one. [entries]
  /// may still be filled from earlier data: a failed refresh never empties
  /// the strip.
  final AppException? error;

  /// Whose lessons these are: `null` for the signed-in student, else the
  /// student a coach is looking at.
  final String? studentId;

  /// When the lessons last arrived; `null` before the first success.
  final DateTime? loadedAt;

  /// Lessons are known (a first fetch succeeded).
  bool get hasData => loadedAt != null;

  @override
  bool operator ==(Object other) =>
      other is LessonsState &&
      other.isLoading == isLoading &&
      other.error == error &&
      other.studentId == studentId &&
      other.loadedAt == loadedAt &&
      listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(
    isLoading,
    error,
    studentId,
    loadedAt,
    Object.hashAll(entries),
  );
}

/// The lessons of the signed-in user, cached for the session (Rehber §2.3
/// `LessonsService`; board 3.1 "Derslerin", spec §6.3 #21).
///
/// It lives in the `session` DI scope (`registerLessonsSession`), so the next
/// user starts with nothing. Screens listen with `ListenableServiceMixin`
/// (`listenToServices`) and read [state]:
///
/// - [load] shows the cache while it is fresh and fetches otherwise.
/// - [refresh] always fetches (pull-to-refresh, after learning items).
/// - A failed fetch keeps the earlier data and sets `error`.
/// - Lessons and missing counts are fetched together; one failing does not
///   cost the other (lessons without counts show as unknown).
/// - A coach looking at a student passes the student's id; switching students
///   drops the previous student's data first.
class LessonsService with ListenableServiceMixin {
  LessonsService({
    required LessonContentRepository repository,
    this.freshFor = const Duration(minutes: 5),
    DateTime Function()? clock,
  }) : _repository = repository,
       _clock = clock ?? DateTime.now {
    listenToReactiveValues([_state]);
  }

  final LessonContentRepository _repository;
  final DateTime Function() _clock;

  /// How long loaded lessons count as fresh for [load].
  final Duration freshFor;

  final ReactiveValue<LessonsState> _state = ReactiveValue<LessonsState>(
    const LessonsState(),
  );

  Future<void>? _inFlight;
  String? _inFlightStudent;
  int _generation = 0;
  bool _disposed = false;

  LessonsState get state => _state.value;

  List<LessonEntry> get entries => _state.value.entries;

  bool get isLoading => _state.value.isLoading;

  AppException? get error => _state.value.error;

  /// The entry of the general lesson [generalLessonId], or `null`.
  LessonEntry? entryOf(String generalLessonId) {
    for (final entry in entries) {
      if (entry.lesson.id == generalLessonId) return entry;
    }
    return null;
  }

  /// Makes the lessons of [studentId] (`null`: the signed-in student) ready:
  /// returns at once when they are loaded and fresh, otherwise fetches.
  Future<void> load({String? studentId}) {
    final current = _state.value;
    final fresh =
        current.hasData &&
        current.studentId == studentId &&
        current.error == null &&
        _clock().difference(current.loadedAt!) < freshFor;
    if (fresh) return Future.value();
    return refresh(studentId: studentId);
  }

  /// Fetches the lessons and their missing counts again. Calls for the same
  /// student while a fetch is running share it.
  Future<void> refresh({String? studentId}) {
    final running = _inFlight;
    if (running != null && _inFlightStudent == studentId) return running;
    final generation = ++_generation;
    _inFlightStudent = studentId;
    final future = _fetch(studentId, generation).whenComplete(() {
      if (_generation == generation) {
        _inFlight = null;
        _inFlightStudent = null;
      }
    });
    _inFlight = future;
    return future;
  }

  /// Lowers the missing count of [track] of a lesson by one, without a
  /// request: the screen calls it after `markItemLearned` succeeded so the
  /// strip updates at once. Unknown lessons and tracks are left alone.
  void markLearnedLocally(String generalLessonId, LessonTrack track) {
    final current = _state.value;
    final index = current.entries.indexWhere(
      (entry) => entry.lesson.id == generalLessonId,
    );
    if (index < 0) return;
    final entry = current.entries[index];
    final missing = entry.missing;
    if (missing == null) return;
    final updated = missing.withOneLearned(track);
    if (updated == missing) return;
    final entries = [...current.entries]..[index] = entry.withMissing(updated);
    _emit(
      LessonsState(
        entries: entries,
        isLoading: current.isLoading,
        error: current.error,
        studentId: current.studentId,
        loadedAt: current.loadedAt,
      ),
    );
  }

  Future<void> _fetch(String? studentId, int generation) async {
    final before = _state.value;
    final sameStudent = before.studentId == studentId;
    _emit(
      LessonsState(
        // Another student's lessons must never show under this one.
        entries: sameStudent ? before.entries : const [],
        isLoading: true,
        studentId: studentId,
        loadedAt: sameStudent ? before.loadedAt : null,
      ),
    );

    final answers = await (
      _repository.getGeneralLessons(),
      _repository.getLessonsMissing(studentId: studentId),
    ).wait;
    if (_disposed || generation != _generation) return;

    final previous = _state.value;
    final lessons = answers.$1.rightOrNull;
    final missing = answers.$2.rightOrNull;
    final failure = answers.$1.leftOrNull ?? answers.$2.leftOrNull;

    final List<LessonEntry> entries;
    if (lessons != null) {
      final sorted = [...lessons]..sort((a, b) => a.order.compareTo(b.order));
      entries = [
        for (final lesson in sorted)
          LessonEntry(
            lesson: lesson,
            // A failed count keeps the earlier one rather than going unknown.
            missing: missing != null
                ? missing.of(lesson.id)
                : _previousMissing(previous.entries, lesson.id),
          ),
      ];
    } else if (missing != null) {
      entries = [
        for (final entry in previous.entries)
          entry.withMissing(missing.of(entry.lesson.id)),
      ];
    } else {
      entries = previous.entries;
    }

    _emit(
      LessonsState(
        entries: entries,
        error: failure,
        studentId: studentId,
        loadedAt: lessons != null ? _clock() : previous.loadedAt,
      ),
    );
  }

  static LessonMissing? _previousMissing(
    List<LessonEntry> entries,
    String lessonId,
  ) {
    for (final entry in entries) {
      if (entry.lesson.id == lessonId) return entry.missing;
    }
    return null;
  }

  void _emit(LessonsState next) {
    if (_disposed) return;
    _state.value = next;
  }

  /// Stops delivering results of fetches that are still running.
  void dispose() => _disposed = true;
}
