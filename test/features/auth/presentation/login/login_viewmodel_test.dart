import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/auth/presentation/login/login_viewmodel.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../../../services/session_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SessionHarness harness;
  late AppRouter router;
  late LoginViewModel viewModel;
  late int notifications;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    harness = SessionHarness();
    router = AppRouter(
      session: () => harness.manager.state,
      preferences: await DevicePreferences.load(),
    );
    viewModel = LoginViewModel(session: harness.manager, router: router);
    notifications = 0;
    viewModel.addListener(() => notifications++);
  });

  tearDown(() async {
    viewModel.dispose();
    await harness.dispose();
  });

  group('submit', () {
    test(
      'signs in with the normalized name and the password as typed',
      () async {
        await viewModel.submit(username: ' Ayse ', password: ' Sifre 1 ');

        final body = harness.backend.calls('/student/login').single.data;
        expect(body, {'username': 'ayse', 'password': ' Sifre 1 '});
        expect(harness.manager.state.isSignedIn, isTrue);
        expect(viewModel.failure, isNull);
      },
    );

    test('stays busy after a success: the guards close the screen', () async {
      await viewModel.submit(username: 'ayse', password: 'sifre');

      expect(viewModel.isSubmitting, isTrue);
    });

    test('is busy while the sign-in runs', () async {
      final running = viewModel.submit(username: 'ayse', password: 'sifre');

      expect(viewModel.isSubmitting, isTrue);
      await running;
    });

    test('a second tap while it runs sends nothing more', () async {
      final first = viewModel.submit(username: 'ayse', password: 'sifre');
      final second = viewModel.submit(username: 'ayse', password: 'sifre');
      await Future.wait([first, second]);

      expect(harness.backend.calls('/student/login'), hasLength(1));
    });

    test('wrong credentials: unauthorized, ready for another try', () async {
      harness.backend.acceptCredentials = false;

      await viewModel.submit(username: 'ayse', password: 'yanlis');

      expect(viewModel.failure, AppErrorCode.unauthorized);
      expect(viewModel.isSubmitting, isFalse);
      expect(viewModel.failureCount, 1);
      expect(harness.manager.state, isNot(isA<SessionSignedIn>()));
    });

    test('every failure counts, also two equal ones in a row', () async {
      harness.backend.acceptCredentials = false;

      await viewModel.submit(username: 'ayse', password: 'a');
      await viewModel.submit(username: 'ayse', password: 'b');

      expect(viewModel.failureCount, 2);
      expect(viewModel.failure, AppErrorCode.unauthorized);
    });

    test('a new attempt clears the old failure while it runs', () async {
      harness.backend.acceptCredentials = false;
      await viewModel.submit(username: 'ayse', password: 'yanlis');
      harness.backend.acceptCredentials = true;

      final running = viewModel.submit(username: 'ayse', password: 'dogru');

      expect(viewModel.failure, isNull);
      await running;
      expect(harness.manager.state.isSignedIn, isTrue);
    });

    test('an empty field is not sent and fails like a wrong pair', () async {
      await viewModel.submit(username: '   ', password: 'sifre');
      await viewModel.submit(username: 'ayse', password: '');

      expect(harness.backend.calls('/student/login'), isEmpty);
      expect(viewModel.failure, AppErrorCode.unauthorized);
      expect(viewModel.failureCount, 2);
      expect(viewModel.isSubmitting, isFalse);
    });

    test(
      'a lost connection is a connection failure, not wrong credentials',
      () async {
        await harness.goOffline();

        await viewModel.submit(username: 'ayse', password: 'sifre');

        expect(viewModel.failure, isNotNull);
        expect(viewModel.failure, isNot(AppErrorCode.unauthorized));
        expect(LoginViewModel.isCredentialFailure(viewModel.failure!), isFalse);
        expect(viewModel.isSubmitting, isFalse);
      },
    );

    test('a server error says "server", never wrong credentials', () async {
      harness.backend
        ..loginStatus = 500
        ..loginBody = {'success': false};

      await viewModel.submit(username: 'ayse', password: 'sifre');

      expect(viewModel.failure, AppErrorCode.server);
    });

    test('tells the screen on every change', () async {
      await viewModel.submit(username: 'ayse', password: 'sifre');

      expect(notifications, greaterThanOrEqualTo(1));
    });
  });

  group('isCredentialFailure', () {
    test('only the codes that mean the pair did not match', () {
      expect(
        LoginViewModel.isCredentialFailure(AppErrorCode.unauthorized),
        isTrue,
      );
      expect(
        LoginViewModel.isCredentialFailure(AppErrorCode.validation),
        isTrue,
      );
      expect(LoginViewModel.isCredentialFailure(AppErrorCode.network), isFalse);
      expect(LoginViewModel.isCredentialFailure(AppErrorCode.timeout), isFalse);
      expect(LoginViewModel.isCredentialFailure(AppErrorCode.server), isFalse);
    });
  });

  group('prefill', () {
    test('hands the user name to the screen and counts it', () {
      viewModel.prefill('ayse');

      expect(viewModel.prefillUsername, 'ayse');
      expect(viewModel.prefillCount, 1);
      expect(notifications, 1);
    });

    test('an empty name is ignored', () {
      viewModel.prefill('');

      expect(viewModel.prefillUsername, isNull);
      expect(viewModel.prefillCount, 0);
    });
  });

  group('flags', () {
    test('both variants are closed unless the flags say otherwise', () {
      expect(viewModel.forgotPasswordEnabled, isFalse);
      expect(viewModel.socialLoginEnabled, isFalse);
    });

    test('a closed reset flow does not open', () async {
      // The router has no screen attached here; opening would throw.
      await viewModel.openForgotPassword();

      expect(viewModel.isSubmitting, isFalse);
    });
  });
}
