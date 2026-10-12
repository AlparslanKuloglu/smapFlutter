import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/presentation/form_check/sheets/answer_fix_sheet_viewmodel.dart';

import '../scan_fixtures.dart';

void main() {
  final grid = AnswerGrid.parse(sampleAnswerColumns())!;

  AnswerFixSheetViewModel build({
    AnswerCorrections corrections = AnswerCorrections.none,
    AnswerCell start = const AnswerCell(3, 12),
  }) => AnswerFixSheetViewModel(
    grid: grid,
    corrections: corrections,
    start: start,
  );

  test('opens at the tapped question with an empty list (pano 4.7 kare 2)', () {
    final vm = build();
    expect(vm.draft.column, 3);
    expect(vm.draft.question, 12);
    expect(vm.draft.read, AnswerChoice.blank);
    expect(vm.draft.canAdd, isFalse);
    expect(vm.corrections.isEmpty, isTrue);
  });

  test('picks a mark, adds it at the head of the list and clears the mark', () {
    final vm = build();
    vm.pick(AnswerChoice.c);
    expect(vm.draft.canAdd, isTrue);
    vm.add();
    expect(vm.corrections.count, 1);
    expect(vm.corrections.items.first.cell, const AnswerCell(3, 12));
    expect(vm.corrections.items.first.to, AnswerChoice.c);
    expect(vm.draft.choice, isNull);
  });

  test('two corrections, newest first (pano 4.7 kare 3)', () {
    final vm = build()
      ..pick(AnswerChoice.c)
      ..add()
      ..selectColumn(4)
      ..step(19)
      ..pick(AnswerChoice.a)
      ..add();
    expect(vm.corrections.items.map((c) => c.cell), [
      const AnswerCell(4, 31),
      const AnswerCell(3, 12),
    ]);
  });

  test('adding without a mark does nothing', () {
    final vm = build()..add();
    expect(vm.corrections.isEmpty, isTrue);
  });

  test('a correction can be taken back with its X', () {
    final vm = build()
      ..pick(AnswerChoice.c)
      ..add()
      ..remove(const AnswerCell(3, 12));
    expect(vm.corrections.isEmpty, isTrue);
  });

  test('keeps the corrections it was opened with', () {
    final open = AnswerCorrections.none.add(
      const AnswerCell(1, 1),
      read: AnswerChoice.c,
      to: AnswerChoice.e,
    );
    final vm = build(corrections: open);
    expect(vm.corrections, open);
  });

  test('the stepper and the segment move inside the form', () {
    final vm = build()
      ..step(1)
      ..selectColumn(1);
    expect(vm.draft.cell, const AnswerCell(1, 13));
    vm.step(-1);
    expect(vm.draft.question, 12);
  });
}
