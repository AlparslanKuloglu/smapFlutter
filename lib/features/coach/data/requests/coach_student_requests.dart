import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/coach/domain/new_student.dart';

/// The coach's student endpoints as typed requests (`NetworkService.send`).
///
/// Paths, verbs and bodies follow `CoachRepository` and
/// `HomeRepository.fetchMyStudents`. Every call answers the backend's
/// `{success, ...}` frame, kept as a [LegacyEnvelope] for the repository.
abstract final class CoachStudentRequests {
  /// `POST /coach/getMyStudents`, no body. Answers `{students: [...]}`.
  static BaseRequest<LegacyEnvelope> myStudents() =>
      const BaseRequest<LegacyEnvelope>(
        method: HttpMethod.post,
        path: '/coach/getMyStudents',
        decoder: LegacyEnvelope.read,
      );

  /// `GET /ajax/checkUsername?name=<userName>`. Answers `{available}`.
  ///
  /// Not marked as needing a session: the registration form needs the same
  /// check before anybody is signed in. If the server does require one, a
  /// missing session reads as `unauthorized` instead of `sessionExpired`.
  static BaseRequest<LegacyEnvelope> checkUsername(String userName) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/ajax/checkUsername',
        query: <String, dynamic>{'name': userName},
        requiresSession: false,
        decoder: LegacyEnvelope.read,
      );

  /// `POST /coach/addNewStudent` with `{dataObj: {name, surname, userName,
  /// password, seasonType, aimType, photo}}`. Answers `{student}` or
  /// `{userNameUsing: true}`.
  static BaseRequest<LegacyEnvelope> addStudent(NewStudent student) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.post,
        path: '/coach/addNewStudent',
        body: <String, Object>{'dataObj': student.toDataObj()},
        decoder: LegacyEnvelope.read,
      );
}
