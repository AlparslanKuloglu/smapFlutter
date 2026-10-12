import 'package:stacked/stacked.dart';

import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/scan/application/form_check_model.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/data/scan_repository.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/domain/scan_failure.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_dialogs.dart';
import 'package:smap/features/scan/presentation/scan_flow/scan_flow_actions.dart';

/// Where the sending of the checked answers is.
enum ReviewSend {
  /// Nothing sent yet (or the alert was dismissed by trying again).
  idle,

  /// "Gönderiliyor": the primary button is busy.
  sending,

  /// "Cevaplar gönderilemedi…": the inline alert is up.
  failed,
}

/// The logic of "Form Kontrol" (pano 4.7, 4.8; spec §4.C 4.7).
///
/// - **The grid** is the reading with the corrections laid over it
///   ([FormCheckModel]); a column is selected for the grid below the segment
///   (the first column to start with, the first that has a blank when there
///   is one).
/// - **Fixing** opens the sheet at a cell (a tap on the grid) or at the first
///   blank ("Düzelt"); the sheet hands back the corrections as the student
///   left them.
/// - **Confirming** sends the reading with the corrections (`answerArray`)
///   and asks for no second confirmation. The answer tells whether the exam
///   is in the system: yes opens the result, no opens the exam request (pano
///   4.9). A failure keeps everything (corrections and the reading), plays the
///   `error` haptic, shows "Cevaplar gönderilemedi…" (or "Bağlantı yok…" when
///   the device is offline) and turns the primary button into "Tekrar Dene".
/// - **Leaving** with the corrections asks "Okutmadan çıkılsın mı?"; without
///   them it just leaves.
class ScanReviewViewModel extends BaseViewModel {
  ScanReviewViewModel({
    required OpticReading reading,
    required ScanRepository repository,
    required ScanReviewDialogs dialogs,
    required ScanFlowActions actions,
    required this.imageUrl,
  }) : _reading = reading,
       _repository = repository,
       _dialogs = dialogs,
       _actions = actions,
       _model = FormCheckModel(reading.grid!),
       _column = 1 {
    _column = _model.firstToCheck.column;
  }

  final OpticReading _reading;
  final ScanRepository _repository;
  final ScanReviewDialogs _dialogs;
  final ScanFlowActions _actions;

  /// The address of the form image the reader drew on; `null` when the
  /// reading names none.
  final String? imageUrl;

  FormCheckModel _model;
  int _column;
  ReviewSend _send = ReviewSend.idle;
  bool _offline = false;
  bool _disposed = false;

  /// The reading with the corrections over it.
  FormCheckModel get model => _model;

  /// The column the grid shows (1-based).
  int get column => _column;

  ReviewSend get send => _send;

  /// Whether the last failure was for want of a connection.
  bool get offline => _offline;

  /// Whether the buttons are locked (the answers are being sent).
  bool get sending => _send == ReviewSend.sending;

  /// The segment's choice.
  void selectColumn(int column) {
    if (column == _column || column < 1 || column > _model.grid.columnCount) {
      return;
    }
    _column = column;
    notifyListeners();
  }

  /// "Düzelt": the fix sheet at the first blank reading.
  Future<void> fix() => _openFix(_model.firstToCheck);

  /// A tap on a cell of the grid: the fix sheet at that question.
  Future<void> fixCell(int question) => _openFix(AnswerCell(_column, question));

  Future<void> _openFix(AnswerCell start) async {
    if (sending) return;
    final corrections = await _dialogs.fixAnswers(
      grid: _model.grid,
      corrections: _model.corrections,
      start: start,
    );
    if (_disposed) return;
    _model = _model.withCorrections(corrections);
    notifyListeners();
  }

  /// "Cevapları Onayla" (and "Tekrar Dene" after a failure).
  Future<void> confirm() async {
    if (sending) return;
    _send = ReviewSend.sending;
    notifyListeners();
    final result = await _repository.sendAnswers(
      reading: _reading,
      corrections: _model.corrections,
    );
    if (_disposed) return;
    result.fold(
      (exception) {
        final failure = ScanFailure.of(exception);
        _send = ReviewSend.failed;
        _offline = failure.isOffline;
        AppHaptics.error();
        notifyListeners();
      },
      (reply) {
        final examId = reply.examId;
        if (examId != null) {
          _actions.examRecognised(examId);
        } else {
          _actions.examUnknown(reply);
        }
      },
    );
  }

  /// Kapat (and the system Back).
  Future<void> exit() async {
    if (sending) return;
    if (_model.corrections.isEmpty || await _dialogs.confirmExit()) {
      if (!_disposed) _actions.close();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
