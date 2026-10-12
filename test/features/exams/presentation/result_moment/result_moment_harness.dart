import 'package:smap/features/exams/application/exam_detail_model.dart';
import 'package:smap/features/exams/domain/exam_detail.dart';
import 'package:smap/features/exams/presentation/notification_primer/notification_primer.dart';
import 'package:smap/features/exams/presentation/result_moment/result_moment_navigator.dart';

/// The "was it asked" flag in memory; counts its writes.
class MemoryPrimerFlag implements NotificationPrimerFlag {
  MemoryPrimerFlag({this.shown = false});

  @override
  bool shown;

  int writes = 0;

  @override
  Future<void> markShown() async {
    writes++;
    shown = true;
  }
}

/// Writes "sheet" to [log] when the sheet would open and remembers what the
/// flag said at that moment.
class RecordingPrimerPresenter implements NotificationPrimerPresenter {
  RecordingPrimerPresenter(this.log, {this.flag});

  final List<String> log;
  final MemoryPrimerFlag? flag;
  bool? flagWhenShown;

  @override
  Future<void> show() async {
    flagWhenShown = flag?.shown;
    log.add('sheet');
  }
}

/// Records where the result moment leads, in the same [log] as the sheet so
/// the order can be read.
class RecordingMomentNavigator implements ResultMomentNavigator {
  RecordingMomentNavigator(this.log);

  final List<String> log;
  final List<ExamDetail?> openedExams = [];

  @override
  Future<void> openExamDetail({
    required String examId,
    ExamDetail? exam,
    ExamDetailTab tab = ExamDetailTab.general,
  }) async {
    openedExams.add(exam);
    log.add('detail:$examId:${tab.key}');
  }

  @override
  Future<void> openHome() async => log.add('home');
}
