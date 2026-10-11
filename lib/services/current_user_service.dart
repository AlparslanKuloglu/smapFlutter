import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_result.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/services/session_manager.dart';
import 'package:stacked/stacked.dart';

/// The signed-in user as a reactive value for ViewModels.
///
/// Lives in the `session` DI scope: it is created after sign-in or restore and
/// disposed with the scope, so a ViewModel can never read the previous user.
/// It follows [SessionManager] (a refresh at launch, a profile edit, an expired
/// session) and writes changes back through it, so the secure cache stays the
/// same value.
///
/// Listen with `ListenableServiceMixin` (`listenToServices`) in a
/// ViewModel; the value changes only when the user data does.
class CurrentUserService with ListenableServiceMixin {
  CurrentUserService({required SessionManager session}) : _session = session {
    _user.value = session.user;
    session.addListener(_sync);
    listenToReactiveValues([_user]);
  }

  final SessionManager _session;
  final ReactiveValue<UserDto?> _user = ReactiveValue<UserDto?>(null);

  /// The current user. Stays the last known one while the session is expired
  /// (the screen is still showing it behind the sheet); `null` only before the
  /// first sign-in.
  UserDto? get user => _user.value;

  /// The user's role; [UserRole.unknown] without a user.
  UserRole get role => _user.value?.userRole ?? UserRole.unknown;

  bool get isStudent => role.isStudent;

  bool get isCoach => role.isCoach;

  /// Replaces the user (after the profile screen saved a change) and caches
  /// it.
  Future<void> update(UserDto user) => _session.updateUser(user);

  /// Reloads the user from the server (`/ajax/checkUser`).
  Future<AppResult<UserDto>> refresh() => _session.refreshUser();

  void _sync() {
    final next = _session.user;
    // A signed-out manager leaves the last user in place: the screens behind
    // the "oturum bitti" sheet keep their data, and the scope drop ends this
    // service for a real sign-out.
    if (next != null) _user.value = next;
  }

  void dispose() => _session.removeListener(_sync);
}
