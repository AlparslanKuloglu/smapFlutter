import 'dart:async';

import 'package:stacked/stacked.dart';

import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/theme/app_motion.dart';
import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/data/exam_repository.dart';
import 'package:smap/features/exams/domain/ayt_field.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/domain/exam_summary.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_loader.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_model.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_navigator.dart';
import 'package:smap/shared/ui/feedback/section_state.dart';

/// The logic of the result moment (pano 5.1 and 5.2; flow 13.4 step 14 and
/// 15; spec §4.D).
///
/// - The **result** comes from the Denemelerim list ([ResultMomentLoader]:
///   the result and the net of the exam before it), bounded by 15 s; only
///   this load can fail the screen. The **card count** (`getTotalInfoCard`)
///   loads beside it and only ever adds its row: when it fails, times out or
///   says zero the row is not drawn (spec 5.1 "yanıtta yoksa satır yok").
/// - [AppHaptics.success] plays **once**, when the result first shows ("Gelişte
///   bir kez success"); an error screen, a retry that fails again or the
///   segment never replay it. No spinning number, no confetti.
/// - The "Puan türü" segment opens on the student's own field ([userField]);
///   choosing another one only swaps the boxes and the field's net.
/// - Leaving (Anasayfa, Detaylı Analiz, the cards row, the close button and
///   the system Back) first offers the notification permission sheet when it
///   is due ([NotificationPrimer]: once, on the first successful read, only
///   while notifications are enabled), then goes on to the destination.
///
/// The destination buttons work in every state (the detail reads the result
/// itself when the moment could not).
class ResultMomentViewModel extends BaseViewModel {
  ResultMomentViewModel({
    required this.examId,
    required ExamRepository exams,
    required ResultMomentNavigator navigator,
    required NotificationPrimer primer,
    required this.cdnBaseUrl,
    this.userField,
    ResultMomentLoader? loader,
    void Function() onArrive = AppHaptics.success,
    void Function() onRetryFailed = AppHaptics.error,
    Duration timeout = SmapDurations.skeletonTimeout,
  }) : _exams = exams,
       _navigator = navigator,
       _primer = primer,
       _loader = loader ?? ResultMomentLoader(exams),
       _onArrive = onArrive,
       _onRetryFailed = onRetryFailed,
       _timeout = timeout;

  /// The result's id (route `:examId`).
  final String examId;

  /// Where the covers live (`AppConfig.cdnBaseUrl`).
  final String cdnBaseUrl;

  /// The signed-in student's AYT field; `null` when unknown.
  final AytField? userField;

  final ExamRepository _exams;
  final ResultMomentNavigator _navigator;
  final NotificationPrimer _primer;
  final ResultMomentLoader _loader;
  final void Function() _onArrive;
  final void Function() _onRetryFailed;
  final Duration _timeout;

  bool _started = false;
  bool _disposed = false;
  bool _retrying = false;
  bool _arrived = false;
  bool _leaving = false;

  AsyncSection<ResultMomentModel> _moment =
      const AsyncSection<ResultMomentModel>.loading();
  ExamDetail? _detail;
  AytField? _selectedField;
  int? _cardTotal;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  // ── Result ───────────────────────────────────────────────────────────

  /// The state of the result: it decides the skeleton, the content and the
  /// error screen.
  SectionState get screenState => _moment.state;

  /// What the moment draws; `null` until the result is here.
  ResultMomentModel? get model => _moment.data;

  /// The cover's full URL; `null` without a cover or a result.
  String? get coverUrl => model == null
      ? null
      : ExamDefinition(imageFile: model!.coverFile).imageUrl(cdnBaseUrl);

  /// The exam's name as it heads the screen: the server's, else "AYT
  /// denemesi" is the view's to write (`null` here).
  String? get examName => model?.name;

  /// Starts the screen: reads the result and the card count.
  void init() {
    if (_started) return;
    _started = true;
    unawaited(_loadMoment());
    unawaited(_loadCards());
  }

  /// "Tekrar Dene" of the screen error: back to the skeleton; a repeated
  /// failure plays the error haptic (pano 5.8 "Hareket ve haptik").
  Future<void> retry() {
    _retrying = true;
    return _loadMoment();
  }

  Future<void> _loadMoment() async {
    _moment = const AsyncSection<ResultMomentModel>.loading();
    notifyListeners();
    ExamDetail? detail;
    final next = await AsyncSection.load<ResultMomentModel>(() async {
      final source = await _unwrap(_loader.load(examId));
      final read = ResultMomentModel.of(
        source.exam,
        previousNet: source.previousNet,
        userField: userField,
      );
      if (read == null) {
        throw const AppException(
          code: AppErrorCode.unknown,
          message: 'The result has no net, D/Y/B or date to draw',
        );
      }
      detail = source.exam;
      return read;
    }, timeout: _timeout);
    if (_disposed) return;
    _moment = next;
    _detail = next.isReady ? detail : null;
    _selectedField = next.data?.defaultField;
    if ((next.isError || next.isOffline) && _retrying) _onRetryFailed();
    _retrying = false;
    notifyListeners();
    if (next.isReady && !_arrived) {
      _arrived = true;
      _onArrive();
    }
  }

  // ── Puan türü ────────────────────────────────────────────────────────

  /// The segment on show; `null` when the result has no score type.
  AytField? get selectedField => _selectedField;

  /// What the boxes and the field's net draw now.
  MomentScore get score => model?.scoreFor(_selectedField) ?? MomentScore.none;

  /// A "Puan türü" option was chosen (the segment plays the selection
  /// haptic).
  void selectField(AytField field) {
    if (field == _selectedField) return;
    _selectedField = field;
    notifyListeners();
  }

  // ── Kart sayısı ──────────────────────────────────────────────────────

  /// The cards the exam added; `null` while unknown, when the request failed
  /// or when none were added (the row is not drawn).
  int? get cardTotal => _cardTotal;

  Future<void> _loadCards() async {
    int? total;
    try {
      final answer = await _exams
          .getEarnedCardCounts(examId: examId)
          .timeout(_timeout);
      total = answer.rightOrNull?.total;
    } on Object {
      total = null;
    }
    if (_disposed) return;
    _cardTotal = total != null && total > 0 ? total : null;
    notifyListeners();
  }

  // ── Leaving ──────────────────────────────────────────────────────────

  /// "Detaylı Analiz": Deneme Detay, Genel.
  Future<void> openDetail() =>
      _leave(() => _navigator.openExamDetail(examId: examId, exam: _detail));

  /// The cards row: Deneme Detay, Kartlar.
  Future<void> openCards() => _leave(
    () => _navigator.openExamDetail(
      examId: examId,
      exam: _detail,
      tab: ExamDetailTab.cards,
    ),
  );

  /// "Anasayfa", the close button and the system Back: Anasayfa.
  Future<void> openHome() => _leave(_navigator.openHome);

  Future<void> _leave(Future<void> Function() go) async {
    if (_leaving) return;
    _leaving = true;
    try {
      await _primer.offer();
      if (_disposed) return;
      await go();
    } finally {
      _leaving = false;
    }
  }

  static Future<T> _unwrap<T>(Future<AppResult<T>> future) async {
    final result = await future;
    return result.fold<T>(
      (AppException failure) => throw failure,
      (value) => value,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
