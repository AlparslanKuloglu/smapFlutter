import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/deletion_consequences.dart';
import 'package:smap/features/account/presentation/deletion/account_deletion_viewmodel.dart';
import 'package:smap/features/account/presentation/deletion/deletion_dialogs.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';

import '../account_settings_fakes.dart';

class _FakeDialogs implements AccountDeletionDialogs {
  bool answer = true;
  final List<String?> asked = [];

  @override
  Future<bool> confirmDeletion({String? userName}) async {
    asked.add(userName);
    return answer;
  }
}

class _FakeNavigator implements AccountDeletionNavigator {
  /// What the progress screen completes with.
  bool? progressOutcome;
  int opened = 0;
  int closed = 0;

  @override
  Future<bool?> openProgress() async {
    opened++;
    return progressOutcome;
  }

  @override
  void close() => closed++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeAccountRepository account;
  late FakeUserService user;
  late _FakeDialogs dialogs;
  late _FakeNavigator navigator;
  late AccountDeletionViewModel viewModel;

  AccountDeletionViewModel build() => AccountDeletionViewModel(
    currentUser: user,
    account: account,
    dialogs: dialogs,
    navigator: navigator,
  );

  setUp(() {
    account = FakeAccountRepository();
    user = FakeUserService(alparslan);
    dialogs = _FakeDialogs();
    navigator = _FakeNavigator();
    viewModel = build();
  });

  tearDown(() => viewModel.dispose());

  group('the list (pano 9.4 kare 2)', () {
    test('names the 10 exams and the coach once the coach loaded', () async {
      account.myCoach = const Right(mehmet);
      await viewModel.init();
      final lines = viewModel.consequences;
      expect(lines.map((l) => l.kind), [
        DeletionConsequenceKind.exams,
        DeletionConsequenceKind.progress,
        DeletionConsequenceKind.coach,
        DeletionConsequenceKind.irreversible,
      ]);
      expect(lines.first.examCount, 10);
      expect(lines[2].coachName, 'Mehmet Özkan');
    });

    test(
      'before the coach answers, the account\'s own coach field decides',
      () async {
        final gate = Completer<void>();
        account.myCoachGate = gate.future;
        account.myCoach = const Right(mehmet);
        final loading = viewModel.init();
        expect(viewModel.hasCoach, isTrue);
        expect(viewModel.coachName, isNull);
        gate.complete();
        await loading;
        expect(viewModel.coachName, 'Mehmet Özkan');
      },
    );

    test('a student without a coach gets no coach line', () async {
      user.set(alparslanNoCoach);
      account.myCoach = const Right(null);
      await viewModel.init();
      expect(viewModel.hasCoach, isFalse);
      expect(
        viewModel.consequences.map((l) => l.kind),
        isNot(contains(DeletionConsequenceKind.coach)),
      );
    });

    test('the server\'s "no coach" wins over a stale coach field', () async {
      account.myCoach = const Right(null);
      await viewModel.init();
      expect(viewModel.hasCoach, isFalse);
    });

    test('a failed coach call keeps the line without a name', () async {
      account.myCoach = const Left(offline);
      await viewModel.init();
      expect(viewModel.hasCoach, isTrue);
      expect(viewModel.coachName, isNull);
    });

    test('an account without an exam count has no number', () {
      user.set(alparslanNoCoach.copyWith(totalMexam: null));
      expect(viewModel.examCount, isNull);
    });
  });

  group('"Hesabımı Sil"', () {
    test('asks with the user\'s name and opens the progress screen', () async {
      await viewModel.requestDeletion();
      expect(dialogs.asked, ['Alparslan Kuloğlu']);
      expect(navigator.opened, 1);
      expect(viewModel.failed, isFalse);
    });

    test('"Vazgeç" on the sheet opens nothing', () async {
      dialogs.answer = false;
      await viewModel.requestDeletion();
      expect(navigator.opened, 0);
    });

    test('a failed deletion shows the error box on the explanation', () async {
      navigator.progressOutcome = false;
      await viewModel.requestDeletion();
      expect(viewModel.failed, isTrue);
    });

    test('a deletion that moved on to "silindi" shows no error', () async {
      navigator.progressOutcome = null;
      await viewModel.requestDeletion();
      expect(viewModel.failed, isFalse);
    });

    test('trying again clears the error box', () async {
      navigator.progressOutcome = false;
      await viewModel.requestDeletion();
      navigator.progressOutcome = null;
      await viewModel.requestDeletion();
      expect(viewModel.failed, isFalse);
    });

    test('a second tap while one runs does nothing', () async {
      final first = viewModel.requestDeletion();
      await viewModel.requestDeletion();
      await first;
      expect(navigator.opened, 1);
    });
  });

  test('"Vazgeç" closes the screen', () {
    viewModel.cancel();
    expect(navigator.closed, 1);
  });
}
