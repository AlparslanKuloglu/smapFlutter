import 'package:stacked/stacked.dart';

import 'package:smap/features/startup/application/store_launcher.dart';
import 'package:smap/services/session_manager.dart';

/// "Hesabın açılamadı": the account's role is neither student nor coach.
class UnknownRoleViewModel extends BaseViewModel {
  UnknownRoleViewModel({
    required SessionManager session,
    required StoreLauncher launcher,
  }) : _session = session,
       _launcher = launcher;

  final SessionManager _session;
  final StoreLauncher _launcher;

  /// A support mailbox is configured; the "Destek'e Yaz" button shows only
  /// then (no address is invented).
  bool get canWriteSupport => _launcher.canWriteSupport;

  /// Signs out; the guards take the user to the welcome screen.
  Future<void> signInAgain() => _session.signOut();

  /// Opens a mail draft to support.
  Future<void> writeSupport() => _launcher.writeSupport();
}
