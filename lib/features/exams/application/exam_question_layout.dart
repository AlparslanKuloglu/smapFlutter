import 'package:smap/features/analytics/application/net_chart_point.dart';
import 'package:smap/features/lessons/application/lesson_catalog.dart';
import 'package:smap/features/exams/application/exam_cards_model.dart';

/// Which lesson a question belongs to, from its place on the form (pano 5.7:
/// "Türk Dili ve Edebiyatı–Sosyal Bilimler 1 · Tarih"; the board's data note
/// names the AYT order "1–24 Türk Dili ve Edebiyatı, 25–34 Tarih-1, 35–40
/// Coğrafya-1"). Pure.
///
/// The form is cut by the lessons of [ExamLessonCatalog] in their exam order
/// (`mexamOrder`), each with its `totalQuestion`; the two lessons the catalog
/// has no entry for (Felsefe and Din Kültürü, orders 4 and 5 of the TYT
/// Sosyal Bilimler test, 6 and 7 of the AYT Sosyal Bilimler 2 test) fill the
/// gaps. A question outside the cut gets no lesson (nothing is guessed).
abstract final class ExamQuestionLayout {
  /// The lessons of the test at [testIndex] with the questions each has, in
  /// form order.
  static List<({String name, int count, String? id})> lessonsOfTest(
    NetExamType exam,
    int testIndex,
  ) {
    final tests = _testOrders[exam] ?? const <List<int>>[];
    if (testIndex < 0 || testIndex >= tests.length) return const [];
    final orders = tests[testIndex];
    final byOrder = <int, ({String name, int count, String? id})>{
      for (final spec in ExamLessonCatalog.of(exam))
        spec.mexamOrder: (
          name: ExamCardsModel.lessonName(spec),
          count: _questions(spec),
          id: spec.id,
        ),
      for (final gap in (_gaps[exam] ?? const {}).entries)
        gap.key: (name: gap.value.name, count: gap.value.count, id: null),
    };
    return [for (final order in orders) ?byOrder[order]];
  }

  /// The name of the lesson of question [questionOrder] (1-based) of the test
  /// at [testIndex]; `null` when the layout does not cover it.
  static String? lessonNameOf(
    NetExamType exam,
    int testIndex,
    int questionOrder,
  ) => lessonOf(exam, testIndex, questionOrder)?.name;

  /// The lesson of question [questionOrder]: its name and, when the catalog
  /// knows it, its id (what the lesson's card deck takes).
  static ({String name, String? id})? lessonOf(
    NetExamType exam,
    int testIndex,
    int questionOrder,
  ) {
    var from = 1;
    for (final lesson in lessonsOfTest(exam, testIndex)) {
      final to = from + lesson.count - 1;
      if (questionOrder >= from && questionOrder <= to) {
        return (name: lesson.name, id: lesson.id);
      }
      from = to + 1;
    }
    return null;
  }

  /// Questions of a catalog lesson in one exam. The catalog's TYT Tarih and
  /// Coğrafya say 5 each, TYT Matematik 30, TYT Geometri 10: the form's.
  static int _questions(ExamLessonSpec spec) => spec.totalQuestion;

  /// `mexamOrder` of the lessons in each test, by test index.
  static const Map<NetExamType, List<List<int>>> _testOrders = {
    NetExamType.tyt: [
      [1],
      [2, 3, 4, 5],
      [6, 7],
      [8, 9, 10],
    ],
    NetExamType.ayt: [
      [1, 2, 3],
      [4, 5, 6, 7],
      [8, 9],
      [10, 11, 12],
    ],
  };

  /// Lessons of the form that have no catalog entry.
  static const Map<NetExamType, Map<int, ({String name, int count})>> _gaps = {
    NetExamType.tyt: {
      4: (name: 'Felsefe', count: 5),
      5: (name: 'Din Kültürü', count: 5),
    },
    NetExamType.ayt: {
      6: (name: 'Felsefe Grubu', count: 12),
      7: (name: 'Din Kültürü', count: 6),
    },
  };
}
