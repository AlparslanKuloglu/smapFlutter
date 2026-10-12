import 'dart:typed_data';

import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';

/// What a stage of the scan can ask of the flow around it: move on, go back,
/// leave. The stages hold this instead of the flow's ViewModel or a router,
/// so a test records the calls (UI guide §6 rule 16).
abstract interface class ScanFlowActions {
  /// The shutter took [photo]: on to the corner screen.
  void captured(ScanPhoto photo);

  /// Back to a fresh camera ("Tekrar Çek", "Yeni Fotoğraf").
  void retake();

  /// "Devam": the area at [quad] was straightened into [flattened]; the
  /// upload starts.
  void flattened(Uint8List flattened, FormQuad quad);

  /// "Vazgeç" on the upload: back to the corners with the photo.
  void backToCorners();

  /// The reader answered with [reading].
  void readFinished(OpticReading reading);

  /// The upload failed for want of a connection (the planned offline screen
  /// takes over when the offline queue is on; otherwise the upload screen's own
  /// failure stays). Returns whether the flow took it.
  bool uploadOffline();

  /// "Şimdi Tekrar Dene" on the offline screen: the upload again.
  void retryUpload();

  /// The checked answers went through and the exam is [examId]: the result.
  void examRecognised(String examId);

  /// The checked answers went through but the exam is not in the system.
  void examUnknown(AnswerReply reply);

  /// Leaves the scan, back to the screen it was opened from.
  void close();

  /// Leaves the scan for Anasayfa ("Anasayfa" after the request).
  void goHome();
}
