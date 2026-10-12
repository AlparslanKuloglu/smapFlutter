import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/deletion_consequences.dart';

void main() {
  List<DeletionConsequenceKind> kinds(List<DeletionConsequence> list) => [
    for (final line in list) line.kind,
  ];

  test('a student with a coach and 10 read exams (pano 9.4 kare 2)', () {
    final list = DeletionConsequences.of(
      examCount: 10,
      hasCoach: true,
      coachName: 'Mehmet Özkan',
    );
    expect(kinds(list), [
      DeletionConsequenceKind.exams,
      DeletionConsequenceKind.progress,
      DeletionConsequenceKind.coach,
      DeletionConsequenceKind.irreversible,
    ]);
    expect(list.first.examCount, 10);
    expect(list[2].coachName, 'Mehmet Özkan');
  });

  test('a student without a coach has no coach line', () {
    final list = DeletionConsequences.of(examCount: 6, hasCoach: false);
    expect(kinds(list), isNot(contains(DeletionConsequenceKind.coach)));
    expect(list, hasLength(3));
  });

  test('a count the account does not carry is left out, not made up', () {
    expect(DeletionConsequences.of(hasCoach: false).first.examCount, isNull);
    expect(
      DeletionConsequences.of(examCount: 0, hasCoach: false).first.examCount,
      isNull,
    );
  });

  test('a coach without a known name is named by no one', () {
    final list = DeletionConsequences.of(
      examCount: 10,
      hasCoach: true,
      coachName: '  ',
    );
    expect(list[2].kind, DeletionConsequenceKind.coach);
    expect(list[2].coachName, isNull);
  });

  test('the last line is always "geri alınamaz"', () {
    expect(
      DeletionConsequences.of(hasCoach: true).last.kind,
      DeletionConsequenceKind.irreversible,
    );
  });

  test('lines compare by value', () {
    expect(
      const DeletionConsequence(DeletionConsequenceKind.exams, examCount: 3),
      const DeletionConsequence(DeletionConsequenceKind.exams, examCount: 3),
    );
  });
}
