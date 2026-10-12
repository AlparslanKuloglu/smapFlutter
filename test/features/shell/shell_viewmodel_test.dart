import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/app_router.dart';
import 'package:smap/core/services/connectivity_service.dart';
import 'package:smap/core/services/device_preferences.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/core/theme/app_spacing.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/shell/presentation/shell_viewmodel.dart';
import 'package:smap/shared/ui/feedback/toast_host.dart';
import 'package:smap/shared/ui/feedback/toast_slot.dart';

// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import '../../core/services/fake_connectivity.dart';

class _NoPresenter implements ToastPresenter {
  @override
  bool screenReaderOn = false;

  @override
  bool present(ToastSlot slot, ValueListenable<double?> barHeight) => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppRouter router;
  late ToastService toast;
  late ConnectivityService connectivity;
  late ShellViewModel viewModel;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    router = AppRouter(
      session: () => const SessionState.signedOut(),
      preferences: await DevicePreferences.load(),
    );
    toast = ToastService(presenter: _NoPresenter());
    connectivity = ConnectivityService(connectivity: FakeConnectivity());
    viewModel = ShellViewModel(
      router: router,
      toast: toast,
      connectivity: connectivity,
    );
  });

  tearDown(() {
    viewModel.dispose();
    toast.dispose();
  });

  test('the toast starts without a bar offset', () {
    expect(toast.bottomBarHeight.value, isNull);
  });

  test('a shell on top gives the toast the bar height', () {
    viewModel.updateBar(const ['StudentShellRoute']);

    expect(toast.bottomBarHeight.value, AppSize.bottomBar);
  });

  test('the coach shell counts too', () {
    viewModel.updateBar(const ['CoachShellRoute']);

    expect(toast.bottomBarHeight.value, AppSize.bottomBar);
  });

  test('the scan flow over the shell clears it, closing it brings it back', () {
    viewModel.updateBar(const ['StudentShellRoute']);

    viewModel.updateBar(const ['StudentShellRoute', 'ScanFlowRoute']);
    expect(toast.bottomBarHeight.value, isNull);

    viewModel.updateBar(const ['StudentShellRoute']);
    expect(toast.bottomBarHeight.value, AppSize.bottomBar);
  });

  test('a screen without a shell has no bar offset', () {
    viewModel.updateBar(const ['StudentShellRoute']);

    viewModel.updateBar(const ['WelcomeRoute']);

    expect(toast.bottomBarHeight.value, isNull);
  });

  test('the shell routes are the two the guards know', () {
    expect(ShellViewModel.shellRouteNames, {
      StudentShellRoute.name,
      CoachShellRoute.name,
    });
  });

  test('the offline strip follows the connectivity service', () {
    expect(viewModel.online, same(connectivity.online));
  });
}
