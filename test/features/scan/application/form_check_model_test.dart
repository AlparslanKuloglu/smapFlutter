import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/scan/application/form_check_model.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

import '../scan_fixtures.dart';

FormCheckModel model() =>
    FormCheckModel(AnswerGrid.parse(sampleAnswerColumns())!);

void main() {
  group('the reading (pano 4.7 kare 1)', () {
    test('160 answers, 2 blank, none corrected', () {
      final m = model();
      expect(m.readCount, 160);
      expect(m.blankCount, 2);
      expect(m.correctionCount, 0);
    });

    test('the 3rd and 4th columns have one blank each, the others none', () {
      final m = model();
      expect([for (var c = 1; c <= 4; c++) m.blanksIn(c)], [0, 0, 1, 1]);
    });

    test('a blank reading is dashed, the others are read', () {
      final m = model();
      expect(m.statusOf(3, 12), FormCheckStatus.blankRead);
      expect(m.markOf(3, 12), isNull);
      expect(m.statusOf(3, 11), FormCheckStatus.read);
      expect(m.markOf(3, 11), isNotNull);
    });

    test('the sheet opens at the first blank, column then question', () {
      expect(model().firstToCheck, const AnswerCell(3, 12));
    });

    test('the sheet opens at the first cell when nothing is blank', () {
      final clean = FormCheckModel(
        AnswerGrid.parse(sampleAnswerColumns(blanks: const {}))!,
      );
      expect(clean.firstToCheck, const AnswerCell(1, 1));
    });
  });

  group('with the corrections (pano 4.7 kare 4)', () {
    FormCheckModel corrected() => model().withCorrections(
      AnswerCorrections.none
          .add(
            const AnswerCell(3, 12),
            read: AnswerChoice.blank,
            to: AnswerChoice.c,
          )
          .add(
            const AnswerCell(4, 31),
            read: AnswerChoice.blank,
            to: AnswerChoice.a,
          ),
    );

    test('fixing both blanks leaves 0 blank and 2 corrections', () {
      final m = corrected();
      expect(m.blankCount, 0);
      expect(m.correctionCount, 2);
      expect([for (var c = 1; c <= 4; c++) m.blanksIn(c)], [0, 0, 0, 0]);
    });

    test('a corrected cell shows the correction', () {
      final m = corrected();
      expect(m.statusOf(3, 12), FormCheckStatus.corrected);
      expect(m.markOf(3, 12), 'C');
      expect(m.markOf(4, 31), 'A');
      expect(m.effective(3, 12), AnswerChoice.c);
    });

    test('a cell corrected to blank counts as a blank and shows the dash', () {
      final m = model().withCorrections(
        AnswerCorrections.none.add(
          const AnswerCell(1, 1),
          read: AnswerChoice.c,
          to: AnswerChoice.blank,
        ),
      );
      expect(m.blankCount, 3);
      expect(m.statusOf(1, 1), FormCheckStatus.corrected);
      expect(m.markOf(1, 1), isNull);
    });

    test('the first cell to check moves past a fixed blank', () {
      final m = model().withCorrections(
        AnswerCorrections.none.add(
          const AnswerCell(3, 12),
          read: AnswerChoice.blank,
          to: AnswerChoice.c,
        ),
      );
      expect(m.firstToCheck, const AnswerCell(4, 31));
    });

    test('compares by content', () {
      expect(corrected(), corrected());
      expect(corrected(), isNot(model()));
    });
  });
}
