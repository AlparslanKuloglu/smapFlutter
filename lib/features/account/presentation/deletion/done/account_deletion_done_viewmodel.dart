import 'package:stacked/stacked.dart';

import 'package:smap/services/session_manager.dart';

/// The logic of "Hesabın silindi" (pano 9.4 kare 5).
///
/// "Tamam" ends the session on the device (`completeAccountDeletion`: cookie,
/// cached user, legacy keys and the session scope go; `/ajax/logout` is not
/// called, the session no longer exists on the server). The router's guards
/// see the signed-out state and move to "Hoş geldin" (2.2 kare 5). No
/// haptic.
class AccountDeletionDoneViewModel extends BaseViewModel {
  AccountDeletionDoneViewModel({required SessionManager session})
    : _session = session;

  final SessionManager _session;

  bool _finishing = false;

  /// "Tamam".
  Future<void> finish() async {
    if (_finishing) return;
    _finishing = true;
    await _session.completeAccountDeletion();
  }
}
