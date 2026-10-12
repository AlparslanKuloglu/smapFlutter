import 'dart:typed_data';

import 'package:stacked/stacked.dart';

import 'package:smap/features/scan/application/form_quad.dart';
import 'package:smap/features/scan/application/scan_flow_state.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_navigator.dart';

/// The state machine of the scan (spec §4.C "Durum makinesi
/// `OmrFlowController`"): which stage is up and what it carries, as a
/// [ScanFlowState], moved by the stages through [ScanFlowActions].
///
/// The flow is one route (`/scan`) whose stages replace one another over a
/// cross-fade: the camera, the corners, the upload, the answer check, the exam
/// request and the errors. The ViewModel holds no byte of its own and no
/// network call: the stages do their work, the photo and the reading travel
/// in the state. Leaving goes through the [ScanNavigator].
class ScanFlowViewModel extends BaseViewModel implements ScanFlowActions {
  ScanFlowViewModel({
    required ScanNavigator navigator,
    required bool offlineQueueEnabled,
  }) : _navigator = navigator,
       _offlineQueueEnabled = offlineQueueEnabled;

  final ScanNavigator _navigator;
  final bool _offlineQueueEnabled;

  ScanFlowState _state = const ScanFlowState();
  int _generation = 0;

  /// Where the scan is.
  ScanFlowState get state => _state;

  /// Counts the camera openings, so a retake builds a fresh camera stage
  /// instead of reusing the old one.
  int get generation => _generation;

  void _go(ScanFlowState next) {
    if (next == _state) return;
    _state = next;
    notifyListeners();
  }

  @override
  void captured(ScanPhoto photo) => _go(_state.captured(photo));

  @override
  void retake() {
    _generation++;
    _go(_state.retake());
    notifyListeners();
  }

  @override
  void flattened(Uint8List flattened, FormQuad quad) =>
      _go(_state.flattenedTo(flattened, quad));

  @override
  void backToCorners() => _go(_state.backToCorners());

  @override
  void readFinished(OpticReading reading) => _go(_state.read(reading));

  @override
  bool uploadOffline() {
    if (!_offlineQueueEnabled || _state.stage != ScanStage.upload) return false;
    _go(_state.offline());
    return true;
  }

  @override
  void retryUpload() => _go(_state.retryUpload());

  @override
  void examRecognised(String examId) => _navigator.showResult(examId);

  @override
  void examUnknown(AnswerReply reply) => _go(_state.examNotFound(reply));

  @override
  void close() => _navigator.close();

  @override
  void goHome() => _navigator.goHome();
}
