import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/application/answer_fix_draft.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

import '../scan_fixtures.dart';

final grid = AnswerGrid.parse(sampleAnswerColumns())!;

void main() {
  group('opening (pano 4.7 kare 2)', () {
    test('a tapped cell fills column and question, no mark', () {
      final draft = AnswerFixDraft.at(grid, const AnswerCell(3, 12));
      expect(draft.column, 3);
      expect(draft.question, 12);
      expect(draft.choice, isNull);
      expect(draft.read, AnswerChoice.blank);
      expect(draft.canAdd, isFalse);
    });

    test('a cell outside the form is brought inside', () {
      final draft = AnswerFixDraft.at(grid, const AnswerCell(9, 99));
      expect(draft.cell, const AnswerCell(4, 40));
    });
  });

  group('moving', () {
    test('the stepper stays inside the column', () {
      var draft = AnswerFixDraft.at(grid, const AnswerCell(3, 1));
      expect(draft.hasPrevious, isFalse);
      expect(draft.stepped(-1).question, 1);
      draft = draft.withQuestion(40);
      expect(draft.hasNext, isFalse);
      expect(draft.stepped(1).question, 40);
      expect(draft.stepped(-1).question, 39);
    });

    test('changing the column keeps the question and drops the mark', () {
      final draft = AnswerFixDraft.at(
        grid,
        const AnswerCell(3, 12),
      ).withChoice(AnswerChoice.c).withColumn(4);
      expect(draft.column, 4);
      expect(draft.question, 12);
      expect(draft.choice, isNull);
    });

    test('changing the question drops the mark too', () {
      final draft = AnswerFixDraft.at(
        grid,
        const AnswerCell(3, 12),
      ).withChoice(AnswerChoice.c).stepped(1);
      expect(draft.question, 13);
      expect(draft.choice, isNull);
    });
  });

  group('picking and adding', () {
    test('Düzeltmeyi Ekle is off until a mark is picked', () {
      final draft = AnswerFixDraft.at(grid, const AnswerCell(4, 31));
      expect(draft.canAdd, isFalse);
      expect(draft.withChoice(AnswerChoice.a).canAdd, isTrue);
    });

    test('picking the same mark again takes it back', () {
      final draft = AnswerFixDraft.at(
        grid,
        const AnswerCell(4, 31),
      ).withChoice(AnswerChoice.a).withChoice(AnswerChoice.a);
      expect(draft.choice, isNull);
    });

    test('adding writes the correction and clears the mark', () {
      final draft = AnswerFixDraft.at(
        grid,
        const AnswerCell(3, 12),
      ).withChoice(AnswerChoice.c);
      final corrections = draft.addTo(AnswerCorrections.none);
      expect(corrections.count, 1);
      expect(corrections.items.first.from, AnswerChoice.blank);
      expect(corrections.items.first.to, AnswerChoice.c);
      final next = draft.cleared();
      expect(next.cell, draft.cell);
      expect(next.choice, isNull);
    });

    test('adding without a mark changes nothing', () {
      final draft = AnswerFixDraft.at(grid, const AnswerCell(3, 12));
      expect(draft.addTo(AnswerCorrections.none), AnswerCorrections.none);
    });
  });
}
