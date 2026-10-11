import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/session_store.dart';

import 'auth_fixtures.dart';

void main() {
  late FakeSecureStore secure;

  SessionStore build({bool mirror = false}) => SessionStore(
    storage: secure,
    legacyMirror: mirror,
    retryDelay: Duration.zero,
  );

  final user = UserDto.fromJson(studentJson());

  setUp(() {
    secure = FakeSecureStore();
    SharedPreferences.setMockInitialValues({});
  });

  test('reads back what it wrote', () async {
    final store = build();

    expect(await store.write(user), isTrue);

    expect(await store.read(), user);
  });

  test('nothing stored reads as null', () async {
    expect(await build().read(), isNull);
  });

  test('the stored record has no password and one key', () async {
    await build().write(UserDto.fromJson(studentJson()));

    expect(secure.values.keys, [SessionStore.userKey]);
    expect(secure.values.values.single.contains('password'), isFalse);
    expect(secure.values.values.single.contains('abcdefghij'), isFalse);
  });

  test('a corrupt record is dropped', () async {
    secure.values[SessionStore.userKey] = '{not json';

    expect(await build().read(), isNull);
    expect(secure.values, isEmpty);
  });

  test('a record of the wrong shape is dropped', () async {
    secure.values[SessionStore.userKey] = jsonEncode({'v': 1, 'user': 'x'});

    expect(await build().read(), isNull);
    expect(secure.values, isEmpty);
  });

  test('a transient read failure is retried', () async {
    final store = build();
    await store.write(user);
    secure.failReads = 2;

    expect(await store.read(), user);
    expect(secure.reads, 3);
  });

  test('a read that keeps failing answers null and deletes nothing', () async {
    final store = build();
    await store.write(user);
    secure.failReads = 3;

    expect(await store.read(), isNull);
    expect(secure.values, isNotEmpty, reason: 'the cache must survive');
  });

  test('a refused write answers false and does not throw', () async {
    secure.failWrites = true;

    expect(await build().write(user), isFalse);
  });

  test('without the mirror nothing is written to the legacy prefs', () async {
    await build().write(user);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_data'), isNull);
  });

  test('with the mirror the legacy user_data follows the cache', () async {
    final store = build(mirror: true);

    await store.write(user);

    final prefs = await SharedPreferences.getInstance();
    final mirrored =
        jsonDecode(prefs.getString('user_data')!) as Map<String, dynamic>;
    expect(mirrored['_id'], 'student-1');
    expect(mirrored['role'], 'student');
    expect(mirrored.containsKey('password'), isFalse);
  });

  test('clear removes the cache and every legacy session key', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': '{"role":"student"}',
      'isLoggedIn': true,
      'connect_sid': 's:abc',
      'bagItemsStr': '[]',
      'onboarding_completed': true,
      'skip_learned_dialog': true,
    });
    final store = build();
    await store.write(user);

    await store.clear();

    expect(secure.values, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getKeys(), {'onboarding_completed', 'skip_learned_dialog'});
  });
}
