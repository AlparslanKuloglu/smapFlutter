import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/router/route_refresh.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/domain/session_state.dart';

void main() {
  late ValueNotifier<SessionState> session;
  late RouteRefresh refresh;
  late int wakeUps;

  setUp(() {
    session = ValueNotifier<SessionState>(const SessionState.unknown());
    refresh = RouteRefresh(session);
    wakeUps = 0;
    refresh.addListener(() => wakeUps++);
  });

  tearDown(() {
    refresh.dispose();
    session.dispose();
  });

  test('wakes the router when the session is decided', () {
    session.value = const SessionState.restoring();
    expect(wakeUps, 0, reason: 'still undecided');

    session.value = const SessionState.signedOut();
    expect(wakeUps, 1);
  });

  test('wakes it on sign-in, expiry and sign-out', () {
    session.value = const SessionState.signedOut();
    session.value = const SessionState.signedIn(
      UserDto(id: '1', role: 'student'),
    );
    expect(wakeUps, 2);

    session.value = const SessionState.signedOut(expired: true);
    expect(wakeUps, 3);

    session.value = const SessionState.signedOut();
    expect(wakeUps, 4);
  });

  test('stays quiet for a refreshed profile of the same account', () {
    session.value = const SessionState.signedIn(
      UserDto(id: '1', role: 'student'),
    );
    final before = wakeUps;

    session.value = const SessionState.signedIn(
      UserDto(id: '1', role: 'student', name: 'Yeni Ad'),
      verified: true,
    );

    expect(wakeUps, before);
  });

  test('wakes it when the role changes under the same session', () {
    session.value = const SessionState.signedIn(
      UserDto(id: '1', role: 'student'),
    );
    final before = wakeUps;

    session.value = const SessionState.signedIn(
      UserDto(id: '1', role: 'coach'),
    );

    expect(wakeUps, before + 1);
  });
}
