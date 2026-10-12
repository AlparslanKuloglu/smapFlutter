import 'dart:convert';
import 'dart:typed_data';

import 'package:smap/core/network/base_request.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

/// The three optical reading endpoints as typed requests
/// (`NetworkService.send`; spec §4.C 4.5, 4.7, 4.9).
///
/// The bodies are the legacy ones, key for key: a JSON object posted with
/// `Content-Type: application/json`, to the OMR host (`ApiHost.omr`) and
/// without the session (`requiresSession: false`; the old calls were sent
/// unauthenticated, the account travels inside the body as `user`). Whether
/// the host takes a multipart JPEG instead of base64 is an open backend
/// question (spec §6.3 #2); until it is answered the wire format is the old
/// one.
abstract final class ScanRequests {
  static const String _json = 'application/json';

  /// `POST {omr}/opticimage`: `{"image": the base64 JPEG, "user": {…}}`.
  ///
  /// The send timeout is the 60 s of the upload, the receive timeout the
  /// 30 s the reading may take ([SmapDurations]); both are the design's
  /// numbers (pano 4.5 kare 3, spec T2.6), not the 10 s of the old client.
  static BaseRequest<OpticReading> opticImage({
    required Uint8List jpeg,
    required Map<String, dynamic>? user,
  }) => BaseRequest<OpticReading>(
    method: HttpMethod.post,
    path: '/opticimage',
    host: ApiHost.omr,
    requiresSession: false,
    contentType: _json,
    body: <String, dynamic>{'image': base64Encode(jpeg), 'user': ?user},
    sendTimeout: SmapDurations.submitTimeout,
    receiveTimeout: SmapDurations.readTimeout,
    decoder: (data) => OpticReading.fromJson(_object(data)),
  );

  /// `POST {omr}/answerArray`: `{"original_data": the reading, "edits":
  /// {"Kolon 3": {"12": "C"}}}`.
  static BaseRequest<AnswerReply> answerArray({
    required OpticReading reading,
    required Map<String, Map<String, String>> edits,
  }) => BaseRequest<AnswerReply>(
    method: HttpMethod.post,
    path: '/answerArray',
    host: ApiHost.omr,
    requiresSession: false,
    contentType: _json,
    body: <String, dynamic>{
      'original_data': reading.toLegacyJson(),
      'edits': edits,
    },
    sendTimeout: SmapDurations.submitTimeout,
    receiveTimeout: SmapDurations.readTimeout,
    decoder: (data) => AnswerReply.fromJson(_object(data)),
  );

  /// `POST {omr}/examrequest`: `{"publisherName", "examName", "answerData":
  /// the answer with its images, "user": {…}}`; answers `{"success": true}`.
  static BaseRequest<bool> examRequest({
    required String publisherName,
    required String examName,
    required Map<String, dynamic> answerData,
    required Map<String, dynamic>? user,
  }) => BaseRequest<bool>(
    method: HttpMethod.post,
    path: '/examrequest',
    host: ApiHost.omr,
    requiresSession: false,
    contentType: _json,
    body: <String, dynamic>{
      'publisherName': publisherName,
      'examName': examName,
      'answerData': answerData,
      'user': ?user,
    },
    decoder: (data) => _object(data)['success'] != false,
  );

  static Map<String, dynamic> _object(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const FormatException(
      'The reading service did not answer a JSON object.',
    );
  }
}
