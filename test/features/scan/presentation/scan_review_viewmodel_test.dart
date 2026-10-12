import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/features/exams/application/question_status.dart';
import 'package:smap/features/scan/domain/answer_correction.dart';
import 'package:smap/features/scan/domain/answer_grid.dart';
import 'package:smap/features/scan/domain/optic_reading.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_dialogs.dart';
import 'package:smap/features/scan/presentation/form_check/scan_review_viewmodel.dart';

import '../scan_fakes.dart';
import '../scan_fixtures.dart';

class _Dialogs implements ScanReviewDialogs {
  /// What the fix sheet hands back, given the corrections it opened with.
  AnswerCorrections Function(AnswerCorrections open)? fix;
  bool exit = true;
  final List<AnswerCell> opened = [];
  int exitAsked = 0;

  @override
  Future<AnswerCorrections> fixAnswers({
    required AnswerGrid grid,
    required AnswerCorrections corrections,
    required AnswerCell start,
  }) async {
    opened.add(start);
    return fix?.call(corrections) ?? corrections;
  }

  @override
  Future<bool> confirmExit() async {
    exitAsked++;
    return exit;
  }
}

AnswerCorrections both(AnswerCorrections from) => from
    .add(const AnswerCell(3, 12), read: AnswerChoice.blank, to: AnswerChoice.c)
    .add(const AnswerCell(4, 31), read: AnswerChoice.blank, to: AnswerChoice.a);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeScanRepository repository;
  late _Dialogs dialogs;
  late RecordingActions actions;

  ScanReviewViewModel build({OpticReading? reading}) => ScanReviewViewModel(
    reading: reading ?? sampleReading(),
    repository: repository,
    dialogs: dialogs,
    actions: actions,
    imageUrl: 'https://cdn.example.test/uploads/optic_160.jpg',
  );

  setUp(() {
    repository = FakeScanRepository();
    dialogs = _Dialogs();
    actions = RecordingActions();
  });

  group('the check (pano 4.7 kare 1)', () {
    test(
      'shows 160 answers read, 2 blank, and the column with the first blank',
      () {
        final vm = build();
        expect(vm.model.readCount, 160);
        expect(vm.model.blankCount, 2);
        expect(vm.column, 3);
        vm.dispose();
      },
    );

    test('starts at the first column when nothing is blank', () {
      final vm = build(
        reading: sampleReading(columns: sampleAnswerColumns(blanks: const {})),
      );
      expect(vm.column, 1);
      vm.dispose();
    });

    test('the segment changes the column', () {
      final vm = build();
      vm.selectColumn(4);
      expect(vm.column, 4);
      vm.selectColumn(9);
      expect(vm.column, 4);
      vm.dispose();
    });
  });

  group('fixing (pano 4.7 kare 2 to 4)', () {
    test('"Düzelt" opens the sheet at the first blank reading', () async {
      final vm = build();
      await vm.fix();
      expect(dialogs.opened, [const AnswerCell(3, 12)]);
      vm.dispose();
    });

    test(
      'a tapped cell opens the sheet at that question of the column',
      () async {
        final vm = build();
        vm.selectColumn(2);
        await vm.fixCell(7);
        expect(dialogs.opened, [const AnswerCell(2, 7)]);
        vm.dispose();
      },
    );

    test(
      'the corrections the sheet hands back are laid over the grid',
      () async {
        dialogs.fix = both;
        final vm = build();
        await vm.fix();
        expect(vm.model.correctionCount, 2);
        expect(vm.model.blankCount, 0);
        expect(vm.model.statusOf(3, 12), FormCheckStatus.corrected);
        vm.dispose();
      },
    );

    test('the sheet opens again with what was already added', () async {
      dialogs.fix = both;
      final vm = build();
      await vm.fix();
      AnswerCorrections? opened;
      dialogs.fix = (open) {
        opened = open;
        return open;
      };
      await vm.fix();
      expect(opened!.count, 2);
      vm.dispose();
    });
  });

  group('Cevapları Onayla', () {
    test(
      'sends the reading and the corrections and, for a known exam, opens the result',
      () async {
        dialogs.fix = both;
        repository.answers = Right(AnswerReply.fromJson(sampleAnswerJson()));
        final vm = build();
        await vm.fix();
        await vm.confirm();
        expect(repository.sentCorrections.single.count, 2);
        expect(actions.calls, ['examRecognised']);
        expect(actions.examId, '6527f1c2a4b5d8e9f0123456');
        vm.dispose();
      },
    );

    test(
      'for an unknown exam it opens the request with the server\'s answer',
      () async {
        repository.answers = Right(
          AnswerReply.fromJson(sampleAnswerJson(found: false)),
        );
        final vm = build();
        await vm.confirm();
        expect(actions.calls, ['examUnknown']);
        expect(actions.reply!.examFound, isFalse);
        vm.dispose();
      },
    );

    test('is busy while it sends and asks nothing more', () async {
      repository.answers = Right(AnswerReply.fromJson(sampleAnswerJson()));
      final vm = build();
      final run = vm.confirm();
      expect(vm.send, ReviewSend.sending);
      expect(vm.sending, isTrue);
      await run;
      vm.dispose();
    });

    test(
      'a failure keeps the corrections and shows the alert (pano 4.8 kare 2)',
      () async {
        dialogs.fix = both;
        repository.answers = Left(exception(AppErrorCode.server));
        final vm = build();
        await vm.fix();
        await vm.confirm();
        expect(vm.send, ReviewSend.failed);
        expect(vm.offline, isFalse);
        expect(vm.model.correctionCount, 2);
        expect(actions.calls, isEmpty);
        vm.dispose();
      },
    );

    test('offline it says so', () async {
      repository.answers = Left(exception(AppErrorCode.offline));
      final vm = build();
      await vm.confirm();
      expect(vm.send, ReviewSend.failed);
      expect(vm.offline, isTrue);
      vm.dispose();
    });

    test('"Tekrar Dene" sends again and clears the alert on success', () async {
      repository.answers = Left(exception(AppErrorCode.network));
      final vm = build();
      await vm.confirm();
      repository.answers = Right(AnswerReply.fromJson(sampleAnswerJson()));
      await vm.confirm();
      expect(repository.sentCorrections, hasLength(2));
      expect(actions.calls, ['examRecognised']);
      vm.dispose();
    });

    test('a second press while it sends is ignored', () async {
      repository.answers = Right(AnswerReply.fromJson(sampleAnswerJson()));
      final vm = build();
      final first = vm.confirm();
      await vm.confirm();
      await first;
      expect(repository.sentCorrections, hasLength(1));
      vm.dispose();
    });
  });

  group('leaving (pano 4.7 "Okutmadan çıkılsın mı?")', () {
    test('without corrections it leaves at once', () async {
      final vm = build();
      await vm.exit();
      expect(dialogs.exitAsked, 0);
      expect(actions.calls, ['close']);
      vm.dispose();
    });

    test('with corrections it asks first, and stays on "Vazgeç"', () async {
      dialogs.fix = both;
      dialogs.exit = false;
      final vm = build();
      await vm.fix();
      await vm.exit();
      expect(dialogs.exitAsked, 1);
      expect(actions.calls, isEmpty);
      vm.dispose();
    });

    test('with corrections and a yes it leaves', () async {
      dialogs.fix = both;
      final vm = build();
      await vm.fix();
      await vm.exit();
      expect(actions.calls, ['close']);
      vm.dispose();
    });
  });
}
