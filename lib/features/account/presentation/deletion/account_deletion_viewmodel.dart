import 'package:stacked/stacked.dart';

import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/core/services/app_haptics.dart';
import 'package:smap/features/account/application/deletion_consequences.dart';
import 'package:smap/features/account/data/account_repository.dart';
import 'package:smap/features/account/presentation/deletion/deletion_dialogs.dart';
import 'package:smap/features/account/presentation/deletion/deletion_navigator.dart';
import 'package:smap/services/current_user_service.dart';

/// The logic of "Hesabını sil" (pano 9.4 kare 2 and 3; spec §4.C 9.4).
///
/// - The list of what is lost is built from what the account carries: the
///   number of read exams (`UserDto.totalMexam`) and the coach, whose name
///   comes from `getStudentsCoach` (loaded in the background; until it
///   arrives the line says "Koçunla" and nothing about the name). A student
///   without a coach gets no coach line.
/// - "Hesabımı Sil" asks the dangerous confirmation, and on "Hesabımı Sil"
///   there opens the full-screen deletion. When that comes back failed, the
///   explanation shows the line "Hesabın silinemedi. Bağlantını kontrol edip
///   tekrar dene." in an error box (the board leaves toast or inline open;
///   inline stays until the next try) and the `error` haptic plays.
/// - "Vazgeç" closes the screen.
class AccountDeletionViewModel extends BaseViewModel {
  AccountDeletionViewModel({
    required CurrentUserService currentUser,
    required AccountRepository account,
    required AccountDeletionDialogs dialogs,
    required AccountDeletionNavigator navigator,
  }) : _currentUser = currentUser,
       _account = account,
       _dialogs = dialogs,
       _navigator = navigator;

  final CurrentUserService _currentUser;
  final AccountRepository _account;
  final AccountDeletionDialogs _dialogs;
  final AccountDeletionNavigator _navigator;

  bool _coachLoaded = false;
  String? _coachName;
  bool _hasCoach = false;
  bool _failed = false;
  bool _busy = false;
  bool _disposed = false;

  /// How many exams the student has read; `null` when the account does not
  /// say, and then the sentence has no number.
  int? get examCount => _currentUser.user?.totalMexam;

  /// The student has a coach: the answer of `getStudentsCoach` once it is in,
  /// the account's own `coach` field before.
  bool get hasCoach =>
      _coachLoaded ? _hasCoach : (_currentUser.user?.coach ?? '').isNotEmpty;

  /// The coach's name, once known.
  String? get coachName => _coachName;

  /// The last deletion failed; the error box is drawn.
  bool get failed => _failed;

  /// Loads the coach's name for the list. Failure is silent: the line then
  /// has no name.
  Future<void> init() async {
    final result = await _account.getMyCoach();
    if (_disposed) return;
    final user = result.rightOrNull;
    if (result.leftOrNull != null) return;
    _coachLoaded = true;
    _hasCoach = user != null;
    final name = user?.name?.trim();
    _coachName = name == null || name.isEmpty ? null : name;
    notifyListeners();
  }

  /// "Hesabımı Sil" on the explanation.
  Future<void> requestDeletion() async {
    if (_busy) return;
    _busy = true;
    try {
      final confirmed = await _dialogs.confirmDeletion(
        userName: _currentUser.user?.name,
      );
      if (!confirmed || _disposed) return;
      if (_failed) {
        _failed = false;
        notifyListeners();
      }
      final outcome = await _navigator.openProgress();
      if (_disposed) return;
      if (outcome == false) {
        _failed = true;
        AppHaptics.error();
        notifyListeners();
      }
    } finally {
      _busy = false;
    }
  }

  /// "Vazgeç".
  void cancel() => _navigator.close();

  /// The lines of the list.
  List<DeletionConsequence> get consequences => DeletionConsequences.of(
    examCount: examCount,
    hasCoach: hasCoach,
    coachName: _coachName,
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
