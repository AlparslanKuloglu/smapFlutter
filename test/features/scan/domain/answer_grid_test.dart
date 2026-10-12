import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';

import '../scan_fixtures.dart';

void main() {
  group('AnswerChoice.parse', () {
    test('reads a letter of either case', () {
      expect(AnswerChoice.parse('A'), AnswerChoice.a);
      expect(AnswerChoice.parse('c'), AnswerChoice.c);
      expect(AnswerChoice.parse(' E '), AnswerChoice.e);
    });

    test('reads no mark as blank', () {
      for (final raw in <Object?>[
        null,
        '',
        '  ',
        '-',
        '–',
        '_',
        'Boş',
        'BOŞ',
      ]) {
        expect(AnswerChoice.parse(raw), AnswerChoice.blank, reason: '$raw');
      }
    });

    test('does not guess what it does not understand', () {
      expect(AnswerChoice.parse('F'), isNull);
      expect(AnswerChoice.parse('AB'), isNull);
      expect(AnswerChoice.parse(3), isNull);
      expect(AnswerChoice.parse(true), isNull);
    });

    test('the server edits name a blank "Boş" and a letter by itself', () {
      expect(AnswerChoice.blank.legacyValue, 'Boş');
      expect(AnswerChoice.d.legacyValue, 'D');
      expect(AnswerChoice.blank.letter, isNull);
      expect(AnswerChoice.d.letter, 'D');
    });
  });

  group('AnswerGrid.parse', () {
    test('reads four columns of forty (pano 4.7: 160 answers)', () {
      final grid = AnswerGrid.parse(sampleAnswerColumns())!;
      expect(grid.columnCount, 4);
      expect(grid.totalCells, 160);
      expect(grid.questionCount(3), 40);
    });

    test('numbers columns and questions from 1', () {
      final grid = AnswerGrid.parse(sampleAnswerColumns())!;
      expect(grid.at(3, 12), AnswerChoice.blank);
      expect(grid.at(4, 31), AnswerChoice.blank);
      expect(grid.at(1, 1), AnswerChoice.c);
      expect(grid.contains(4, 40), isTrue);
      expect(grid.contains(5, 1), isFalse);
      expect(grid.contains(1, 41), isFalse);
      expect(grid.contains(0, 1), isFalse);
    });

    test('cuts a flat list into columns of forty', () {
      final flat = [for (final column in sampleAnswerColumns()) ...column];
      final grid = AnswerGrid.parse(flat)!;
      expect(grid.columnCount, 4);
      expect(grid, AnswerGrid.parse(sampleAnswerColumns()));
    });

    test('keeps a short last column as it is', () {
      final grid = AnswerGrid.parse(List<String?>.filled(95, 'A'))!;
      expect(grid.columnCount, 3);
      expect(grid.questionCount(3), 15);
    });

    test('is null for nothing to check', () {
      expect(AnswerGrid.parse(null), isNull);
      expect(AnswerGrid.parse(<Object?>[]), isNull);
      expect(AnswerGrid.parse('A'), isNull);
      expect(AnswerGrid.parse([<Object?>[]]), isNull);
    });

    test('is null when an entry is not a choice', () {
      final columns = sampleAnswerColumns();
      columns[0][4] = 'Z';
      expect(AnswerGrid.parse(columns), isNull);
    });

    test('compares by content', () {
      expect(
        AnswerGrid.parse(sampleAnswerColumns()),
        AnswerGrid.parse(sampleAnswerColumns()),
      );
      expect(
        AnswerGrid.parse(sampleAnswerColumns()),
        isNot(AnswerGrid.parse(sampleAnswerColumns(blanks: const {}))),
      );
    });
  });
}
