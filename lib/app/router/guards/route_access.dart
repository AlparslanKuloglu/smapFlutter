import 'package:flutter/foundation.dart';

import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/auth/domain/session_state.dart';

/// What a route is, for the guards. The router maps its generated route names
/// to a group (`AppRouter.groupOf`); everything below is plain Dart.
enum RouteGroup {
  /// The launch screen (`StartupRoute`); always reachable.
  startup,

  /// Full-screen stops that need nobody to be signed in or out: forced
  /// update, maintenance.
  blocking,

  /// The intro (`OnboardingRoute`): only before it was seen.
  onboarding,

  /// The doors of the signed-out app: welcome, sign-in, sign-up. Only while
  /// nobody is signed in.
  signedOutEntry,

  /// The student shell.
  studentShell,

  /// The coach shell.
  coachShell,

  /// "Hesabın açılamadı": only for a signed-in account whose role the app
  /// has no shell for.
  unknownRole,

  /// Any other route (details, sheets that are routes): never guarded.
  other,
}

/// Where a guard (or the launch screen) sends the user.
enum RouteTarget {
  onboarding,
  welcome,
  studentShell,
  coachShell,
  unknownRole,

  /// "Yeni sürüm gerekli"; only the launch screen sends here.
  forceUpdate,

  /// "SMAP şu an bakımda"; only the launch screen sends here.
  maintenance,
}

/// The verdict of a guard stage.
@immutable
sealed class AccessDecision {
  const AccessDecision();

  /// Let the navigation through.
  const factory AccessDecision.allow() = AccessAllow;

  /// Replace the whole stack with [target].
  const factory AccessDecision.redirect(RouteTarget target) = AccessRedirect;

  /// Drop the navigation and change nothing else (a sign-in that was opened
  /// over the screens of an expired session closes itself this way).
  const factory AccessDecision.reject() = AccessReject;
}

final class AccessAllow extends AccessDecision {
  const AccessAllow();

  @override
  bool operator ==(Object other) => other is AccessAllow;

  @override
  int get hashCode => (AccessAllow).hashCode;

  @override
  String toString() => 'allow';
}

final class AccessRedirect extends AccessDecision {
  const AccessRedirect(this.target);

  final RouteTarget target;

  @override
  bool operator ==(Object other) =>
      other is AccessRedirect && other.target == target;

  @override
  int get hashCode => Object.hash(AccessRedirect, target);

  @override
  String toString() => 'redirect(${target.name})';
}

final class AccessReject extends AccessDecision {
  const AccessReject();

  @override
  bool operator ==(Object other) => other is AccessReject;

  @override
  int get hashCode => (AccessReject).hashCode;

  @override
  String toString() => 'reject';
}

/// What the guards know when a navigation arrives.
@immutable
class AccessInput {
  const AccessInput({
    required this.group,
    required this.onboardingSeen,
    required this.session,
    this.shellInStack = false,
  });

  /// The route being opened.
  final RouteGroup group;

  /// The intro ran to its end (or an old install's flag was migrated).
  final bool onboardingSeen;

  /// The session as `SessionManager` reports it.
  final SessionState session;

  /// A shell is already on the root stack: a sign-in that arrives now is a
  /// re-login over an expired session, not a first sign-in.
  final bool shellInStack;
}

/// The shell (or stop) a signed-in [role] belongs to.
RouteTarget targetForRole(UserRole role) => switch (role) {
  UserRole.student => RouteTarget.studentShell,
  UserRole.coach => RouteTarget.coachShell,
  UserRole.unknown => RouteTarget.unknownRole,
};

RouteTarget _roleTargetOf(SessionState session) =>
    targetForRole(session.user?.userRole ?? UserRole.unknown);

/// Where the app opens once the session is decided (spec §3.1 "Global
/// redirect sırası", steps 3 to 5):
///
/// 1. the intro was not seen: the intro;
/// 2. nobody signed in: the welcome screen;
/// 3. a signed-in account: its shell, or "Hesabın açılamadı" for a role the
///    app does not know.
RouteTarget resolveLaunchTarget({
  required bool onboardingSeen,
  required SessionState session,
}) {
  if (!onboardingSeen) return RouteTarget.onboarding;
  if (!session.isSignedIn) return RouteTarget.welcome;
  return _roleTargetOf(session);
}

/// First stage of the guard chain (`OnboardingGuard`): the intro comes before
/// everything else.
AccessDecision onboardingStage(AccessInput input) {
  switch (input.group) {
    case RouteGroup.onboarding:
      // A finished intro never shows again.
      return input.onboardingSeen
          ? AccessDecision.redirect(
              resolveLaunchTarget(onboardingSeen: true, session: input.session),
            )
          : const AccessDecision.allow();
    case RouteGroup.signedOutEntry:
    case RouteGroup.studentShell:
    case RouteGroup.coachShell:
    case RouteGroup.unknownRole:
      return input.onboardingSeen
          ? const AccessDecision.allow()
          : const AccessDecision.redirect(RouteTarget.onboarding);
    case RouteGroup.startup:
    case RouteGroup.blocking:
    case RouteGroup.other:
      return const AccessDecision.allow();
  }
}

/// Second stage (`AuthGuard`): who is signed in.
///
/// - The doors are for the signed out. A signed-in account that reaches one
///   goes to its shell; when a shell is already open (a re-login over an
///   expired session) the door just closes ([AccessDecision.reject]) and the
///   user is back on the screen they were on.
/// - The shells and "Hesabın açılamadı" need a session. An expired one still
///   counts: the user stays on the screen behind the "oturum bitti" sheet.
///   While the session is not decided yet nothing opens (the launch screen
///   decides after `restore()`).
AccessDecision authStage(AccessInput input) {
  final session = input.session;
  switch (input.group) {
    case RouteGroup.signedOutEntry:
      if (!session.isSignedIn) return const AccessDecision.allow();
      return input.shellInStack
          ? const AccessDecision.reject()
          : AccessDecision.redirect(_roleTargetOf(session));
    case RouteGroup.studentShell:
    case RouteGroup.coachShell:
    case RouteGroup.unknownRole:
      if (session.isSignedIn || session.isExpired) {
        return const AccessDecision.allow();
      }
      return session.isResolved
          ? const AccessDecision.redirect(RouteTarget.welcome)
          : const AccessDecision.reject();
    case RouteGroup.startup:
    case RouteGroup.blocking:
    case RouteGroup.onboarding:
    case RouteGroup.other:
      return const AccessDecision.allow();
  }
}

/// Third stage (`RoleGuard`): the shell of the signed-in role, nothing else.
AccessDecision roleStage(AccessInput input) {
  final session = input.session;
  if (!session.isSignedIn) return const AccessDecision.allow();
  final own = _roleTargetOf(session);
  switch (input.group) {
    case RouteGroup.studentShell:
      return own == RouteTarget.studentShell
          ? const AccessDecision.allow()
          : AccessDecision.redirect(own);
    case RouteGroup.coachShell:
      return own == RouteTarget.coachShell
          ? const AccessDecision.allow()
          : AccessDecision.redirect(own);
    case RouteGroup.unknownRole:
      return own == RouteTarget.unknownRole
          ? const AccessDecision.allow()
          : AccessDecision.redirect(own);
    case RouteGroup.startup:
    case RouteGroup.blocking:
    case RouteGroup.onboarding:
    case RouteGroup.signedOutEntry:
    case RouteGroup.other:
      return const AccessDecision.allow();
  }
}

/// The three stages in the order the router runs them (onboarding, auth,
/// role); the first verdict that is not "allow" wins. The guards run one
/// stage each, so this is also what a navigation ends up as.
AccessDecision decideAccess(AccessInput input) {
  for (final stage in const [onboardingStage, authStage, roleStage]) {
    final decision = stage(input);
    if (decision is! AccessAllow) return decision;
  }
  return const AccessDecision.allow();
}

/// The part of a session state the router cares about. `RouteRefresh` wakes
/// the router only when this changes, so a sign-in's busy flag or a refreshed
/// profile photo does not re-run the guards.
@immutable
class SessionRouteKey {
  const SessionRouteKey({
    required this.resolved,
    required this.signedIn,
    required this.expired,
    required this.role,
  });

  factory SessionRouteKey.of(SessionState state) => SessionRouteKey(
    resolved: state.isResolved,
    signedIn: state.isSignedIn,
    expired: state.isExpired,
    role: state.user?.userRole,
  );

  final bool resolved;
  final bool signedIn;
  final bool expired;
  final UserRole? role;

  @override
  bool operator ==(Object other) =>
      other is SessionRouteKey &&
      other.resolved == resolved &&
      other.signedIn == signedIn &&
      other.expired == expired &&
      other.role == role;

  @override
  int get hashCode => Object.hash(resolved, signedIn, expired, role);
}
