import 'package:smap/app/router/app_router.dart';
import 'package:smap/app/router/stack_router_x.dart';

/// Where the sign-up screen can go. The ViewModel talks to this seam; the
/// app gives it [RouterRegisterNavigator].
abstract interface class RegisterNavigator {
  /// "Giriş Yap" under the button (pano 2.5): the sign-in screen. When the
  /// sign-up was opened from it, this goes back instead of piling up.
  void openLogin();
}

/// [RegisterNavigator] over the app's router.
class RouterRegisterNavigator implements RegisterNavigator {
  const RouterRegisterNavigator(this._router);

  final AppRouter _router;

  @override
  void openLogin() => _router.pushOrPop(const LoginRoute());
}
