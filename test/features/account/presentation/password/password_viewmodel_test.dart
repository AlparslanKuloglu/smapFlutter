import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/account/application/password_repository.dart';
import 'package:smap/features/account/application/password_rules.dart';
import 'package:smap/features/account/presentation/password/password_navigator.dart';
import 'package:smap/features/account/presentation/password/password_viewmodel.dart';

import '../account_settings_fakes.dart';

class _FakePasswordRepository implements PasswordRepository {
  AppResult<Unit> result = const Right(unit);
  final List<({String current, String next})> calls = [];

  @override
  Future<AppResult<Unit>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    calls.add((current: currentPassword, next: newPassword));
    return result;
  }
}

class _FakeNavigator implements PasswordNavigator {
  int closed = 0;

  @override
  void close() => closed++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePasswordRepository repository;
  late _FakeNavigator navigator;
  late ToastProbe toast;
  late PasswordViewModel viewModel;

  setUp(() {
    repository = _FakePasswordRepository();
    navigator = _FakeNavigator();
    toast = ToastProbe();
    viewModel = PasswordViewModel(
      repository: repository,
      navigator: navigator,
      toast: toast.service,
    );
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  Future<void> submit({
    String current = 'eski-sifre',
    String next = 'yeni-sifre1',
    String? repeat,
  }) => viewModel.submit(current: current, next: next, repeat: repeat ?? next);

  group('the button', () {
    test('is closed until the three fields hold something', () {
      expect(viewModel.canSubmit.value, isFalse);
      viewModel.edited(current: 'a', next: '', repeat: '');
      expect(viewModel.canSubmit.value, isFalse);
      viewModel.edited(current: 'a', next: 'b', repeat: 'c');
      expect(viewModel.canSubmit.value, isTrue);
      viewModel.edited(current: 'a', next: 'b', repeat: '');
      expect(viewModel.canSubmit.value, isFalse);
    });

    test('an empty form sends nothing', () async {
      await viewModel.submit(
        current: '',
        next: 'yeni-sifre1',
        repeat: 'yeni-sifre1',
      );
      expect(repository.calls, isEmpty);
      expect(viewModel.issue, isNull);
    });
  });

  group('checks before the server', () {
    test(
      'a short new password shows the rule in red and sends nothing',
      () async {
        await submit(next: 'kisa', repeat: 'kisa');
        expect(viewModel.issue, PasswordIssue.tooShort);
        expect(repository.calls, isEmpty);
      },
    );

    test('the same password is refused', () async {
      await submit(current: 'ayni-sifre-1', next: 'ayni-sifre-1');
      expect(viewModel.issue, PasswordIssue.sameAsCurrent);
      expect(repository.calls, isEmpty);
    });

    test('two different new passwords are refused', () async {
      await submit(repeat: 'baska-sifre-1');
      expect(viewModel.issue, PasswordIssue.mismatch);
      expect(repository.calls, isEmpty);
    });

    test('each refusal asks the screen to move the focus again', () async {
      await submit(repeat: 'baska-sifre-1');
      final first = viewModel.focusRequests;
      await submit(repeat: 'baska-sifre-1');
      expect(viewModel.focusRequests, first + 1);
    });

    test('editing a field clears the red', () async {
      await submit(repeat: 'baska-sifre-1');
      viewModel.edited(
        current: 'eski-sifre',
        next: 'yeni-sifre1',
        repeat: 'yeni-sifre1',
      );
      expect(viewModel.issue, isNull);
    });
  });

  group('the server', () {
    test(
      'success closes the screen and toasts "Şifren güncellendi."',
      () async {
        await submit();
        expect(repository.calls.single, (
          current: 'eski-sifre',
          next: 'yeni-sifre1',
        ));
        expect(navigator.closed, 1);
        expect(toast.text, 'Şifren güncellendi.');
        expect(viewModel.isSending, isFalse);
      },
    );

    test('a refused current password stays on the form (kare 2)', () async {
      repository.result = const Left(
        AppException(code: AppErrorCode.validation, statusCode: 400),
      );
      await submit();
      expect(viewModel.issue, PasswordIssue.wrongCurrent);
      expect(viewModel.issue!.field, PasswordField.current);
      expect(navigator.closed, 0);
      expect(toast.text, isNull);
      expect(viewModel.isSending, isFalse);
    });

    test('a failed connection is a toast and keeps the form', () async {
      repository.result = const Left(offline);
      await submit();
      expect(viewModel.issue, isNull);
      expect(navigator.closed, 0);
      expect(toast.text, 'Gönderilemedi. Bağlantını kontrol edip tekrar dene.');
      expect(toast.isError, isTrue);
    });

    test('a second tap while sending does nothing', () async {
      final first = submit();
      await submit();
      await first;
      expect(repository.calls, hasLength(1));
    });
  });
}
