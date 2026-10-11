import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/requests/auth_requests.dart';
import 'package:smap/features/auth/domain/session_state.dart';

import '../features/auth/data/auth_fixtures.dart';
import 'session_harness.dart';

void main() {
  late SessionHarness h;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    h = SessionHarness();
  });

  tearDown(() => h.dispose());

  group('restore', () {
    test('starts unknown', () {
      expect(h.manager.state, const SessionState.unknown());
      expect(h.manager.isSignedIn, isFalse);
      expect(h.manager.user, isNull);
    });

    test('no cookie and no cache: signed out, nothing contacted', () async {
      await h.manager.restore();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.history, [
        const SessionState.restoring(),
        const SessionState.signedOut(),
      ]);
      expect(h.backend.requests, isEmpty);
      expect(h.pushes, 0);
    });

    test('a cached user without a cookie is stale: dropped', () async {
      await h.store.write(UserDto.fromJson(studentJson()));

      await h.manager.restore();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.secure.values, isEmpty);
      expect(h.pushes, 0);
    });

    test(
      'a cached user opens the app at once, then the server confirms',
      () async {
        await h.leaveSignedInSession();

        await h.manager.restore();
        await h.manager.revalidate();

        expect(h.history.map((s) => s.runtimeType), [
          SessionRestoring,
          SessionSignedIn,
          SessionSignedIn,
        ]);
        final optimistic = h.history[1] as SessionSignedIn;
        expect(optimistic.verified, isFalse);
        expect(optimistic.user.name, 'Eski Ad');
        final confirmed = h.manager.state as SessionSignedIn;
        expect(confirmed.verified, isTrue);
        expect(
          confirmed.user.name,
          'Ayşe Yılmaz',
          reason: 'refreshed from checkUser',
        );
        expect((await h.store.read())?.name, 'Ayşe Yılmaz');
        expect(h.pushes, 1);
        expect(h.backend.calls('/ajax/checkUser'), hasLength(1));
      },
    );

    test(
      'offline: opens on the cached user and does not call the server',
      () async {
        await h.leaveSignedInSession();
        await h.goOffline();

        await h.manager.restore();
        await h.manager.revalidate();

        final state = h.manager.state as SessionSignedIn;
        expect(state.verified, isFalse);
        expect(state.user.name, 'Eski Ad');
        expect(h.backend.requests, isEmpty);
        expect(h.pushes, 1);
      },
    );

    test(
      'a failed check (offline mid-check, 5xx) keeps the cached session',
      () async {
        await h.leaveSignedInSession();
        h.backend.checkUserFailsWith = 500;

        await h.manager.restore();
        await h.manager.revalidate();

        expect(h.manager.state, isA<SessionSignedIn>());
        expect((h.manager.state as SessionSignedIn).verified, isFalse);
        expect(h.pops, 0);

        h.backend
          ..checkUserFailsWith = null
          ..online = false;
        await h.manager.revalidate();
        expect(h.manager.state.isSignedIn, isTrue);
      },
    );

    test(
      'the server rejecting the cached session expires it, scope kept',
      () async {
        await h.leaveSignedInSession();
        h.backend.validCookie = 'another-cookie';

        await h.manager.restore();
        await h.manager.revalidate();

        expect(h.manager.state, const SessionState.signedOut(expired: true));
        expect(h.pushes, 1);
        expect(h.pops, 0, reason: 'the screens behind the sheet stay alive');
        expect(h.history.where((s) => s.isExpired), hasLength(1));
      },
    );

    test('a redirect to the login page also expires it', () async {
      await h.leaveSignedInSession();
      h.backend
        ..validCookie = 'another-cookie'
        ..noSessionStatus = 302;

      await h.manager.restore();
      await h.manager.revalidate();

      expect(h.manager.state, const SessionState.signedOut(expired: true));
    });

    test('a cookie but no cache: the server says who it is', () async {
      h.backend.startSession();
      await saveSessionCookie(h.jar);

      await h.manager.restore();

      final state = h.manager.state as SessionSignedIn;
      expect(state.verified, isTrue);
      expect(state.user.id, 'student-1');
      expect((await h.store.read())?.id, 'student-1');
      expect(h.pushes, 1);
    });

    test(
      'a cookie the server rejects and no cache: signed out, cookie gone',
      () async {
        await saveSessionCookie(h.jar);

        await h.manager.restore();

        expect(h.manager.state, const SessionState.signedOut());
        expect(await h.hasCookie(), isFalse);
        expect(h.pushes, 0);
      },
    );

    test(
      'a cookie, no cache and no connection: signed out, cookie kept',
      () async {
        await saveSessionCookie(h.jar);
        await h.goOffline();

        await h.manager.restore();

        expect(h.manager.state, const SessionState.signedOut());
        expect(await h.hasCookie(), isTrue);
        expect(h.backend.requests, isEmpty);
      },
    );

    test('an unreadable keychain does not log the user out', () async {
      h.backend.startSession();
      await saveSessionCookie(h.jar);
      h.secure.failReads = 10;

      await h.manager.restore();

      expect(h.manager.state, isA<SessionSignedIn>());
      expect((h.manager.state as SessionSignedIn).verified, isTrue);
    });

    test(
      'moves a legacy plain-text user first, so today\'s user stays in',
      () async {
        SharedPreferences.setMockInitialValues({
          'user_data':
              '{"_id":"student-1","role":"student","name":"Legacy Ad",'
              '"password":"hash"}',
          'isLoggedIn': true,
        });
        h.backend.startSession();
        await saveSessionCookie(h.jar);
        await h.goOffline();

        await h.manager.restore();

        final state = h.manager.state as SessionSignedIn;
        expect(state.user.name, 'Legacy Ad');
        expect(state.verified, isFalse);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('user_data'), isNull);
        expect(prefs.getBool('isLoggedIn'), isNull);
        expect(
          await h.hasCookie(),
          isTrue,
          reason: 'the cookie jar is untouched',
        );
      },
    );

    test('is idempotent', () async {
      await h.leaveSignedInSession();

      final first = h.manager.restore();
      final second = h.manager.restore();
      await Future.wait([first, second]);
      await h.manager.restore();

      expect(h.pushes, 1);
      expect(h.history.whereType<SessionRestoring>(), hasLength(1));
    });

    test('a scope that cannot start leaves the app signed out', () async {
      await h.leaveSignedInSession();
      h.pushError = StateError('module failed');

      await h.manager.restore();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.pops, 1, reason: 'a half-pushed scope is dropped');
    });
  });

  group('signIn', () {
    test(
      'logs in, confirms with checkUser, caches the user, opens the scope',
      () async {
        final result = await h.manager.signIn(
          username: 'ayse',
          password: 'secret-1',
        );

        expect(result.rightOrNull?.id, 'student-1');
        expect(h.manager.state, isA<SessionSignedIn>());
        expect((h.manager.state as SessionSignedIn).verified, isTrue);
        expect(h.manager.user?.name, 'Ayşe Yılmaz');
        expect(h.pushes, 1);
        expect((await h.store.read())?.id, 'student-1');
        expect(await h.hasCookie(), isTrue);
        expect(h.backend.requests.map((r) => r.path), [
          '/student/login',
          '/ajax/checkUser',
        ]);
        expect(h.manager.isSigningIn, isFalse);
      },
    );

    test('the scope opens before the screens are told', () async {
      var pushedWhenNotified = 0;
      h.manager.addListener(() {
        if (h.manager.isSignedIn) pushedWhenNotified = h.pushes;
      });

      await h.manager.signIn(username: 'a', password: 'b');

      expect(pushedWhenNotified, 1);
    });

    test('a login answered with a 302 and the user works too', () async {
      h.backend.loginStatus = 302;

      final result = await h.manager.signIn(username: 'a', password: 'b');

      expect(result.isRight(), isTrue);
    });

    test('wrong credentials: unauthorized, nothing left behind', () async {
      h.backend
        ..acceptCredentials = false
        ..rejectStatus = 401;

      final result = await h.manager.signIn(username: 'a', password: 'wrong');

      expect(result.leftOrNull?.code, AppErrorCode.unauthorized);
      expect(h.manager.state, const SessionState.unknown());
      expect(h.pushes, 0);
      expect(h.secure.values, isEmpty);
      expect(h.backend.calls('/ajax/checkUser'), isEmpty);
      expect(h.manager.isSigningIn, isFalse);
    });

    test('offline: the offline error, nothing left behind', () async {
      await h.goOffline();

      final result = await h.manager.signIn(username: 'a', password: 'b');

      expect(result.leftOrNull?.code, AppErrorCode.offline);
      expect(h.pushes, 0);
    });

    test(
      'login accepted but checkUser sees no session: unauthorized, undone',
      () async {
        h.backend.checkUserFailsWith = 401;

        final result = await h.manager.signIn(username: 'a', password: 'b');

        expect(result.leftOrNull?.code, AppErrorCode.unauthorized);
        expect(h.manager.state, const SessionState.unknown());
        expect(h.pushes, 0);
        expect(h.secure.values, isEmpty);
        expect(
          await h.hasCookie(),
          isFalse,
          reason: 'the login cookie is thrown away',
        );
        expect(
          h.backend.calls('/ajax/logout'),
          hasLength(1),
          reason: 'the server is asked to end the session it just opened',
        );
      },
    );

    test('a failed check after login is reported as is and undone', () async {
      h.backend.checkUserFailsWith = 500;

      final result = await h.manager.signIn(username: 'a', password: 'b');

      expect(result.leftOrNull?.code, AppErrorCode.server);
      expect(await h.hasCookie(), isFalse);
      expect(h.manager.state.isSignedIn, isFalse);
    });

    test('a scope that fails to start rolls everything back', () async {
      h.pushError = StateError('module failed');

      final result = await h.manager.signIn(username: 'a', password: 'b');

      expect(result.isLeft(), isTrue);
      expect(h.manager.state, const SessionState.unknown());
      expect(await h.hasCookie(), isFalse);
      expect(h.secure.values, isEmpty);
      expect(h.pops, 1);
    });

    test('is refused while signed in', () async {
      await h.manager.signIn(username: 'a', password: 'b');

      final again = await h.manager.signIn(username: 'a', password: 'b');

      expect(again.isLeft(), isTrue);
      expect(h.backend.calls('/student/login'), hasLength(1));
    });

    test('a second tap while one runs is refused', () async {
      final first = h.manager.signIn(username: 'a', password: 'b');
      final second = await h.manager.signIn(username: 'a', password: 'b');

      expect(second.isLeft(), isTrue);
      expect((await first).isRight(), isTrue);
      expect(h.backend.calls('/student/login'), hasLength(1));
    });

    test('tells listeners while it runs (busy button)', () async {
      final busy = <bool>[];
      h.manager.addListener(() => busy.add(h.manager.isSigningIn));

      await h.manager.signIn(username: 'a', password: 'b');

      expect(busy.first, isTrue);
      expect(busy.last, isFalse);
    });
  });

  group('session expiry', () {
    Future<void> signedIn() async {
      await h.manager.signIn(username: 'a', password: 'b');
      h.history.clear();
    }

    Future<void> callTheServerAfterTheCookieDied() async {
      h.backend.validCookie = null;
      await h.network.send(AuthRequests.checkUser());
    }

    test(
      'a rejected call flips to signedOut(expired) and keeps the scope',
      () async {
        await signedIn();

        await callTheServerAfterTheCookieDied();

        expect(h.manager.state, const SessionState.signedOut(expired: true));
        expect(h.manager.state.isExpired, isTrue);
        expect(h.pops, 0);
        expect(h.history, [const SessionState.signedOut(expired: true)]);
      },
    );

    test('concurrent failures flip it once', () async {
      await signedIn();
      h.backend.validCookie = null;

      await Future.wait([
        h.network.send(AuthRequests.checkUser()),
        h.network.send(AuthRequests.checkUser()),
        h.network.send(AuthRequests.checkUser()),
      ]);

      expect(h.history, hasLength(1));
    });

    test(
      'signing in again as the same user continues in the same scope',
      () async {
        await signedIn();
        await callTheServerAfterTheCookieDied();

        final result = await h.manager.signIn(username: 'a', password: 'b');

        expect(result.isRight(), isTrue);
        expect(h.manager.state.isSignedIn, isTrue);
        expect(h.pushes, 1);
        expect(h.pops, 0);
      },
    );

    test('the next expiry is reported again after signing back in', () async {
      await signedIn();
      await callTheServerAfterTheCookieDied();
      await h.manager.signIn(username: 'a', password: 'b');
      h.history.clear();

      await callTheServerAfterTheCookieDied();

      expect(h.manager.state, const SessionState.signedOut(expired: true));
    });

    test('signing in as somebody else rebuilds the scope', () async {
      await signedIn();
      await callTheServerAfterTheCookieDied();
      h.backend.user = studentJson(id: 'student-2', name: 'Mehmet');

      await h.manager.signIn(username: 'm', password: 'b');

      expect(h.manager.user?.id, 'student-2');
      expect(h.pops, 1);
      expect(h.pushes, 2);
    });

    test('is ignored while nobody is signed in', () async {
      await h.manager.restore();
      h.history.clear();

      await h.network.send(AuthRequests.checkUser());

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.history, isEmpty);
    });

    test('is not caused by the failed check of a sign-in', () async {
      h.backend.checkUserFailsWith = 401;

      await h.manager.signIn(username: 'a', password: 'b');

      expect(h.history.where((s) => s.isExpired), isEmpty);
    });

    test('is ignored after dispose', () async {
      await signedIn();
      h.manager.dispose();

      await callTheServerAfterTheCookieDied();

      expect(h.manager.state.isSignedIn, isTrue);
      h.manager = h.build();
    });
  });

  group('signOut', () {
    Future<void> signedIn() async {
      SharedPreferences.setMockInitialValues({
        'user_data': '{"role":"student"}',
        'bagItemsStr': '[]',
        'onboarding_completed': true,
      });
      await h.manager.signIn(username: 'a', password: 'b');
      h.history.clear();
    }

    test('ends the session and clears every trace', () async {
      await signedIn();

      await h.manager.signOut();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.manager.user, isNull);
      expect(h.backend.calls('/ajax/logout'), hasLength(1));
      expect(h.backend.validCookie, isNull);
      expect(await h.hasCookie(), isFalse);
      expect(h.secure.values, isEmpty);
      expect(h.pops, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys(), {'onboarding_completed'});
    });

    test('the screens leave before the server is told', () async {
      await signedIn();
      h.backend.logoutGate = Completer<void>();

      final done = h.manager.signOut();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.pops, 0, reason: 'the scope outlives the screens');
      h.backend.logoutGate!.complete();
      await done;
      expect(h.pops, 1);
    });

    test('a server that fails to log out does not stop the cleanup', () async {
      await signedIn();
      h.backend.logoutFailsWith = 500;

      await h.manager.signOut();

      expect(await h.hasCookie(), isFalse);
      expect(h.secure.values, isEmpty);
      expect(h.pops, 1);
    });

    test('a server that never answers does not hold the user', () async {
      await signedIn();
      h.backend.logoutGate = Completer<void>();

      await h.manager.signOut();

      expect(await h.hasCookie(), isFalse);
      expect(h.pops, 1);
    });

    test('offline: no call, same cleanup', () async {
      await signedIn();
      await h.goOffline();

      await h.manager.signOut();

      expect(h.backend.calls('/ajax/logout'), isEmpty);
      expect(await h.hasCookie(), isFalse);
      expect(h.secure.values, isEmpty);
      expect(h.pops, 1);
    });

    test('twice at once logs out once', () async {
      await signedIn();

      await Future.wait([h.manager.signOut(), h.manager.signOut()]);

      expect(h.backend.calls('/ajax/logout'), hasLength(1));
      expect(h.pops, 1);
    });

    test('works from an expired session', () async {
      await signedIn();
      h.backend.validCookie = null;
      await h.network.send(AuthRequests.checkUser());

      await h.manager.signOut();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.pops, 1);
      expect(h.secure.values, isEmpty);
    });

    test('with no session it only cleans up', () async {
      await h.manager.restore();

      await h.manager.signOut();

      expect(h.backend.requests, isEmpty);
      expect(h.pops, 0);
    });

    test('a sign-in right after waits for the sign-out', () async {
      await signedIn();
      h.backend.logoutGate = Completer<void>();

      final out = h.manager.signOut();
      final next = h.manager.signIn(username: 'a', password: 'b');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(h.backend.calls('/student/login'), hasLength(1));
      h.backend.logoutGate!.complete();
      await out;
      final result = await next;

      expect(result.isRight(), isTrue);
      expect(h.manager.state.isSignedIn, isTrue);
      expect(h.pushes, 2);
    });

    test('the next user starts with nothing of the last one', () async {
      await signedIn();
      await h.manager.signOut();
      h.backend.user = studentJson(id: 'student-2', name: 'Mehmet');

      await h.manager.signIn(username: 'm', password: 'b');

      expect(h.manager.user?.id, 'student-2');
      expect((await h.store.read())?.id, 'student-2');
      expect(h.pushes, 2);
      expect(h.pops, 1);
    });
  });

  group('completeAccountDeletion', () {
    test('clears like a sign-out without calling logout', () async {
      await h.manager.signIn(username: 'a', password: 'b');

      await h.manager.completeAccountDeletion();

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.backend.calls('/ajax/logout'), isEmpty);
      expect(await h.hasCookie(), isFalse);
      expect(h.secure.values, isEmpty);
      expect(h.pops, 1);
    });
  });

  group('user updates', () {
    test('updateUser replaces the user and the cache', () async {
      await h.manager.signIn(username: 'a', password: 'b');
      h.history.clear();
      const edited = UserDto(id: 'student-1', name: 'Yeni Ad', role: 'student');

      await h.manager.updateUser(edited);

      expect(h.manager.user, edited);
      expect((h.manager.state as SessionSignedIn).verified, isTrue);
      expect((await h.store.read())?.name, 'Yeni Ad');
      expect(h.history, hasLength(1));
    });

    test('updateUser is ignored when signed out', () async {
      await h.manager.restore();

      await h.manager.updateUser(const UserDto(id: 'x'));

      expect(h.manager.state, const SessionState.signedOut());
      expect(h.secure.values, isEmpty);
    });

    test('refreshUser reloads from the server', () async {
      await h.manager.signIn(username: 'a', password: 'b');
      h.backend.user = studentJson(name: 'Sunucudaki Ad');

      final result = await h.manager.refreshUser();

      expect(result.rightOrNull?.name, 'Sunucudaki Ad');
      expect(h.manager.user?.name, 'Sunucudaki Ad');
      expect((await h.store.read())?.name, 'Sunucudaki Ad');
    });

    test('refreshUser without a session fails as expired', () async {
      final result = await h.manager.refreshUser();

      expect(result.leftOrNull?.code, AppErrorCode.sessionExpired);
      expect(h.backend.requests, isEmpty);
    });
  });
}
