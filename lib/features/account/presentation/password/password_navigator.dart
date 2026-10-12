import 'package:auto_route/auto_route.dart';

/// Where "Şifre" leads (pano 9.3 kare 3: back to Hesap). The ViewModel holds
/// this instead of a router, so it stays free of the generated route classes
/// and of a `BuildContext` (UI guide §6 rule 16).
abstract interface class PasswordNavigator {
  /// Closes the screen; Hesap is under it.
  void close();
}

/// [PasswordNavigator] on auto_route; [_router] is the stack router of the
/// screen (`context.router`), the Hesap tab's own stack.
class RouterPasswordNavigator implements PasswordNavigator {
  const RouterPasswordNavigator(this._router);

  final StackRouter _router;

  @override
  void close() => _router.maybePop();
}
