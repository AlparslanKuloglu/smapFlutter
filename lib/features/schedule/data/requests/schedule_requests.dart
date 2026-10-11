import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/schedule/data/requests/schedule_wire.dart';
import 'package:smap/features/schedule/domain/weekly_draft.dart';

/// The program endpoints as typed requests (`NetworkService.send`), after
/// `WeeklyRepository`. Every call answers the backend's `{success, ...}`
/// frame, kept as a [LegacyEnvelope] for the repository to read.
///
/// **Coach context.** The legacy repository added `studentId` as a query
/// parameter to every call when it was built for a coach's student; so does
/// each request here when [studentId] is given. Whether the server honours it
/// for writes (a coach editing a student's program) is not confirmed.
abstract final class ScheduleRequests {
  static Map<String, dynamic>? _scope(String? studentId) {
    final id = studentId?.trim();
    if (id == null || id.isEmpty) return null;
    return <String, dynamic>{'studentId': id};
  }

  /// `POST /student/getMyWeeklies` with `{filter: {dates: [...]}}`. Answers
  /// `{weeklies: [...], bagItems: [...]}`. [days] are sent as `yyyy-MM-dd`;
  /// empty means "all" (the only form the legacy code used).
  static BaseRequest<LegacyEnvelope> weeklies({
    String? studentId,
    List<DateTime> days = const [],
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/student/getMyWeeklies',
    query: _scope(studentId),
    body: <String, Object>{
      'filter': <String, Object>{
        'dates': [for (final day in days) formatDayKey(day)],
      },
    },
    decoder: LegacyEnvelope.read,
  );

  /// `GET /student/getAllMainSubjects`. Answers `{subjectsJson}`, an object
  /// whose keys are lesson ids and whose values are lists of main subjects.
  static BaseRequest<LegacyEnvelope> mainSubjects({String? studentId}) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/student/getAllMainSubjects',
        query: _scope(studentId),
        decoder: LegacyEnvelope.read,
      );

  /// `POST /student/addNewProgram` with `{dataObj: {name, motto, tasks}}`.
  static BaseRequest<LegacyEnvelope> addProgram(
    WeeklyDraft draft, {
    String? studentId,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/student/addNewProgram',
    query: _scope(studentId),
    body: <String, Object>{'dataObj': weeklyToDataObj(draft)},
    decoder: LegacyEnvelope.read,
  );

  /// `POST /student/updateProgram` with `{dataObj: {name, motto, tasks,
  /// weeklyId}}`: replaces the whole program.
  static BaseRequest<LegacyEnvelope> updateProgram(
    String weeklyId,
    WeeklyDraft draft, {
    String? studentId,
  }) => BaseRequest<LegacyEnvelope>(
    method: HttpMethod.post,
    path: '/student/updateProgram',
    query: _scope(studentId),
    body: <String, Object>{
      'dataObj': weeklyToDataObj(draft, weeklyId: weeklyId),
    },
    decoder: LegacyEnvelope.read,
  );
}
