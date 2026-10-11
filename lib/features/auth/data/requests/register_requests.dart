import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/network/base_request.dart';
import 'package:smap/features/auth/data/dtos/new_registration.dart';

/// The sign-up endpoint as a typed request (`NetworkService.send`).
abstract final class RegisterRequests {
  /// Whether the body also carries `acceptedTermsVersion`,
  /// `acceptedKvkkVersion` and `acceptedPrivacyVersion`.
  ///
  /// The legacy `RegisterNotifier` added them to its payload, but
  /// `AuthRemoteDataSource.register` rebuilt the body from `userType` and
  /// `data` only, so the real legacy wire never held them. They are sent now
  /// (the design records consent by version, spec §6.3 #13) as top-level
  /// fields. Set to `false` to put the wire back exactly as the legacy had
  /// it, if the backend turns out to refuse unknown fields.
  static const bool sendAcceptedVersions = true;

  /// `POST /student/register` with [registration]'s body.
  ///
  /// Public call: a 401 is not "session expired". The legacy call accepted a
  /// 200, a 201 or a 302 as long as the body said `success: true`; 2xx and 302
  /// are listed here and the repository reads the body. Timeouts: the legacy
  /// call used 8 s; this one gives a slow phone connection 15 s, like login.
  static BaseRequest<LegacyEnvelope> register(NewRegistration registration) =>
      BaseRequest<LegacyEnvelope>(
        method: HttpMethod.post,
        path: '/student/register',
        body: registration.toBody(withAcceptedVersions: sendAcceptedVersions),
        requiresSession: false,
        successStatuses: const {302},
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        decoder: LegacyEnvelope.read,
      );
}
