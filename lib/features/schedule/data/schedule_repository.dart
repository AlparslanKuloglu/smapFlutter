import 'package:dartz/dartz.dart';

import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/schedule/data/dtos/bag_item_dto.dart';
import 'package:smap/features/schedule/data/dtos/main_subject_dto.dart';
import 'package:smap/features/schedule/data/dtos/weekly_dto.dart';
import 'package:smap/features/schedule/data/dtos/weeklies_response.dart';
import 'package:smap/features/schedule/data/requests/schedule_requests.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// The weekly program endpoints. Answers `Either<AppException, T>`; nothing
/// throws.
///
/// Every method takes an optional [studentId]: a coach reading or writing a
/// student's program passes the student's id, which goes out as the `studentId`
/// query parameter exactly as the legacy `WeeklyRepository` did. A student
/// leaves it out.
///
/// A `success: false` answer is an `AppErrorCode.validation` failure carrying
/// the server's text; an answer that is not the backend's JSON frame is an
/// `AppErrorCode.server` failure.
///
/// Not here, because the backend has no endpoint yet (spec §6.3 #25): deleting
/// a program ("Programı İptal Et"), resetting a day on the server (the editor
/// resets a day in the draft and saves the whole program), partial updates.
class ScheduleRepository {
  ScheduleRepository(this._network);

  final NetworkService _network;

  /// `POST /student/getMyWeeklies`: the programs and the bag. An empty answer
  /// (no programs yet) is a valid value; a missing list reads as empty, like
  /// the legacy code's `?? []`.
  ///
  /// [days] limits the programs to those that touch those days; the legacy
  /// call always sent none and the server's reading of the filter is not
  /// confirmed.
  Future<AppResult<WeekliesResponse>> getWeeklies({
    String? studentId,
    List<DateTime> days = const [],
  }) async {
    const path = '/student/getMyWeeklies';
    final result = await _network.send(
      ScheduleRequests.weeklies(studentId: studentId, days: days),
    );
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      if (failure != null) return Left(failure);
      return Right(
        WeekliesResponse(
          weeklies: envelope.readList('weeklies', WeeklyDto.fromJson) ?? [],
          bagItems: envelope.readList('bagItems', BagItemDto.fromJson) ?? [],
        ),
      );
    });
  }

  /// `GET /student/getAllMainSubjects`: the main subjects of every lesson,
  /// keyed by the lesson's id. Lessons without a list are left out.
  Future<AppResult<Map<String, List<MainSubjectDto>>>> getMainSubjects({
    String? studentId,
  }) async {
    const path = '/student/getAllMainSubjects';
    final result = await _network.send(
      ScheduleRequests.mainSubjects(studentId: studentId),
    );
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      if (failure != null) return Left(failure);
      final raw = envelope.object('subjectsJson');
      if (raw == null) {
        return Left(envelope.unusable(path, 'no subjectsJson'));
      }
      final bySubject = <String, List<MainSubjectDto>>{};
      raw.forEach((lessonId, value) {
        if (value is! List) return;
        final list = <MainSubjectDto>[];
        for (final item in value) {
          if (item is! Map) continue;
          try {
            list.add(MainSubjectDto.fromJson(Map<String, dynamic>.from(item)));
          } on Object {
            continue;
          }
        }
        bySubject[lessonId] = list;
      });
      return Right(bySubject);
    });
  }

  /// `POST /student/addNewProgram`: creates a program from [draft].
  ///
  /// Succeeds with the created program when the answer carries it (`weekly`,
  /// or `data`), and with `null` when the server accepted the program without
  /// echoing it; reload the list then.
  Future<AppResult<WeeklyDto?>> createWeekly(
    WeeklyDraft draft, {
    String? studentId,
  }) => _save(
    '/student/addNewProgram',
    ScheduleRequests.addProgram(draft, studentId: studentId),
  );

  /// `POST /student/updateProgram`: replaces the program [weeklyId] with
  /// [draft] (the server has no partial update). Same answer as
  /// [createWeekly].
  Future<AppResult<WeeklyDto?>> updateWeekly(
    String weeklyId,
    WeeklyDraft draft, {
    String? studentId,
  }) => _save(
    '/student/updateProgram',
    ScheduleRequests.updateProgram(weeklyId, draft, studentId: studentId),
  );

  Future<AppResult<WeeklyDto?>> _save(
    String path,
    BaseRequest<LegacyEnvelope> request,
  ) async {
    final result = await _network.send(request);
    return result.fold(Left.new, (envelope) {
      final failure = _failureOf(envelope, path);
      if (failure != null) return Left(failure);
      final weekly = envelope.object('weekly') ?? envelope.object('data');
      if (weekly == null) return const Right(null);
      try {
        return Right(WeeklyDto.fromJson(weekly));
      } on Object catch (error, stackTrace) {
        return Left(AppException.parse(error, stackTrace, path));
      }
    });
  }

  /// `null` for `success: true`; otherwise the failure the answer stands for.
  AppException? _failureOf(LegacyEnvelope envelope, String path) {
    if (envelope.isSuccess) return null;
    if (envelope.isRejected) return envelope.rejection(path);
    return envelope.unusable(path, 'no success flag');
  }
}
