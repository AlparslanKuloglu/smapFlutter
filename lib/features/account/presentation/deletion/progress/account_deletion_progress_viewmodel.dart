import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';

/// The logic of "Hesabın siliniyor" (pano 9.4 kare 4; spec §4.C 9.4
/// "Davranış").
///
/// [start] makes the one call, `GET /ajax/deleteAccount`, the moment the
/// screen is up, and only once however often the screen is built. The call is
/// idempotent on the server. Success moves on to "Hesabın silindi" (the
/// session is still open there; it is ended by that screen's "Tamam"), a
/// failure goes back to the explanation. No haptic here: the explanation
/// plays the `error` one.
class AccountDeletionProgressViewModel extends BaseViewModel {
  AccountDeletionProgressViewModel({
    required AccountRepository account,
    required AccountDeletionProgressNavigator navigator,
  }) : _account = account,
       _navigator = navigator;

  final AccountRepository _account;
  final AccountDeletionProgressNavigator _navigator;

  bool _started = false;
  bool _disposed = false;

  /// Deletes the account; later calls do nothing.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final result = await _account.deleteAccount();
    if (_disposed) return;
    if (result.leftOrNull == null) {
      _navigator.showDone();
    } else {
      _navigator.showFailure();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
