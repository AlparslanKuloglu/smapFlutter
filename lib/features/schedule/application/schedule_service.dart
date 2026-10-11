import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/schedule/application/schedule_snapshot.dart';
import 'package:smap/features/schedule/application/today_program.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';
import 'package:smap/features/schedule/data/schedule_repository.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// The weekly programs as a reactive value for ViewModels.
///
/// Lives in the `session` DI scope, so it is dropped with the session and can
/// never show the previous user's programs. The programs of the signed-in user
/// and those of each student a coach opens are kept side by side, one
/// [ScheduleSnapshot] per `studentId` (`null` is "my own").
///
/// - [load] answers from the cache while the snapshot is younger than
///   [staleAfter]; otherwise it fetches. A fetch that is already running is
///   joined, not repeated. `forceRefresh: true` (pull to refresh) always
///   fetches. A failed refresh keeps the old snapshot and reports the failure.
/// - Writes ([createWeekly], [updateWeekly]) run one after the other, in the
///   order they were asked, so a burst of "instant save" updates reaches the
///   server in order. A saved program is put into the snapshot at once. When
///   the server does not echo it, the list is fetched again.
/// - The "Çantam" list lives in the snapshot; there is no `SharedPreferences`
///   copy.
///
/// A refresh that starts before a write finishes can overwrite the write's
/// result with older data until the next refresh; screens that save and pull
/// to refresh at the same moment should wait for the write.
///
/// Listen with `ListenableServiceMixin` (`listenToServices`) in a ViewModel.
class ScheduleService with ListenableServiceMixin {
  ScheduleService({
    required ScheduleRepository repository,
    DateTime Function()? clock,
    this.staleAfter = const Duration(minutes: 2),
  }) : _repository = repository,
       _clock = clock ?? DateTime.now {
    listenToReactiveValues([_snapshots]);
  }

  final ScheduleRepository _repository;
  final DateTime Function() _clock;

  /// How long a loaded snapshot counts as current.
  final Duration staleAfter;

  final ReactiveValue<Map<String, ScheduleSnapshot>> _snapshots =
      ReactiveValue<Map<String, ScheduleSnapshot>>(const {});
  final Map<String, Future<AppResult<ScheduleSnapshot>>> _loading = {};
  final Map<String, Map<String, List<MainSubjectDto>>> _subjects = {};
  final Map<String, Future<AppResult<Map<String, List<MainSubjectDto>>>>>
  _loadingSubjects = {};
  Future<void> _writeTail = Future<void>.value();

  static String _key(String? studentId) {
    final id = studentId?.trim();
    return id == null || id.isEmpty ? '' : id;
  }

  static String? _studentOf(String key) => key.isEmpty ? null : key;

  /// The loaded snapshot of [studentId] (`null`: the signed-in user's own),
  /// or `null` before the first successful [load].
  ScheduleSnapshot? snapshot({String? studentId}) =>
      _snapshots.value[_key(studentId)];

  /// The "Bugün" tasks of [now] (default: the clock's today) from the loaded
  /// snapshot; empty before the first load.
  List<ScheduledTask> today({String? studentId, DateTime? now}) =>
      snapshot(studentId: studentId)?.tasksOn(now ?? _clock()) ?? const [];

  /// Loads the programs and the bag (see the class comment for the cache
  /// rules).
  Future<AppResult<ScheduleSnapshot>> load({
    String? studentId,
    bool forceRefresh = false,
  }) {
    final key = _key(studentId);
    final cached = _snapshots.value[key];
    if (!forceRefresh &&
        cached != null &&
        _clock().difference(cached.loadedAt) < staleAfter) {
      return Future.value(Right(cached));
    }
    return _loading[key] ??= _fetch(key);
  }

  /// The main subjects of every lesson, keyed by the lesson's id, for the
  /// topic picker. Cached for the session (the legacy repository cached them
  /// for the life of the screen); `forceRefresh: true` fetches again.
  Future<AppResult<Map<String, List<MainSubjectDto>>>> mainSubjects({
    String? studentId,
    bool forceRefresh = false,
  }) {
    final key = _key(studentId);
    final cached = _subjects[key];
    if (!forceRefresh && cached != null) return Future.value(Right(cached));
    return _loadingSubjects[key] ??= _fetchSubjects(key);
  }

  /// Creates a program from [draft] and returns the created program.
  ///
  /// Fails with `AppErrorCode.server` when the server accepted the program
  /// but neither echoed it nor listed it afterwards.
  Future<AppResult<WeeklyDto>> createWeekly(
    WeeklyDraft draft, {
    String? studentId,
  }) => _serialized(() async {
    final key = _key(studentId);
    final known = _idsOf(key);
    final saved = await _repository.createWeekly(draft, studentId: studentId);
    final failure = saved.leftOrNull;
    if (failure != null) return Left<AppException, WeeklyDto>(failure);
    final echoed = saved.rightOrNull;
    if (echoed != null && echoed.id != null) {
      _store(key, echoed);
      return Right<AppException, WeeklyDto>(echoed);
    }
    final reloaded = await _fetch(key);
    return reloaded.fold(Left.new, (snapshot) {
      for (final weekly in snapshot.weeklies) {
        if (weekly.id != null && !known.contains(weekly.id)) {
          return Right<AppException, WeeklyDto>(weekly);
        }
      }
      return Left<AppException, WeeklyDto>(
        _notListed('/student/addNewProgram'),
      );
    });
  });

  /// Replaces the program [weeklyId] with [draft] (the server has no partial
  /// update) and returns the saved program.
  Future<AppResult<WeeklyDto>> updateWeekly(
    String weeklyId,
    WeeklyDraft draft, {
    String? studentId,
  }) => _serialized(() async {
    final key = _key(studentId);
    final saved = await _repository.updateWeekly(
      weeklyId,
      draft,
      studentId: studentId,
    );
    final failure = saved.leftOrNull;
    if (failure != null) return Left<AppException, WeeklyDto>(failure);
    final echoed = saved.rightOrNull;
    if (echoed != null && echoed.id != null) {
      _store(key, echoed);
      return Right<AppException, WeeklyDto>(echoed);
    }
    final reloaded = await _fetch(key);
    return reloaded.fold(Left.new, (snapshot) {
      final weekly = snapshot.weeklyById(weeklyId);
      return weekly == null
          ? Left<AppException, WeeklyDto>(_notListed('/student/updateProgram'))
          : Right<AppException, WeeklyDto>(weekly);
    });
  });

  /// Marks the snapshot of [studentId] as stale; the next [load] fetches.
  void invalidate({String? studentId}) {
    final key = _key(studentId);
    final cached = _snapshots.value[key];
    if (cached == null) return;
    _snapshots.value = {
      ..._snapshots.value,
      key: cached.copyWith(loadedAt: DateTime.fromMillisecondsSinceEpoch(0)),
    };
  }

  /// Forgets everything (sign-out).
  void clear() {
    _snapshots.value = const {};
    _subjects.clear();
  }

  void dispose() => clear();

  Future<AppResult<ScheduleSnapshot>> _fetch(String key) async {
    try {
      final result = await _repository.getWeeklies(studentId: _studentOf(key));
      return result.map((response) {
        final snapshot = ScheduleSnapshot(
          studentId: _studentOf(key),
          weeklies: List.unmodifiable(response.weeklies),
          bagItems: List.unmodifiable(response.bagItems),
          loadedAt: _clock(),
        );
        _snapshots.value = {..._snapshots.value, key: snapshot};
        return snapshot;
      });
    } finally {
      unawaited(_loading.remove(key));
    }
  }

  Future<AppResult<Map<String, List<MainSubjectDto>>>> _fetchSubjects(
    String key,
  ) async {
    try {
      final result = await _repository.getMainSubjects(
        studentId: _studentOf(key),
      );
      return result.map((subjects) {
        final frozen = <String, List<MainSubjectDto>>{
          for (final entry in subjects.entries)
            entry.key: List<MainSubjectDto>.unmodifiable(entry.value),
        };
        _subjects[key] = frozen;
        return frozen;
      });
    } finally {
      unawaited(_loadingSubjects.remove(key));
    }
  }

  Set<String> _idsOf(String key) => {
    for (final weekly in _snapshots.value[key]?.weeklies ?? const <WeeklyDto>[])
      if (weekly.id != null) weekly.id!,
  };

  /// Puts [saved] into the snapshot of [key]: replaces the program with the
  /// same id, or puts it first. Nothing is cached before the first load.
  void _store(String key, WeeklyDto saved) {
    final snapshot = _snapshots.value[key];
    if (snapshot == null) return;
    final weeklies = [...snapshot.weeklies];
    final index = weeklies.indexWhere((w) => w.id == saved.id);
    if (index >= 0) {
      weeklies[index] = saved;
    } else {
      weeklies.insert(0, saved);
    }
    _snapshots.value = {
      ..._snapshots.value,
      key: snapshot.copyWith(weeklies: List.unmodifiable(weeklies)),
    };
  }

  AppException _notListed(String path) => AppException(
    code: AppErrorCode.server,
    message: 'Saved, but the program is not in the answer or in the list',
    path: path,
  );

  Future<T> _serialized<T>(Future<T> Function() action) {
    final run = _writeTail.then((_) => action());
    _writeTail = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }
}
