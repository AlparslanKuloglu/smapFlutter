import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/network/network_service.dart';
import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/data/scan_camera.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/data/scan_vision.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_navigator.dart';

import '../../core/network/fake_adapter.dart';

AppException exception(AppErrorCode code) =>
    AppException(code: code, message: code.name);

/// A [ScanRepository] whose three calls answer what the test says.
class FakeScanRepository extends ScanRepository {
  FakeScanRepository()
    : super(
        NetworkService(
          config: AppConfig.resolve(),
          cookieJar: CookieJar(),
          logTraffic: false,
          httpClientAdapter: FakeAdapter((_) => throw StateError('no network')),
        ),
      );

  /// What `readImage` does: report progress, then answer. Set by the test.
  Future<AppResult<OpticReading>> Function(
    Uint8List jpeg,
    ProgressCallback? progress,
    CancelToken? cancel,
  )?
  onRead;

  AppResult<AnswerReply> answers = Left(exception(AppErrorCode.unknown));
  AppResult<Unit> request = const Right(unit);

  /// Holds `sendExamRequest` until completed, to look at the busy state.
  Future<void>? requestGate;

  final List<Uint8List> read = [];
  final List<AnswerCorrections> sentCorrections = [];
  final List<Map<String, dynamic>?> users = [];
  final List<({String publisher, String examName})> requests = [];

  @override
  Future<AppResult<OpticReading>> readImage({
    required Uint8List jpeg,
    required Map<String, dynamic>? user,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) {
    read.add(jpeg);
    users.add(user);
    return onRead!(jpeg, onSendProgress, cancelToken);
  }

  @override
  Future<AppResult<AnswerReply>> sendAnswers({
    required OpticReading reading,
    required AnswerCorrections corrections,
  }) async {
    sentCorrections.add(corrections);
    return answers;
  }

  @override
  Future<AppResult<Unit>> sendExamRequest({
    required String publisherName,
    required String examName,
    required AnswerReply answers,
    required OpticReading reading,
    required Map<String, dynamic>? user,
  }) async {
    requests.add((publisher: publisherName, examName: examName));
    users.add(user);
    await requestGate;
    return request;
  }
}

/// Records what a stage asks of the flow.
class RecordingActions implements ScanFlowActions {
  final List<String> calls = [];
  ScanPhoto? photo;
  Uint8List? flat;
  FormQuad? quad;
  OpticReading? reading;
  AnswerReply? reply;
  String? examId;
  bool offlineAccepted = false;

  @override
  void captured(ScanPhoto photo) {
    calls.add('captured');
    this.photo = photo;
  }

  @override
  void retake() => calls.add('retake');

  @override
  void flattened(Uint8List flattened, FormQuad quad) {
    calls.add('flattened');
    flat = flattened;
    this.quad = quad;
  }

  @override
  void backToCorners() => calls.add('backToCorners');

  @override
  void readFinished(OpticReading reading) {
    calls.add('readFinished');
    this.reading = reading;
  }

  @override
  bool uploadOffline() {
    calls.add('uploadOffline');
    return offlineAccepted;
  }

  @override
  void retryUpload() => calls.add('retryUpload');

  @override
  void examRecognised(String examId) {
    calls.add('examRecognised');
    this.examId = examId;
  }

  @override
  void examUnknown(AnswerReply reply) {
    calls.add('examUnknown');
    this.reply = reply;
  }

  @override
  void close() => calls.add('close');

  @override
  void goHome() => calls.add('goHome');
}

class RecordingNavigator implements ScanNavigator {
  final List<String> calls = [];

  @override
  void close() => calls.add('close');

  @override
  void showResult(String examId) => calls.add('result:$examId');

  @override
  void goHome() => calls.add('home');
}

/// A camera that opens (or fails to) and takes a fixed photo.
class FakeScanCamera implements ScanCamera {
  FakeScanCamera({this.openError, this.photo});

  Object? openError;
  Uint8List? photo;
  int opened = 0;
  final List<FakeCameraSession> sessions = [];

  @override
  Future<ScanCameraSession> open() async {
    opened++;
    if (openError != null) throw ScanCameraException(openError);
    final session = FakeCameraSession(photo ?? Uint8List.fromList([1, 2, 3]));
    sessions.add(session);
    return session;
  }
}

class FakeCameraSession implements ScanCameraSession {
  FakeCameraSession(this.photo);

  final Uint8List photo;
  final ValueNotifier<FormQuad?> form = ValueNotifier<FormQuad?>(null);
  bool disposed = false;
  Object? takeError;

  @override
  Size get previewSize => const Size(720, 1280);

  @override
  ValueListenable<FormQuad?> get liveForm => form;

  @override
  Widget buildPreview() => const SizedBox.shrink();

  @override
  Future<Uint8List> takePicture() async {
    if (takeError != null) throw takeError!;
    return photo;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

/// A vision that finds the form it was given (or none) and "flattens" by
/// returning marker bytes.
class FakeScanVision implements ScanVision {
  DetectedForm? found;
  Uint8List? flat = Uint8List.fromList([7, 7, 7]);
  final List<FormQuad> flattenedWith = [];

  @override
  Future<DetectedForm?> findForm(
    Uint8List picture, {
    Size? pictureSize,
  }) async => found;

  @override
  Future<Uint8List?> flatten(Uint8List picture, FormQuad quad) async {
    flattenedWith.add(quad);
    return flat;
  }
}
