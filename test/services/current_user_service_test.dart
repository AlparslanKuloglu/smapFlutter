import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/extensions/either_extensions.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/services/current_user_service.dart';

import '../features/auth/data/auth_fixtures.dart';
import 'session_harness.dart';

/// Reactive values reach listeners through a stream, one event later.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late SessionHarness h;
  late CurrentUserService service;
  late int notifications;

  setUp(() {
    h = SessionHarness();
  });

  tearDown(() => h.dispose());

  Future<void> signIn({Map<String, Object?>? user}) async {
    if (user != null) h.backend.user = user;
    await h.manager.signIn(username: 'a', password: 'b');
    service = CurrentUserService(session: h.manager);
    notifications = 0;
    service.addListener(() => notifications++);
    await _settle();
    notifications = 0;
  }

  test('starts with the signed-in user and its role', () async {
    await signIn();

    expect(service.user?.id, 'student-1');
    expect(service.role, UserRole.student);
    expect(service.isStudent, isTrue);
    expect(service.isCoach, isFalse);
  });

  test('a coach reads as a coach', () async {
    await signIn(
      user: studentJson(id: 'coach-1', role: 'coach'),
    );

    expect(service.role, UserRole.coach);
    expect(service.isCoach, isTrue);
  });

  test('a role the app does not know is unknown', () async {
    await signIn(user: studentJson(role: 'admin'));

    expect(service.role, UserRole.unknown);
    expect(service.isStudent, isFalse);
    expect(service.isCoach, isFalse);
  });

  test('without a session there is no user and no role', () {
    service = CurrentUserService(session: h.manager);

    expect(service.user, isNull);
    expect(service.role, UserRole.unknown);
  });

  test('update changes the value, the cache and tells listeners', () async {
    await signIn();
    const edited = UserDto(id: 'student-1', name: 'Yeni Ad', role: 'student');

    await service.update(edited);
    await _settle();

    expect(service.user, edited);
    expect((await h.store.read())?.name, 'Yeni Ad');
    expect(notifications, greaterThan(0));
  });

  test('refresh pulls the server\'s version', () async {
    await signIn();
    h.backend.user = studentJson(name: 'Sunucudaki Ad');

    final result = await service.refresh();
    await _settle();

    expect(result.rightOrNull?.name, 'Sunucudaki Ad');
    expect(service.user?.name, 'Sunucudaki Ad');
  });

  test('refresh without a session fails as expired', () async {
    service = CurrentUserService(session: h.manager);

    expect(
      (await service.refresh()).leftOrNull?.code,
      AppErrorCode.sessionExpired,
    );
  });

  test('an equal user does not wake listeners', () async {
    await signIn();

    await service.update(service.user!);
    await _settle();

    expect(notifications, 0);
  });

  test('keeps the last user while the session is expired', () async {
    await signIn();
    h.backend.validCookie = null;

    await h.manager.refreshUser();
    await _settle();

    expect(h.manager.state.isExpired, isTrue);
    expect(service.user?.id, 'student-1');
  });

  test('follows a refresh the session manager did by itself', () async {
    await signIn();
    h.backend.user = studentJson(name: 'Arka Plan Adı');

    await h.manager.revalidate();
    await h.manager.refreshUser();
    await _settle();

    expect(service.user?.name, 'Arka Plan Adı');
  });

  test('stops following after dispose', () async {
    await signIn();
    service.dispose();

    await h.manager.updateUser(
      const UserDto(id: 'student-1', name: 'Başka', role: 'student'),
    );
    await _settle();

    expect(service.user?.name, 'Ayşe Yılmaz');
  });
}
