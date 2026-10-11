import 'package:flutter/foundation.dart';

import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// Where the session stands (`SessionManager.state`).
///
/// ```
/// unknown --restore()--> restoring --> signedIn | signedOut
/// signedIn --signOut()--> signedOut
/// signedIn --401--> signedOut(expired: true) --signIn()--> signedIn
/// ```
@immutable
sealed class SessionState {
  const SessionState();

  /// Nothing decided yet: `restore()` has not run.
  const factory SessionState.unknown() = SessionUnknown;

  /// `restore()` is reading the stored session.
  const factory SessionState.restoring() = SessionRestoring;

  /// A user is signed in. [verified] is `false` while the user comes from the
  /// device cache and the server has not confirmed the session this launch
  /// (offline start, or the check is still running).
  const factory SessionState.signedIn(UserDto user, {bool verified}) =
      SessionSignedIn;

  /// No session. [expired] is `true` when the server ended a session the user
  /// was inside of; the UI then asks to sign in again on the same screen
  /// instead of going back to the welcome screen.
  const factory SessionState.signedOut({bool expired}) = SessionSignedOut;

  /// The signed-in user, `null` otherwise.
  UserDto? get user => switch (this) {
    SessionSignedIn(:final user) => user,
    _ => null,
  };

  bool get isSignedIn => this is SessionSignedIn;

  bool get isSignedOut => this is SessionSignedOut;

  /// `restore()` has finished: the state is signed in or signed out.
  bool get isResolved => isSignedIn || isSignedOut;

  /// Signed out because the server ended the session.
  bool get isExpired => switch (this) {
    SessionSignedOut(:final expired) => expired,
    _ => false,
  };
}

final class SessionUnknown extends SessionState {
  const SessionUnknown();

  @override
  bool operator ==(Object other) => other is SessionUnknown;

  @override
  int get hashCode => (SessionUnknown).hashCode;

  @override
  String toString() => 'SessionState.unknown';
}

final class SessionRestoring extends SessionState {
  const SessionRestoring();

  @override
  bool operator ==(Object other) => other is SessionRestoring;

  @override
  int get hashCode => (SessionRestoring).hashCode;

  @override
  String toString() => 'SessionState.restoring';
}

final class SessionSignedIn extends SessionState {
  const SessionSignedIn(this.user, {this.verified = false});

  @override
  final UserDto user;

  final bool verified;

  @override
  bool operator ==(Object other) =>
      other is SessionSignedIn &&
      other.user == user &&
      other.verified == verified;

  @override
  int get hashCode => Object.hash(SessionSignedIn, user, verified);

  @override
  String toString() => 'SessionState.signedIn(${user.id}, verified: $verified)';
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut({this.expired = false});

  final bool expired;

  @override
  bool operator ==(Object other) =>
      other is SessionSignedOut && other.expired == expired;

  @override
  int get hashCode => Object.hash(SessionSignedOut, expired);

  @override
  String toString() => 'SessionState.signedOut(expired: $expired)';
}
