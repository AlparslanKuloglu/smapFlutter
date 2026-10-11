import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/question_status.dart';

void main() {
  group('QuestionOutcome.resolve', () {
    test('the same letter is correct', () {
      expect(
        QuestionOutcome.resolve(marked: 'B', correct: 'B'),
        QuestionOutcome.correct,
      );
    });

    test('a different letter is wrong', () {
      expect(
        QuestionOutcome.resolve(marked: 'C', correct: 'A'),
        QuestionOutcome.wrong,
      );
    });

    test('nothing marked is blank, whatever the key is', () {
      for (final marked in <String?>[null, '', '  ']) {
        expect(
          QuestionOutcome.resolve(marked: marked, correct: 'A'),
          QuestionOutcome.blank,
        );
      }
    });

    test('case and spaces do not matter', () {
      expect(
        QuestionOutcome.resolve(marked: ' a ', correct: 'A'),
        QuestionOutcome.correct,
      );
    });

    test('only wrong and blank tell the right answer', () {
      expect(QuestionOutcome.correct.showsCorrectAnswer, isFalse);
      expect(QuestionOutcome.wrong.showsCorrectAnswer, isTrue);
      expect(QuestionOutcome.blank.showsCorrectAnswer, isTrue);
    });
  });

  group('FormCheckStatus', () {
    test('a correction wins', () {
      expect(
        FormCheckStatus.resolve(read: 'A', correction: 'C'),
        FormCheckStatus.corrected,
      );
      expect(FormCheckStatus.markOf(read: 'A', correction: 'C'), 'C');
    });

    test('a correction on a blank reading is still a correction', () {
      expect(
        FormCheckStatus.resolve(correction: 'B'),
        FormCheckStatus.corrected,
      );
    });

    test('a reading without a correction is read', () {
      expect(FormCheckStatus.resolve(read: 'D'), FormCheckStatus.read);
      expect(FormCheckStatus.markOf(read: 'D'), 'D');
    });

    test('nothing read and no correction is blankRead with no mark', () {
      expect(FormCheckStatus.resolve(), FormCheckStatus.blankRead);
      expect(FormCheckStatus.resolve(read: ' '), FormCheckStatus.blankRead);
      expect(FormCheckStatus.markOf(read: ' '), isNull);
    });
  });
}
