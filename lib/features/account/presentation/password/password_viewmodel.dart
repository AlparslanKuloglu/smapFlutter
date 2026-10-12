import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/core/services/toast_service.dart';
import 'package:smap/features/account/application/password_repository.dart';
import 'package:smap/features/account/application/password_rules.dart';
import 'package:smap/features/account/presentation/password/password_navigator.dart';

/// The logic of "Şifre" (pano 9.3 kare 1 to 3; spec §4.C "9.3").
///
/// - The primary button is open only while the three fields hold something
///   ([canSubmit]); "Düğme yalnız alanlar doluyken çalışır".
/// - On "Şifreyi Güncelle" the typed values are checked first
///   ([PasswordRules.check]: at least 8 characters, not the same as the
///   current one, the two new ones equal); a problem is drawn under its
///   field, the screen takes the focus there ([focusRequests] counts it) and
///   the `error` haptic plays.
/// - Then the server checks the current password. A refusal is
///   [PasswordIssue.wrongCurrent] (kare 2: the focus stays on the first
///   field and the new ones are kept); any other failure is a toast and the
///   form keeps what was typed.
/// - Success: back to Hesap and the toast "Şifren güncellendi." (kare 3).
///   This device's session stays open; the server ends the others.
///
/// Editing any field clears the red. The ViewModel never holds the typed
/// passwords: the screen's controllers do, and hand them over on submit.
class PasswordViewModel extends BaseViewModel {
  PasswordViewModel({
    required PasswordRepository repository,
    required PasswordNavigator navigator,
    required ToastService toast,
  }) : _repository = repository,
       _navigator = navigator,
       _toast = toast;

  final PasswordRepository _repository;
  final PasswordNavigator _navigator;
  final ToastService _toast;

  final ValueNotifier<bool> _canSubmit = ValueNotifier<bool>(false);

  bool _sending = false;
  PasswordIssue? _issue;
  int _focusRequests = 0;
  bool _disposed = false;

  /// The three fields are filled in: the primary button works. Changes with
  /// every keystroke, so it is a `ValueListenable` and not part of the state.
  ValueListenable<bool> get canSubmit => _canSubmit;

  /// The new password is being saved.
  bool get isSending => _sending;

  /// What is wrong, drawn under [PasswordIssue.field].
  PasswordIssue? get issue => _issue;

  /// Counts the times the screen must move the focus to [issue]'s field, so
  /// the same issue twice in a row still does.
  int get focusRequests => _focusRequests;

  /// A field changed: the button follows the fields and the red goes away.
  void edited({
    required String current,
    required String next,
    required String repeat,
  }) {
    _canSubmit.value = PasswordRules.canSubmit(current, next, repeat);
    if (_issue == null) return;
    _issue = null;
    notifyListeners();
  }

  /// "Şifreyi Güncelle".
  Future<void> submit({
    required String current,
    required String next,
    required String repeat,
  }) async {
    if (_sending || !PasswordRules.canSubmit(current, next, repeat)) return;
    final problem = PasswordRules.check(current, next, repeat);
    if (problem != null) {
      _showIssue(problem);
      return;
    }
    _sending = true;
    _issue = null;
    notifyListeners();
    final result = await _repository.changePassword(
      currentPassword: current,
      newPassword: next,
    );
    if (_disposed) return;
    _sending = false;
    final failure = result.leftOrNull;
    if (failure == null) {
      _navigator.close();
      _toast.success((l10n) => l10n.password_updated);
      notifyListeners();
      return;
    }
    if (PasswordFailures.isWrongCurrent(failure)) {
      _showIssue(PasswordIssue.wrongCurrent);
      return;
    }
    _toast.error((l10n) => l10n.accountSettings_sendFailed);
    notifyListeners();
  }

  void _showIssue(PasswordIssue issue) {
    _issue = issue;
    _focusRequests++;
    AppHaptics.error();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _canSubmit.dispose();
    super.dispose();
  }
}
