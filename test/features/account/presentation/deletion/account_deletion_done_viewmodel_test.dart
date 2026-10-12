import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/presentation/deletion/done/account_deletion_done_viewmodel.dart';
import 'package:smap/services/session_manager.dart';

class _FakeSession implements SessionManager {
  int completed = 0;
  Completer<void>? gate;

  @override
  Future<void> completeAccountDeletion() async {
    completed++;
    await gate?.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('"Tamam" ends the session on the device', () async {
    final session = _FakeSession();
    final viewModel = AccountDeletionDoneViewModel(session: session);
    await viewModel.finish();
    expect(session.completed, 1);
    viewModel.dispose();
  });

  test('a second tap while it runs does nothing', () async {
    final session = _FakeSession()..gate = Completer<void>();
    final viewModel = AccountDeletionDoneViewModel(session: session);
    final first = viewModel.finish();
    await viewModel.finish();
    session.gate!.complete();
    await first;
    expect(session.completed, 1);
    viewModel.dispose();
  });
}
