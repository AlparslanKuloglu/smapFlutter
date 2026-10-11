import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/account/domain/profile_update.dart';

/// The account endpoints as typed requests (`NetworkService.send`).
///
/// Paths, verbs and parameter names follow `ProfileRepository` and the legacy
/// `AuthRemoteDataSource`. Every call answers the backend's `{success, ...}`
/// frame, kept as a [LegacyEnvelope] for the repository to read.
abstract final class AccountRequests {
  /// `POST /student/updateStudent`: the changed profile fields as a flat JSON
  /// body (not wrapped in `dataObj`). Answers `{success, student}`.
  static BaseRequest<LegacyEnvelope> updateStudent(ProfileUpdate update) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.post,
        path: '/student/updateStudent',
        body: update.toBody(),
        decoder: LegacyEnvelope.read,
      );

  /// `GET /ajax/getLegalDocuments`. A public call (the registration screen
  /// shows the texts before there is a session). The answer is a bare list or
  /// `{data: [...]}`, so the raw body is kept.
  static BaseRequest<Object?> getLegalDocuments() => BaseRequest<Object?>(
    method: HttpMethod.get,
    path: '/ajax/getLegalDocuments',
    requiresSession: false,
    decoder: (data) => data,
  );

  /// `GET /ajax/deleteAccount`. Answers `{success, msg}`.
  static BaseRequest<LegacyEnvelope> deleteAccount() =>
      const BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/ajax/deleteAccount',
        decoder: LegacyEnvelope.read,
      );

  /// `GET /student/getStudentsCoach`: the signed-in student's coach.
  static BaseRequest<LegacyEnvelope> getStudentsCoach() =>
      const BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/student/getStudentsCoach',
        decoder: LegacyEnvelope.read,
      );

  /// `GET /student/addCoach?code=<refCode>`. Answers `{success, coach}`.
  static BaseRequest<LegacyEnvelope> addCoach(String refCode) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/student/addCoach',
        query: <String, dynamic>{'code': refCode},
        decoder: LegacyEnvelope.read,
      );

  /// `GET /student/deleteCoach?coach=<coachId>`.
  ///
  /// The legacy call built `{'coach': coachId}` and then forgot to send it;
  /// the parameter name is the one that code intended (spec §6.3 #15).
  static BaseRequest<LegacyEnvelope> deleteCoach(String coachId) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.get,
        path: '/student/deleteCoach',
        query: <String, dynamic>{'coach': coachId},
        decoder: LegacyEnvelope.read,
      );
}
