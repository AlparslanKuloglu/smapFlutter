import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/guards/route_access.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';

const _student = UserDto(id: 's1', role: 'student');
const _coach = UserDto(id: 'c1', role: 'coach');
const _teacher = UserDto(id: 'c2', role: 'teacher');
const _alien = UserDto(id: 'x1', role: 'admin');

SessionState _in(UserDto user) => SessionState.signedIn(user);
const SessionState _out = SessionState.signedOut();
const SessionState _expired = SessionState.signedOut(expired: true);
const SessionState _restoring = SessionState.restoring();

AccessInput _input(
  RouteGroup group,
  SessionState session, {
  bool seen = true,
  bool shellInStack = false,
}) => AccessInput(
  group: group,
  onboardingSeen: seen,
  session: session,
  shellInStack: shellInStack,
);

void main() {
  group('resolveLaunchTarget', () {
    test('the intro comes first, signed in or not', () {
      expect(
        resolveLaunchTarget(onboardingSeen: false, session: _out),
        RouteTarget.onboarding,
      );
      expect(
        resolveLaunchTarget(onboardingSeen: false, session: _in(_student)),
        RouteTarget.onboarding,
      );
    });

    test('intro seen, nobody signed in: the welcome screen', () {
      expect(
        resolveLaunchTarget(onboardingSeen: true, session: _out),
        RouteTarget.welcome,
      );
    });

    test('intro seen, signed in: the shell of the role', () {
      expect(
        resolveLaunchTarget(onboardingSeen: true, session: _in(_student)),
        RouteTarget.studentShell,
      );
      expect(
        resolveLaunchTarget(onboardingSeen: true, session: _in(_coach)),
        RouteTarget.coachShell,
      );
    });

    test('"teacher" is a coach, an unknown role has its own stop', () {
      expect(
        resolveLaunchTarget(onboardingSeen: true, session: _in(_teacher)),
        RouteTarget.coachShell,
      );
      expect(
        resolveLaunchTarget(onboardingSeen: true, session: _in(_alien)),
        RouteTarget.unknownRole,
      );
      expect(
        resolveLaunchTarget(
          onboardingSeen: true,
          session: _in(const UserDto(id: 'n1')),
        ),
        RouteTarget.unknownRole,
      );
    });
  });

  group('onboardingStage', () {
    test('a route before the intro was seen goes to the intro', () {
      for (final group in [
        RouteGroup.signedOutEntry,
        RouteGroup.studentShell,
        RouteGroup.coachShell,
        RouteGroup.unknownRole,
      ]) {
        expect(
          onboardingStage(_input(group, _in(_student), seen: false)),
          const AccessDecision.redirect(RouteTarget.onboarding),
          reason: group.name,
        );
      }
    });

    test('the intro itself opens only while it was not seen', () {
      expect(
        onboardingStage(_input(RouteGroup.onboarding, _out, seen: false)),
        const AccessDecision.allow(),
      );
      expect(
        onboardingStage(_input(RouteGroup.onboarding, _out)),
        const AccessDecision.redirect(RouteTarget.welcome),
      );
      expect(
        onboardingStage(_input(RouteGroup.onboarding, _in(_coach))),
        const AccessDecision.redirect(RouteTarget.coachShell),
      );
    });

    test('the launch screen and the stop screens never wait for the intro', () {
      for (final group in [
        RouteGroup.startup,
        RouteGroup.blocking,
        RouteGroup.other,
      ]) {
        expect(
          onboardingStage(_input(group, _out, seen: false)),
          const AccessDecision.allow(),
          reason: group.name,
        );
      }
    });
  });

  group('authStage', () {
    test('a shell needs a session', () {
      for (final group in [RouteGroup.studentShell, RouteGroup.coachShell]) {
        expect(
          authStage(_input(group, _out)),
          const AccessDecision.redirect(RouteTarget.welcome),
          reason: group.name,
        );
        expect(
          authStage(_input(group, _in(_student))),
          const AccessDecision.allow(),
        );
      }
    });

    test('an expired session keeps the screens it is on', () {
      expect(
        authStage(_input(RouteGroup.studentShell, _expired)),
        const AccessDecision.allow(),
      );
    });

    test('nothing opens while the session is not decided', () {
      expect(
        authStage(_input(RouteGroup.studentShell, _restoring)),
        const AccessDecision.reject(),
      );
      expect(
        authStage(_input(RouteGroup.startup, _restoring)),
        const AccessDecision.allow(),
      );
    });

    test('the doors are for the signed out', () {
      expect(
        authStage(_input(RouteGroup.signedOutEntry, _out)),
        const AccessDecision.allow(),
      );
      expect(
        authStage(_input(RouteGroup.signedOutEntry, _expired)),
        const AccessDecision.allow(),
      );
    });

    test('a first sign-in moves on to the shell of the role', () {
      expect(
        authStage(_input(RouteGroup.signedOutEntry, _in(_student))),
        const AccessDecision.redirect(RouteTarget.studentShell),
      );
      expect(
        authStage(_input(RouteGroup.signedOutEntry, _in(_coach))),
        const AccessDecision.redirect(RouteTarget.coachShell),
      );
    });

    test('a re-login over an open shell just closes itself', () {
      expect(
        authStage(
          _input(RouteGroup.signedOutEntry, _in(_student), shellInStack: true),
        ),
        const AccessDecision.reject(),
      );
    });
  });

  group('roleStage', () {
    test('a student gets the student shell and no other', () {
      expect(
        roleStage(_input(RouteGroup.studentShell, _in(_student))),
        const AccessDecision.allow(),
      );
      expect(
        roleStage(_input(RouteGroup.coachShell, _in(_student))),
        const AccessDecision.redirect(RouteTarget.studentShell),
      );
    });

    test('a coach gets the coach shell and no other', () {
      expect(
        roleStage(_input(RouteGroup.coachShell, _in(_coach))),
        const AccessDecision.allow(),
      );
      expect(
        roleStage(_input(RouteGroup.studentShell, _in(_coach))),
        const AccessDecision.redirect(RouteTarget.coachShell),
      );
    });

    test('an unknown role lands on "Hesabın açılamadı" from any shell', () {
      for (final group in [RouteGroup.studentShell, RouteGroup.coachShell]) {
        expect(
          roleStage(_input(group, _in(_alien))),
          const AccessDecision.redirect(RouteTarget.unknownRole),
          reason: group.name,
        );
      }
      expect(
        roleStage(_input(RouteGroup.unknownRole, _in(_alien))),
        const AccessDecision.allow(),
      );
    });

    test('a known role has no business on "Hesabın açılamadı"', () {
      expect(
        roleStage(_input(RouteGroup.unknownRole, _in(_student))),
        const AccessDecision.redirect(RouteTarget.studentShell),
      );
    });

    test('without a signed-in user the stage has no opinion', () {
      expect(
        roleStage(_input(RouteGroup.studentShell, _expired)),
        const AccessDecision.allow(),
      );
    });
  });

  group('decideAccess (the chain: onboarding, auth, role)', () {
    test('onboarding beats auth and role', () {
      expect(
        decideAccess(_input(RouteGroup.coachShell, _out, seen: false)),
        const AccessDecision.redirect(RouteTarget.onboarding),
      );
    });

    test('auth beats role', () {
      expect(
        decideAccess(_input(RouteGroup.coachShell, _out)),
        const AccessDecision.redirect(RouteTarget.welcome),
      );
    });

    test('a signed-in student opening the coach shell ends on her own', () {
      expect(
        decideAccess(_input(RouteGroup.coachShell, _in(_student))),
        const AccessDecision.redirect(RouteTarget.studentShell),
      );
    });

    test('the happy paths pass', () {
      expect(
        decideAccess(_input(RouteGroup.studentShell, _in(_student))),
        const AccessDecision.allow(),
      );
      expect(
        decideAccess(_input(RouteGroup.coachShell, _in(_teacher))),
        const AccessDecision.allow(),
      );
      expect(
        decideAccess(_input(RouteGroup.signedOutEntry, _out)),
        const AccessDecision.allow(),
      );
      expect(
        decideAccess(_input(RouteGroup.startup, _restoring, seen: false)),
        const AccessDecision.allow(),
      );
    });

    test('a redirect never points at a route that redirects again', () {
      // Whatever a guard answers, following the answer must end in "allow":
      // otherwise a navigation loops.
      const sessions = <SessionState>[
        SessionState.unknown(),
        _restoring,
        _out,
        _expired,
      ];
      final signedIn = [_in(_student), _in(_coach), _in(_alien)];
      for (final session in [...sessions, ...signedIn]) {
        for (final seen in [true, false]) {
          for (final group in RouteGroup.values) {
            final decision = decideAccess(_input(group, session, seen: seen));
            if (decision is! AccessRedirect) continue;
            final next = _groupOf(decision.target);
            final again = decideAccess(_input(next, session, seen: seen));
            expect(
              again,
              isNot(isA<AccessRedirect>()),
              reason:
                  '${group.name} / $session / seen=$seen -> '
                  '${decision.target.name} -> $again',
            );
          }
        }
      }
    });
  });

  group('targetForRole', () {
    test('maps every role', () {
      expect(targetForRole(UserRole.student), RouteTarget.studentShell);
      expect(targetForRole(UserRole.coach), RouteTarget.coachShell);
      expect(targetForRole(UserRole.unknown), RouteTarget.unknownRole);
    });
  });

  group('SessionRouteKey', () {
    test('ignores a refreshed profile, sees a role change', () {
      final a = SessionRouteKey.of(
        _in(const UserDto(id: '1', role: 'student')),
      );
      final b = SessionRouteKey.of(
        _in(const UserDto(id: '1', role: 'student', name: 'Yeni Ad')),
      );
      final c = SessionRouteKey.of(_in(const UserDto(id: '1', role: 'coach')));

      expect(a, b);
      expect(a, isNot(c));
    });

    test('tells apart signed out, expired and undecided', () {
      final keys = {
        SessionRouteKey.of(const SessionState.unknown()),
        SessionRouteKey.of(_out),
        SessionRouteKey.of(_expired),
        SessionRouteKey.of(_in(_student)),
      };
      // unknown and restoring share a key: both are "not decided".
      expect(
        SessionRouteKey.of(_restoring),
        SessionRouteKey.of(const SessionState.unknown()),
      );
      expect(keys, hasLength(4));
    });
  });
}

RouteGroup _groupOf(RouteTarget target) => switch (target) {
  RouteTarget.onboarding => RouteGroup.onboarding,
  RouteTarget.welcome => RouteGroup.signedOutEntry,
  RouteTarget.studentShell => RouteGroup.studentShell,
  RouteTarget.coachShell => RouteGroup.coachShell,
  RouteTarget.unknownRole => RouteGroup.unknownRole,
  RouteTarget.forceUpdate || RouteTarget.maintenance => RouteGroup.blocking,
};
