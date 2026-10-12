import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/exam_request_form.dart';

void main() {
  test(
    'an empty form has both errors, the publisher first (pano 4.9 kare 2)',
    () {
      const form = ExamRequestForm();
      expect(form.publisherError, ExamRequestError.publisherRequired);
      expect(form.examNameError, ExamRequestError.examNameRequired);
      expect(form.firstError, ExamRequestError.publisherRequired);
      expect(form.isValid, isFalse);
    },
  );

  test('blanks only is empty', () {
    final form = const ExamRequestForm()
        .withPublisher('   ')
        .withExamName('\n ');
    expect(form.isValid, isFalse);
  });

  test('the first error follows what is filled', () {
    final form = const ExamRequestForm().withPublisher('Örnek Yayınları');
    expect(form.publisherError, isNull);
    expect(form.firstError, ExamRequestError.examNameRequired);
  });

  test(
    'a filled form is valid and sends the trimmed text (pano 4.9 kare 3)',
    () {
      final form = const ExamRequestForm()
          .withPublisher(' Örnek Yayınları ')
          .withExamName('Türkiye Geneli Deneme 7 ');
      expect(form.isValid, isTrue);
      expect(form.firstError, isNull);
      expect(form.publisherTrimmed, 'Örnek Yayınları');
      expect(form.examNameTrimmed, 'Türkiye Geneli Deneme 7');
    },
  );
}
