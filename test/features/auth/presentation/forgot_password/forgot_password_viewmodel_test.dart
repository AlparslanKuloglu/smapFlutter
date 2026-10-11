import 'package:dartz/dartz.dart';
// ignore: depend_on_referenced_packages
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/auth/application/forgot_password_logic.dart';
import 'package:smap/features/auth/application/forgot_password_repository.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/auth/presentation/forgot_password/forgot_password_viewmodel.dart';
import 'package:smap/l10n/app_localizations_tr.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// A reset backend that answers what the test tells it to.
class _FakeRepository implements ForgotPasswordRepository {
  AppResult<Unit> requestResult = const Right(unit);
  AppResult<Unit> verifyResult = const Right(unit);
  AppResult<ResetOutcome> resetResult = const Right(
    ResetOutcome(userName: 'ayse'),
  );

  final List<String> requests = [];
  final List<String> verifications = [];
  final List<({String email, String code, String password})> resets = [];

  @override
  Future<AppResult<Unit>> requestCode({required String email}) async {
    requests.add(email);
    return requestResult;
  }

  @override
  Future<AppResult<Unit>> verifyCode({
    required String email,
    required String code,
  }) async {
    verifications.add('$email/$code');
    return verifyResult;
  }

  @override
  Future<AppResult<ResetOutcome>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    resets.add((email: email, code: code, password: newPassword));
    return resetResult;
  }
}

class _FakePresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

const _offline = AppException(code: AppErrorCode.offline);
const _wrongCode = AppException(code: AppErrorCode.validation, statusCode: 400);
const _tooMany = AppException(code: AppErrorCode.validation, statusCode: 429);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final l10n = AppLocalizationsTr();
  late _FakeRepository repository;
  late ToastService toast;
  late ForgotPasswordViewModel viewModel;
  late AppRouter router;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    repository = _FakeRepository();
    toast = ToastService(presenter: _FakePresenter());
    router = AppRouter(
      session: () => const SessionState.signedOut(),
      preferences: await DevicePreferences.load(),
    );
    viewModel = ForgotPasswordViewModel(
      repository: repository,
      router: router,
      toast: toast,
    );
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  String? toastText() => toast.slot.current.value?.title(l10n);

  /// Brings the flow to the code step.
  Future<void> toCodeStep() => viewModel.submitEmail('ayse@ornek.com');

  /// Brings the flow to the new password step.
  Future<void> toPasswordStep() async {
    await toCodeStep();
    await viewModel.submitCode('271524');
  }

  group('e-mail step', () {
    test('starts on the e-mail step with nothing wrong', () {
      expect(viewModel.step, ForgotPasswordStep.email);
      expect(viewModel.emailInvalid, isFalse);
      expect(viewModel.codeIssue, isNull);
      expect(viewModel.passwordIssue, isNull);
      expect(viewModel.resendSeconds.value, 0);
    });

    test(
      'an address that does not look like one is refused on the spot',
      () async {
        await viewModel.submitEmail('ad@alan');

        expect(viewModel.emailInvalid, isTrue);
        expect(viewModel.step, ForgotPasswordStep.email);
        expect(repository.requests, isEmpty);
      },
    );

    test('editing the field takes the format error away', () async {
      await viewModel.submitEmail('ad');

      viewModel.emailEdited();

      expect(viewModel.emailInvalid, isFalse);
    });

    test('asks for the code with the trimmed address and moves on', () async {
      await viewModel.submitEmail('  ayse@ornek.com ');

      expect(repository.requests, ['ayse@ornek.com']);
      expect(viewModel.email, 'ayse@ornek.com');
      expect(viewModel.step, ForgotPasswordStep.code);
      expect(viewModel.movingForward, isTrue);
      expect(viewModel.isSending, isFalse);
      expect(viewModel.resendSeconds.value, 30);
    });

    test('is busy while the code is requested', () async {
      final running = viewModel.submitEmail('ayse@ornek.com');

      expect(viewModel.isSending, isTrue);
      await running;
    });

    test(
      'a failed request is a toast and the user stays on the step',
      () async {
        repository.requestResult = const Left(_offline);

        await viewModel.submitEmail('ayse@ornek.com');

        expect(viewModel.step, ForgotPasswordStep.email);
        expect(viewModel.isSending, isFalse);
        expect(
          toastText(),
          'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
        );
        expect(toast.slot.current.value!.kind, AppToastKind.error);
        expect(viewModel.resendSeconds.value, 0);
      },
    );
  });

  group('code step', () {
    test('an incomplete code is not checked', () async {
      await toCodeStep();

      await viewModel.submitCode('2715');

      expect(repository.verifications, isEmpty);
      expect(viewModel.step, ForgotPasswordStep.code);
    });

    test('a good code opens the new password step', () async {
      await toCodeStep();

      await viewModel.submitCode('271524');

      expect(repository.verifications, ['ayse@ornek.com/271524']);
      expect(viewModel.step, ForgotPasswordStep.newPassword);
      expect(viewModel.codeIssue, isNull);
      expect(viewModel.isVerifying, isFalse);
    });

    test('is busy while the code is checked', () async {
      await toCodeStep();

      final running = viewModel.submitCode('271524');

      expect(viewModel.isVerifying, isTrue);
      await running;
    });

    test(
      'a wrong or expired code is shown under the boxes and shakes them',
      () async {
        await toCodeStep();
        repository.verifyResult = const Left(_wrongCode);

        await viewModel.submitCode('000000');

        expect(viewModel.codeIssue, CodeIssue.wrongOrExpired);
        expect(viewModel.codeShake, 1);
        expect(viewModel.step, ForgotPasswordStep.code);
        expect(toastText(), isNull);
      },
    );

    test('too many tries is its own sentence', () async {
      await toCodeStep();
      repository.verifyResult = const Left(_tooMany);

      await viewModel.submitCode('000000');

      expect(viewModel.codeIssue, CodeIssue.tooManyAttempts);
    });

    test('a second wrong code shakes the boxes again', () async {
      await toCodeStep();
      repository.verifyResult = const Left(_wrongCode);

      await viewModel.submitCode('000000');
      await viewModel.submitCode('111111');

      expect(viewModel.codeShake, 2);
    });

    test('editing the boxes takes the red away', () async {
      await toCodeStep();
      repository.verifyResult = const Left(_wrongCode);
      await viewModel.submitCode('000000');

      viewModel.codeEdited();

      expect(viewModel.codeIssue, isNull);
    });

    test(
      'a failed connection is a toast, no red, and the boxes empty',
      () async {
        await toCodeStep();
        final clearsBefore = viewModel.codeClears;
        repository.verifyResult = const Left(_offline);

        await viewModel.submitCode('271524');

        expect(viewModel.codeIssue, isNull);
        expect(viewModel.codeClears, clearsBefore + 1);
        expect(viewModel.step, ForgotPasswordStep.code);
        expect(
          toastText(),
          'Gönderilemedi. Bağlantını kontrol edip tekrar dene.',
        );
      },
    );
  });

  group('resend', () {
    test('is closed for 30 seconds, counting down once a second', () async {
      await toCodeStep();

      expect(viewModel.resendSeconds.value, 30);
      await viewModel.resend();

      expect(repository.requests, hasLength(1));
    });

    test('counts down and opens at zero', () {
      fakeAsync((async) {
        viewModel.submitEmail('ayse@ornek.com');
        async.flushMicrotasks();
        expect(viewModel.resendSeconds.value, 30);

        async.elapse(const Duration(seconds: 6));
        expect(viewModel.resendSeconds.value, 24);

        async.elapse(const Duration(seconds: 24));
        expect(viewModel.resendSeconds.value, 0);

        async.elapse(const Duration(seconds: 10));
        expect(viewModel.resendSeconds.value, 0);
      });
    });

    test('once open it sends again and the wait starts over', () {
      fakeAsync((async) {
        viewModel.submitEmail('ayse@ornek.com');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));

        viewModel.resend();
        async.flushMicrotasks();

        expect(repository.requests, ['ayse@ornek.com', 'ayse@ornek.com']);
        expect(viewModel.resendSeconds.value, 30);
      });
    });

    test('a failed resend is a toast and the button stays open', () {
      fakeAsync((async) {
        viewModel.submitEmail('ayse@ornek.com');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 30));
        repository.requestResult = const Left(_offline);

        viewModel.resend();
        async.flushMicrotasks();

        expect(viewModel.resendSeconds.value, 0);
        expect(toastText(), isNotNull);
      });
    });

    test('a new code clears the red of the old one', () {
      fakeAsync((async) {
        viewModel.submitEmail('ayse@ornek.com');
        async.flushMicrotasks();
        repository.verifyResult = const Left(_wrongCode);
        viewModel.submitCode('000000');
        async.flushMicrotasks();
        expect(viewModel.codeIssue, isNotNull);
        async.elapse(const Duration(seconds: 30));

        viewModel.resend();
        async.flushMicrotasks();

        expect(viewModel.codeIssue, isNull);
      });
    });

    test('leaving the screen stops the countdown', () {
      fakeAsync((async) {
        viewModel.submitEmail('ayse@ornek.com');
        async.flushMicrotasks();

        viewModel.dispose();

        expect(async.pendingTimers, isEmpty);
        // The tearDown disposes it again; a second dispose must not throw.
        viewModel = ForgotPasswordViewModel(
          repository: repository,
          router: router,
          toast: toast,
        );
      });
    });
  });

  group('new password step', () {
    test('a short password is refused with the rule', () async {
      await toPasswordStep();

      await viewModel.submitPassword('1234567', '1234567');

      expect(viewModel.passwordIssue, PasswordIssue.tooShort);
      expect(repository.resets, isEmpty);
    });

    test('two different passwords are refused on the second field', () async {
      await toPasswordStep();

      await viewModel.submitPassword('Sifre1234', 'Sifre12345');

      expect(viewModel.passwordIssue, PasswordIssue.mismatch);
      expect(repository.resets, isEmpty);
    });

    test('editing a field takes the red away', () async {
      await toPasswordStep();
      await viewModel.submitPassword('1', '1');

      viewModel.passwordEdited();

      expect(viewModel.passwordIssue, isNull);
    });

    test('saves with the address, the code and the password', () async {
      await toPasswordStep();

      await viewModel.submitPassword('Sifre1234', 'Sifre1234');

      expect(repository.resets.single, (
        email: 'ayse@ornek.com',
        code: '271524',
        password: 'Sifre1234',
      ));
      expect(viewModel.step, ForgotPasswordStep.done);
      expect(viewModel.userName, 'ayse');
      expect(viewModel.isUpdating, isFalse);
    });

    test(
      'the user name stays empty when the server does not tell it',
      () async {
        await toPasswordStep();
        repository.resetResult = const Right(ResetOutcome());

        await viewModel.submitPassword('Sifre1234', 'Sifre1234');

        expect(viewModel.step, ForgotPasswordStep.done);
        expect(viewModel.userName, isNull);
      },
    );

    test(
      'a code the server no longer accepts sends the user back to it',
      () async {
        await toPasswordStep();
        final clearsBefore = viewModel.codeClears;
        repository.resetResult = const Left(_wrongCode);

        await viewModel.submitPassword('Sifre1234', 'Sifre1234');

        expect(viewModel.step, ForgotPasswordStep.code);
        expect(viewModel.codeIssue, CodeIssue.wrongOrExpired);
        expect(viewModel.codeClears, clearsBefore + 1);
      },
    );

    test('a failed connection is a toast and the user stays', () async {
      await toPasswordStep();
      repository.resetResult = const Left(_offline);

      await viewModel.submitPassword('Sifre1234', 'Sifre1234');

      expect(viewModel.step, ForgotPasswordStep.newPassword);
      expect(toastText(), isNotNull);
    });
  });

  group('back', () {
    test('from the code step goes to the e-mail step, address kept', () async {
      await toCodeStep();

      viewModel.back();

      expect(viewModel.step, ForgotPasswordStep.email);
      expect(viewModel.movingForward, isFalse);
      expect(viewModel.email, 'ayse@ornek.com');
    });

    test('"E-postayı Değiştir" is the same way back', () async {
      await toCodeStep();

      viewModel.changeEmail();

      expect(viewModel.step, ForgotPasswordStep.email);
    });

    test('"E-postayı Değiştir" does nothing outside the code step', () async {
      viewModel.changeEmail();

      expect(viewModel.step, ForgotPasswordStep.email);
    });

    test(
      'from the new password step the boxes come back empty and open',
      () async {
        await toPasswordStep();
        final clearsBefore = viewModel.codeClears;
        await viewModel.submitPassword('1', '1');

        viewModel.back();

        expect(viewModel.step, ForgotPasswordStep.code);
        expect(viewModel.codeClears, clearsBefore + 1);
        expect(viewModel.passwordIssue, isNull);
        expect(viewModel.resendSeconds.value, 0);
      },
    );

    test('there is no way back from the last screen', () async {
      await toPasswordStep();
      await viewModel.submitPassword('Sifre1234', 'Sifre1234');

      viewModel.back();

      expect(viewModel.step, ForgotPasswordStep.done);
    });
  });
}
