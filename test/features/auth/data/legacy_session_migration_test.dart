import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/legacy_session_migration.dart';
import 'package:smap/features/auth/data/session/session_store.dart';

import 'auth_fixtures.dart';

void main() {
  late FakeSecureStore secure;

  SessionStore buildStore({bool mirror = false}) => SessionStore(
    storage: secure,
    legacyMirror: mirror,
    retryDelay: Duration.zero,
  );

  LegacySessionMigration buildMigration(SessionStore store) =>
      LegacySessionMigration(store: store);

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  setUp(() => secure = FakeSecureStore());

  test('nothing on the device: nothing to do', () async {
    SharedPreferences.setMockInitialValues({'onboarding_completed': true});

    final result = await buildMigration(buildStore()).run();

    expect(result, LegacyMigrationResult.nothingToMigrate);
    expect(secure.values, isEmpty);
    expect((await prefs()).getBool('onboarding_completed'), isTrue);
  });

  test(
    'moves user_data into secure storage and deletes the plain copy',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode(studentJson()),
        'isLoggedIn': true,
        'onboarding_completed': true,
      });
      final store = buildStore();

      final result = await buildMigration(store).run();

      expect(result, LegacyMigrationResult.migrated);
      final moved = await store.read();
      expect(moved?.id, 'student-1');
      expect(moved?.userRole.name, 'student');
      final p = await prefs();
      expect(p.getString('user_data'), isNull);
      expect(p.getBool('isLoggedIn'), isNull);
      expect(
        p.getBool('onboarding_completed'),
        isTrue,
        reason: 'only session keys are touched',
      );
      expect(
        secure.values.values.single.contains('abcdefghij'),
        isFalse,
        reason: 'the password hash does not come along',
      );
    },
  );

  test('is idempotent', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode(studentJson()),
    });
    final store = buildStore();
    final migration = buildMigration(store);

    expect(await migration.run(), LegacyMigrationResult.migrated);
    expect(await migration.run(), LegacyMigrationResult.nothingToMigrate);
    expect(await migration.run(), LegacyMigrationResult.nothingToMigrate);

    expect((await store.read())?.id, 'student-1');
  });

  test('a newer secure copy wins over the legacy one', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode(studentJson(name: 'Eski Ad')),
    });
    final store = buildStore();
    await store.write(UserDto.fromJson(studentJson(name: 'Yeni Ad')));

    final result = await buildMigration(store).run();

    expect(result, LegacyMigrationResult.secureStoreWins);
    expect((await store.read())?.name, 'Yeni Ad');
    expect((await prefs()).getString('user_data'), isNull);
  });

  test('a coach is migrated like a student', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode({'_id': 'c1', 'role': 'coach', 'refCode': 'X1'}),
    });
    final store = buildStore();

    await buildMigration(store).run();

    expect((await store.read())?.refCode, 'X1');
    expect((await store.read())?.userRole.isCoach, isTrue);
  });

  test('a broken user_data is dropped and nothing is stored', () async {
    for (final broken in ['{oops', '[]', '"x"', '{}', '{"foo":1}', '  ']) {
      SharedPreferences.setMockInitialValues({'user_data': broken});
      secure.values.clear();

      final result = await buildMigration(buildStore()).run();

      expect(
        result,
        broken.trim().isEmpty
            ? LegacyMigrationResult.nothingToMigrate
            : LegacyMigrationResult.corrupt,
        reason: broken,
      );
      expect(secure.values, isEmpty, reason: broken);
      if (broken.trim().isNotEmpty) {
        expect((await prefs()).getString('user_data'), isNull, reason: broken);
      }
    }
  });

  test(
    'a refused secure write keeps the plain copy for the next launch',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode(studentJson()),
      });
      secure.failWrites = true;
      final store = buildStore();
      final migration = buildMigration(store);

      expect(await migration.run(), LegacyMigrationResult.writeFailed);
      expect((await prefs()).getString('user_data'), isNotNull);

      secure.failWrites = false;
      expect(await migration.run(), LegacyMigrationResult.migrated);
      expect((await prefs()).getString('user_data'), isNull);
    },
  );

  test(
    'with the mirror on, the plain copy stays for the legacy screens',
    () async {
      SharedPreferences.setMockInitialValues({
        'user_data': jsonEncode(studentJson()),
        'connect_sid': 's:abc',
      });
      final store = buildStore(mirror: true);

      final result = await buildMigration(store).run();

      expect(result, LegacyMigrationResult.migrated);
      final p = await prefs();
      expect(p.getString('user_data'), isNotNull);
      expect(p.getString('connect_sid'), isNull);
      expect((await store.read())?.id, 'student-1');
    },
  );

  test('never throws, even when secure storage is unreadable', () async {
    SharedPreferences.setMockInitialValues({
      'user_data': jsonEncode(studentJson()),
    });
    secure.failReads = 100;

    final result = await buildMigration(buildStore()).run();

    expect(result, isNot(LegacyMigrationResult.migrated));
    expect((await prefs()).getString('user_data'), isNotNull);
  });
}
