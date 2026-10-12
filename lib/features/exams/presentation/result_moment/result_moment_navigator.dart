import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';

/// Where the result moment leads (flow 13.4 step 14 to 13.6; spec §3.6 "Ayrılırken
/// `go`"): the ViewModel calls this, not a router, so a test can record the
/// calls.
abstract interface class ResultMomentNavigator {
  /// Deneme Detay of [examId] on the Analizlerim stack, [tab] open ("Detaylı
  /// Analiz" opens Genel, the cards row opens Kartlar). The camera flow is
  /// closed on the way (spec T3.1: "sonuç anından açılınca kamera akışı
  /// kapanır ve ekran Analizlerim yığınına yerleşir"). [exam] is the result
  /// the moment already read, so the detail needs no second request.
  Future<void> openExamDetail({
    required String examId,
    ExamDetail? exam,
    ExamDetailTab tab = ExamDetailTab.general,
  });

  /// Anasayfa ("Anasayfa" and the close button): the camera flow is closed and
  /// the Anasayfa tab opens.
  Future<void> openHome();
}
