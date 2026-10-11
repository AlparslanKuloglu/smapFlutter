import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';
import 'package:smap/features/startup/application/session_expired_coordinator.dart';

const _user = UserDto(id: '1', role: 'student');

/// Lets the zero-delay futures of the flow run.
Future<void> _settle() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late ValueNotifier<SessionState> session;
  late int sheets;
  late int signIns;
  late List<bool> sheetAnswers;
  late Completer<void>? signInRoute;
  late SessionExpiredCoordinator coordinator;

  setUp(() {
    session = ValueNotifier<SessionState>(const SessionState.signedIn(_user));
    sheets = 0;
    signIns = 0;
    sheetAnswers = [];
    signInRoute = null;
    coordinator = SessionExpiredCoordinator(
      session: session,
      showSheet: () async {
        sheets++;
        return sheetAnswers.isEmpty ? true : sheetAnswers.removeAt(0);
      },
      openSignIn: () {
        signIns++;
        signInRoute = Completer<void>();
        return signInRoute!.future;
      },
    )..start();
  });

  tearDown(() {
    coordinator.dispose();
    session.dispose();
  });

  test('stays quiet while the session is fine', () async {
    session.value = const SessionState.signedOut();
    await _settle();

    expect(sheets, 0, reason: 'a plain sign-out is not an expiry');
  });

  test('opens the sheet when the session expires', () async {
    session.value = const SessionState.signedOut(expired: true);
    await _settle();

    expect(sheets, 1);
    expect(signIns, 1, reason: '"Giriş Yap" opens the sign-in');
    expect(coordinator.isRunning, isTrue);
  });

  test('a sign-in that succeeds ends the flow', () async {
    session.value = const SessionState.signedOut(expired: true);
    await _settle();

    session.value = const SessionState.signedIn(_user, verified: true);
    signInRoute!.complete();
    await _settle();

    expect(coordinator.isRunning, isFalse);
    expect(sheets, 1, reason: 'no second sheet');
  });

  test('leaving the sign-in without signing in asks again', () async {
    session.value = const SessionState.signedOut(expired: true);
    await _settle();

    signInRoute!.complete(); // closed by Back, session still expired
    await _settle();

    expect(sheets, 2);
    expect(signIns, 2);
  });

  test('never stacks a second flow on a repeated notification', () async {
    session.value = const SessionState.signedOut(expired: true);
    await _settle();
    session.value = const SessionState.signedOut(expired: true);
    session.notifyListeners();
    await _settle();

    expect(sheets, 1);
  });

  test('a sheet that could not open ends the flow without looping', () async {
    sheetAnswers = [false];

    session.value = const SessionState.signedOut(expired: true);
    await _settle();

    expect(sheets, 1);
    expect(signIns, 0);
    expect(coordinator.isRunning, isFalse);
  });

  test('a second expiry later opens the sheet again', () async {
    session.value = const SessionState.signedOut(expired: true);
    await _settle();
    session.value = const SessionState.signedIn(_user, verified: true);
    signInRoute!.complete();
    await _settle();

    session.value = const SessionState.signedOut(expired: true);
    await _settle();

    expect(sheets, 2);
  });

  test('an already expired session is handled when it starts', () async {
    final expired = ValueNotifier<SessionState>(
      const SessionState.signedOut(expired: true),
    );
    var shown = 0;
    final late = SessionExpiredCoordinator(
      session: expired,
      showSheet: () async {
        shown++;
        return false;
      },
      openSignIn: () async {},
    )..start();
    await _settle();

    expect(shown, 1);
    late.dispose();
    expired.dispose();
  });
}
