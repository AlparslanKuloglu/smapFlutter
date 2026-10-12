import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

void main() {
  const c3q12 = AnswerCell(3, 12);
  const c4q31 = AnswerCell(4, 31);

  group('AnswerCorrections', () {
    test('lists the newest correction first (pano 4.7 kare 3)', () {
      final corrections = AnswerCorrections.none
          .add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c)
          .add(c4q31, read: AnswerChoice.blank, to: AnswerChoice.a);
      expect(corrections.count, 2);
      expect(corrections.items.map((c) => c.cell), [c4q31, c3q12]);
      expect(corrections.items.first.from, AnswerChoice.blank);
      expect(corrections.items.first.to, AnswerChoice.a);
    });

    test('correcting a cell again replaces its correction', () {
      final corrections = AnswerCorrections.none
          .add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c)
          .add(c4q31, read: AnswerChoice.blank, to: AnswerChoice.a)
          .add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.e);
      expect(corrections.count, 2);
      expect(corrections.of(c3q12)!.to, AnswerChoice.e);
      expect(corrections.items.first.cell, c3q12);
    });

    test('correcting to what the reader found removes the correction', () {
      final corrections = AnswerCorrections.none
          .add(c3q12, read: AnswerChoice.b, to: AnswerChoice.c)
          .add(c3q12, read: AnswerChoice.b, to: AnswerChoice.b);
      expect(corrections.isEmpty, isTrue);
      expect(
        AnswerCorrections.none
            .add(c3q12, read: AnswerChoice.b, to: AnswerChoice.b)
            .isEmpty,
        isTrue,
      );
    });

    test('a correction can be taken back', () {
      final corrections = AnswerCorrections.none
          .add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c)
          .remove(c3q12);
      expect(corrections.isEmpty, isTrue);
      expect(corrections.of(c3q12), isNull);
    });

    test('writes the edits of the old answerArray body', () {
      final corrections = AnswerCorrections.none
          .add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c)
          .add(c4q31, read: AnswerChoice.blank, to: AnswerChoice.a)
          .add(
            const AnswerCell(3, 5),
            read: AnswerChoice.b,
            to: AnswerChoice.blank,
          );
      expect(corrections.toLegacyEdits(), {
        'Kolon 3': {'12': 'C', '5': 'Boş'},
        'Kolon 4': {'31': 'A'},
      });
    });

    test('is immutable and compares by content', () {
      const none = AnswerCorrections.none;
      final one = none.add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c);
      expect(none.isEmpty, isTrue);
      expect(
        one,
        none.add(c3q12, read: AnswerChoice.blank, to: AnswerChoice.c),
      );
      expect(() => one.items.add(one.items.first), throwsUnsupportedError);
    });
  });
}
