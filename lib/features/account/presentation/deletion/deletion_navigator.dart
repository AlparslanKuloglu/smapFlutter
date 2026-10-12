import 'package:auto_route/auto_route.dart';

import 'package:smap/app/router/app_router.dart';

/// Where "Hesabını sil" leads (pano 9.4; spec §4.C 9.4 "Route önerisi"): the
/// ViewModels hold this instead of a router, so a test can record the calls.
abstract interface class AccountDeletionNavigator {
  /// Opens the full-screen "Hesabın siliniyor" over the shell and its bottom
  /// bar (kare 4) and completes when it is closed: `false` when the deletion
  /// failed and the screen went back to the explanation; `null` when it
  /// moved on to "Hesabın silindi".
  Future<bool?> openProgress();

  /// Closes the explanation ("Vazgeç"), back to Profil or wherever it was
  /// opened from.
  void close();
}

/// [AccountDeletionNavigator] on auto_route; [_router] is the stack router of
/// the explanation (`context.router`), the Hesap tab's own stack.
class RouterAccountDeletionNavigator implements AccountDeletionNavigator {
  const RouterAccountDeletionNavigator(this._router);

  final StackRouter _router;

  @override
  Future<bool?> openProgress() =>
      _router.root.push<bool>(const AccountDeletionProgressRoute());

  @override
  void close() => _router.maybePop();
}

/// Where the full-screen "Hesabın siliniyor" goes.
abstract interface class AccountDeletionProgressNavigator {
  /// The account is gone: "Hesabın silindi" replaces this screen (kare 5).
  void showDone();

  /// The deletion failed: back to the explanation (kare 4 "Hata olursa
  /// açıklama ekranına dönülür").
  void showFailure();
}

/// [AccountDeletionProgressNavigator] on auto_route; [_router] is the root
/// router (`context.router` of a root route).
class RouterAccountDeletionProgressNavigator
    implements AccountDeletionProgressNavigator {
  const RouterAccountDeletionProgressNavigator(this._router);

  final StackRouter _router;

  @override
  void showDone() => _router.replace(const AccountDeletionDoneRoute());

  /// `pop`, not `maybePop`: the screen is blocking (`PopScope`), and `maybePop`
  /// would ask that and be told no.
  @override
  void showFailure() => _router.pop<bool>(false);
}
