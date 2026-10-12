import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/exam_questions_model.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/exams/data/dtos/mock_exam_dto.dart';
import 'package:smap/features/exams/data/mappers/exam_mappers.dart';

import 'exam_detail_fixtures.dart';

void main() {
  final model = ExamQuestionsModel.of(aytDetail());

  group('counters (pano 5.4)', () {
    test('160 questions, 74 wrong, none blank', () {
      expect(model.total, 160);
      expect(model.wrong, 74);
      expect(model.blank, 0);
      expect(model.countOf(QuestionFilter.all), 160);
      expect(model.countOf(QuestionFilter.wrong), 74);
      expect(model.countOf(QuestionFilter.blank), 0);
    });

    test('four tests, 40 questions each', () {
      expect(model.tests.map((t) => t.questionCount), [40, 40, 40, 40]);
      expect(model.isEmpty, isFalse);
    });
  });

  group('filtered', () {
    test('Tümü keeps every test and question', () {
      final all = model.filtered(QuestionFilter.all);
      expect(all, hasLength(4));
      expect(all.first.questions, hasLength(40));
    });

    test('Yanlışlar: the first test shows its 17 wrong ones (kare 2)', () {
      final wrong = model.filtered(QuestionFilter.wrong);
      expect(wrong.first.questions.map((q) => q.order), firstTestWrong);
      expect(wrong.first.questions, hasLength(17));
      expect(
        wrong.first.questions.every((q) => q.outcome == QuestionOutcome.wrong),
        isTrue,
      );
    });

    test('a filtered test keeps its own D/Y/B and question count', () {
      final first = model.filtered(QuestionFilter.wrong).first;
      expect(first.counts.correct, 23);
      expect(first.questionCount, 40);
    });

    test('Boşlar with no blank leaves nothing (kare 3)', () {
      expect(model.filtered(QuestionFilter.blank), isEmpty);
    });

    test('a test with no match under the filter is left out', () {
      final exam = MockExamDto.fromJson({
        ...aytDetailJson(),
        'questionsArrStr':
            '[[{"order":1,"type":3}],[{"order":1,"type":1}],[],[]]',
      }).toDetail()!;
      final small = ExamQuestionsModel.of(exam);
      expect(small.tests.map((t) => t.index), [0, 1]);
      expect(small.filtered(QuestionFilter.wrong).map((t) => t.index), [0]);
    });
  });

  test('no question anywhere is empty (pano 5.8 empty text)', () {
    expect(ExamQuestionsModel.of(tytDetail()).isEmpty, isTrue);
  });

  test('marked and correct letters are not in the data', () {
    final question = model.tests.first.questions.first;
    expect(question.markedOption, isNull);
    expect(question.correctOption, isNull);
  });
}
