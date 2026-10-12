import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/scan/application/exam_request_form.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/exam_request/scan_request_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';
import 'package:smap/features/scan/presentation/scan_texts.dart';

/// Where the exam request is.
enum RequestPhase {
  /// The form (pano 4.9 kare 1 to 3).
  form,

  /// "Talebin alındı" (pano 4.9 kare 4).
  sent,
}

/// The logic of "Bu deneme henüz sistemde yok" (pano 4.9; spec §4.C 4.9).
///
/// - Two required fields, the publisher and the exam name. Pressing "Analizimi
///   Hazırlayın" with one empty shows the error under each empty field ("Yayınevini
///   yaz." / "Deneme adını yaz."), plays the `error` haptic and moves the focus
///   to the first of them; the fields do not shake. After that the errors follow
///   what is typed.
/// - With both filled, the confirmation sheet shows what will be sent; "Talebi
///   Gönder" sends the request (publisher, name and the checked answers) and the
///   primary button is busy meanwhile.
/// - Sent: "Talebin alındı", the `success` haptic, and "Anasayfa". A failure
///   keeps the form and shows a toast; nothing is promised about
///   notifications.
class ScanRequestViewModel extends BaseViewModel {
  ScanRequestViewModel({
    required OpticReading reading,
    required AnswerReply reply,
    required ScanRepository repository,
    required Map<String, dynamic>? Function() user,
    required ScanRequestDialogs dialogs,
    required ScanFlowActions actions,
    required ToastService toast,
  }) : _reading = reading,
       _reply = reply,
       _repository = repository,
       _user = user,
       _dialogs = dialogs,
       _actions = actions,
       _toast = toast;

  final OpticReading _reading;
  final AnswerReply _reply;
  final ScanRepository _repository;
  final Map<String, dynamic>? Function() _user;
  final ScanRequestDialogs _dialogs;
  final ScanFlowActions _actions;
  final ToastService _toast;

  ExamRequestForm _form = const ExamRequestForm();
  RequestPhase _phase = RequestPhase.form;
  bool _showErrors = false;
  bool _sending = false;
  bool _submitting = false;
  bool _disposed = false;

  /// Asks the screen to focus a field (after a submit with an error).
  final ValueNotifier<ExamRequestError?> focusRequest =
      ValueNotifier<ExamRequestError?>(null);

  ExamRequestForm get form => _form;
  RequestPhase get phase => _phase;
  bool get sending => _sending;

  /// The publisher field's error; only after the first submit.
  ExamRequestError? get publisherError =>
      _showErrors ? _form.publisherError : null;

  /// The exam name field's error; only after the first submit.
  ExamRequestError? get examNameError =>
      _showErrors ? _form.examNameError : null;

  void publisherChanged(String value) {
    _form = _form.withPublisher(value);
    if (_showErrors) notifyListeners();
  }

  void examNameChanged(String value) {
    _form = _form.withExamName(value);
    if (_showErrors) notifyListeners();
  }

  /// "Analizimi Hazırlayın".
  Future<void> submit() async {
    if (_submitting) return;
    if (!_form.isValid) {
      _showErrors = true;
      AppHaptics.error();
      notifyListeners();
      focusRequest.value = _form.firstError;
      return;
    }
    _submitting = true;
    try {
      final confirmed = await _dialogs.confirmRequest(
        publisher: _form.publisherTrimmed,
        examName: _form.examNameTrimmed,
      );
      if (!confirmed || _disposed) return;
      _sending = true;
      notifyListeners();
      final result = await _repository.sendExamRequest(
        publisherName: _form.publisherTrimmed,
        examName: _form.examNameTrimmed,
        answers: _reply,
        reading: _reading,
        user: _user(),
      );
      if (_disposed) return;
      _sending = false;
      final failure = result.leftOrNull;
      if (failure == null) {
        _phase = RequestPhase.sent;
        AppHaptics.success();
      } else {
        _toast.error((l10n) => scanErrorText(l10n, failure.code));
      }
      notifyListeners();
    } finally {
      _submitting = false;
    }
  }

  /// Kapat.
  void close() => _actions.close();

  /// "Anasayfa".
  void goHome() => _actions.goHome();

  @override
  void dispose() {
    _disposed = true;
    focusRequest.dispose();
    super.dispose();
  }
}
