import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/scan/data/scan_requests.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

/// The optical reading calls (`opticimage`, `answerArray`, `examrequest`;
/// spec §4.C 4.5 to 4.9) on the app's one [NetworkService].
///
/// Every call returns an [AppResult]; the host is `AppConfig.omrBaseUrl`
/// (a backend question, spec §6.3 #1), never written here. The account the
/// reading belongs to travels in the body as [user], the JSON of the signed-in
/// user (`UserDto.toJson`, the shape the legacy flow read from `user_data`).
class ScanRepository {
  const ScanRepository(this._network);

  final NetworkService _network;

  /// Sends the compressed [jpeg] and returns what the reader found.
  ///
  /// [onSendProgress] reports `(sent, total)` bytes of the upload (pano 4.5
  /// kare 2 "gerçek yükleme yüzdesi"); [cancelToken] stops the call
  /// ("Vazgeç").
  Future<AppResult<OpticReading>> readImage({
    required Uint8List jpeg,
    required Map<String, dynamic>? user,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) => _network.send(
    ScanRequests.opticImage(jpeg: jpeg, user: user),
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
  );

  /// Sends the checked answers: the reading as it came and the student's
  /// [corrections]. The answer says which exam the answers belong to.
  Future<AppResult<AnswerReply>> sendAnswers({
    required OpticReading reading,
    required AnswerCorrections corrections,
  }) => _network.send(
    ScanRequests.answerArray(
      reading: reading,
      edits: corrections.toLegacyEdits(),
    ),
  );

  /// Asks for the analysis of an exam the system does not know (pano 4.9):
  /// the publisher and the name the student wrote, the checked answers and
  /// the account. A body the server refuses (`success: false`) is a failure.
  Future<AppResult<Unit>> sendExamRequest({
    required String publisherName,
    required String examName,
    required AnswerReply answers,
    required OpticReading reading,
    required Map<String, dynamic>? user,
  }) async {
    final result = await _network.send(
      ScanRequests.examRequest(
        publisherName: publisherName,
        examName: examName,
        answerData: answers.toLegacyJson(
          originalImageFileName: reading.originalImageFileName,
          readImageFileName: reading.opticImageFileName,
        ),
        user: user,
      ),
    );
    return result.flatMap(
      (accepted) => accepted
          ? const Right(unit)
          : const Left(
              AppException(
                code: AppErrorCode.server,
                message: 'examrequest answered success: false',
                path: '/examrequest',
              ),
            ),
    );
  }
}
