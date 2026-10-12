import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';
import 'package:smap/features/account/presentation/deletion/progress/account_deletion_progress_viewmodel.dart';

import '../account_settings_fakes.dart';

class _FakeNavigator implements AccountDeletionProgressNavigator {
  final List<String> calls = [];

  @override
  void showDone() => calls.add('done');

  @override
  void showFailure() => calls.add('failure');
}

void main() {
  late FakeAccountRepository account;
  late _FakeNavigator navigator;
  late AccountDeletionProgressViewModel viewModel;
  var disposed = false;

  setUp(() {
    disposed = false;
    account = FakeAccountRepository();
    navigator = _FakeNavigator();
    viewModel = AccountDeletionProgressViewModel(
      account: account,
      navigator: navigator,
    );
  });

  tearDown(() {
    if (!disposed) viewModel.dispose();
  });

  test('deletes the account and moves on to "Hesabın silindi"', () async {
    await viewModel.start();
    expect(account.deleteCalls, 1);
    expect(navigator.calls, ['done']);
  });

  test('a failure goes back to the explanation', () async {
    account.deleteResult = const Left(offline);
    await viewModel.start();
    expect(navigator.calls, ['failure']);
  });

  test('a server refusal is a failure too', () async {
    account.deleteResult = const Left(refused);
    await viewModel.start();
    expect(navigator.calls, ['failure']);
  });

  test('the call is made once however often the screen starts it', () async {
    final gate = Completer<void>();
    account.deleteGate = gate.future;
    final first = viewModel.start();
    await viewModel.start();
    gate.complete();
    await first;
    expect(account.deleteCalls, 1);
    expect(navigator.calls, ['done']);
  });

  test('nothing happens when the screen is gone before the answer', () async {
    final gate = Completer<void>();
    account.deleteGate = gate.future;
    final running = viewModel.start();
    viewModel.dispose();
    disposed = true;
    gate.complete();
    await running;
    expect(navigator.calls, isEmpty);
  });
}
