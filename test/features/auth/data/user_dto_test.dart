import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';
import 'package:smap/features/auth/data/dtos/check_user_response.dart';
import 'package:smap/features/auth/data/dtos/login_response.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';

/// A student document as the legacy login stores it under `user_data`
/// (field set of `domain/models/student_model.dart` plus the fields the home
/// screen reads), password hash included.
const Map<String, Object?> _studentJson = {
  '_id': '66214a6982ff212039ea3294',
  'name': 'Ayşe Yılmaz',
  'userName': 'ayse',
  'password': r'$2a$10$abcdefghijklmnopqrstuv',
  'photo': 'avatars/1avatarN3.png',
  'schoolNo': 0,
  'totalMexam': 7,
  'status': 1,
  'seasonType': 12,
  'aimType': 3,
  'registerType': 1,
  'email': 'ayse@example.com',
  'degreePoint': 15,
  'date': '2025-05-10T12:30:00.000Z',
  'firstName': 'Ayşe',
  'surname': 'Yılmaz',
  '__v': 0,
  'phone': '5551112233',
  'coach': '',
  'role': 'student',
  'points': 120,
  'progress': 0.4,
};

void main() {
  group('UserDto.fromJson', () {
    test('reads a full student document', () {
      final user = UserDto.fromJson(Map<String, dynamic>.of(_studentJson));

      expect(user.id, '66214a6982ff212039ea3294');
      expect(user.name, 'Ayşe Yılmaz');
      expect(user.userName, 'ayse');
      expect(user.photo, 'avatars/1avatarN3.png');
      expect(user.email, 'ayse@example.com');
      expect(user.phone, '5551112233');
      expect(user.seasonType, 12);
      expect(user.aimType, 3);
      expect(user.totalMexam, 7);
      expect(user.degreePoint, 15);
      expect(user.points, 120);
      expect(user.progress, 0.4);
      expect(user.coach, isNull, reason: 'an empty coach is not a coach');
      expect(user.role, 'student');
      expect(user.userRole, UserRole.student);
      expect(user.date?.toUtc(), DateTime.utc(2025, 5, 10, 12, 30));
    });

    test('never carries the password', () {
      final user = UserDto.fromJson(Map<String, dynamic>.of(_studentJson));
      final encoded = jsonEncode(user.toJson());

      expect(encoded.contains('password'), isFalse);
      expect(encoded.contains('abcdefghijklmnopqrstuv'), isFalse);
      expect(user.toString().contains('abcdefghijklmnopqrstuv'), isFalse);
    });

    test('reads a coach with a share code', () {
      final user = UserDto.fromJson({
        '_id': 'c1',
        'name': 'Mehmet Hoca',
        'role': 'coach',
        'refCode': 'AB12CD',
        'country': 'Türkiye',
        'city': 'Ankara',
      });

      expect(user.userRole, UserRole.coach);
      expect(user.refCode, 'AB12CD');
      expect(user.city, 'Ankara');
      expect(user.aimType, isNull);
    });

    test('an empty object is a user with nothing set', () {
      final user = UserDto.fromJson(<String, dynamic>{});

      expect(user.id, isNull);
      expect(user.userRole, UserRole.unknown);
      expect(user.displayName, isNull);
    });

    test('unknown fields are ignored', () {
      final user = UserDto.fromJson({
        '_id': 'x',
        'role': 'student',
        'somethingNew': {'a': 1},
      });

      expect(user.id, 'x');
    });

    test('reads loosely typed values', () {
      final user = UserDto.fromJson({
        '_id': 12345,
        'phone': 5551112233,
        'seasonType': '11',
        'aimType': 3.0,
        'points': '120',
        'progress': '0,5',
        'date': 1746880200000,
        'role': ' Student ',
        'name': '  Ayşe  ',
        'email': '   ',
      });

      expect(user.id, '12345');
      expect(user.phone, '5551112233');
      expect(user.seasonType, 11);
      expect(user.aimType, 3);
      expect(user.points, 120);
      expect(user.progress, 0.5);
      expect(user.date, isNotNull);
      expect(user.userRole, UserRole.student);
      expect(user.name, 'Ayşe');
      expect(user.email, isNull);
    });

    test('a field of the wrong shape becomes null and spares the rest', () {
      final user = UserDto.fromJson({
        '_id': 'x',
        'name': {'first': 'Ayşe'},
        'seasonType': 'on ikinci',
        'aimType': [3],
        'progress': 'çok',
        'date': 'dün',
        'role': ['student'],
        'email': 'a@b.com',
      });

      expect(user.id, 'x');
      expect(user.name, isNull);
      expect(user.seasonType, isNull);
      expect(user.aimType, isNull);
      expect(user.progress, isNull);
      expect(user.date, isNull);
      expect(user.role, isNull);
      expect(user.userRole, UserRole.unknown);
      expect(user.email, 'a@b.com');
    });

    test('a populated coach object reads as the coach id', () {
      final user = UserDto.fromJson({
        'role': 'student',
        'coach': {'_id': 'coach-9', 'name': 'Mehmet Hoca'},
      });

      expect(user.coach, 'coach-9');
    });

    test('a coach id as text is kept', () {
      expect(UserDto.fromJson({'coach': 'coach-9'}).coach, 'coach-9');
    });
  });

  group('UserDto', () {
    test('survives a JSON round trip', () {
      final user = UserDto.fromJson(Map<String, dynamic>.of(_studentJson));
      final again = UserDto.fromJson(
        jsonDecode(jsonEncode(user.toJson())) as Map<String, dynamic>,
      );

      expect(again, user);
    });

    test('encodes the Mongo id under _id and leaves out missing fields', () {
      final json = const UserDto(id: 'u1', role: 'coach').toJson();

      expect(json, {'_id': 'u1', 'role': 'coach'});
    });

    test('displayName falls back from name to first name and surname to '
        'login name', () {
      expect(const UserDto(name: 'Ayşe Y.').displayName, 'Ayşe Y.');
      expect(
        const UserDto(firstName: 'Ayşe', surname: 'Yılmaz').displayName,
        'Ayşe Yılmaz',
      );
      expect(const UserDto(firstName: 'Ayşe').displayName, 'Ayşe');
      expect(const UserDto(userName: 'ayse').displayName, 'ayse');
      expect(const UserDto().displayName, isNull);
    });
  });

  group('LoginResponse.fromBody', () {
    test('a body with the user is authenticated', () {
      final response = LoginResponse.fromBody({
        'user': Map<String, Object?>.of(_studentJson),
      });

      expect(response.isAuthenticated, isTrue);
      expect(response.user?.userRole, UserRole.student);
    });

    test('success: true without a user is authenticated', () {
      expect(LoginResponse.fromBody({'success': true}).isAuthenticated, isTrue);
      expect(
        LoginResponse.fromBody({'success': 'true'}).isAuthenticated,
        isTrue,
      );
    });

    test('success: false wins over a user', () {
      final response = LoginResponse.fromBody({
        'success': false,
        'message': 'Kullanıcı adı veya şifre hatalı',
        'user': {'_id': 'x', 'role': 'student'},
      });

      expect(response.isAuthenticated, isFalse);
      expect(response.message, 'Kullanıcı adı veya şifre hatalı');
    });

    test('an empty object is not authenticated', () {
      expect(
        LoginResponse.fromBody(<String, Object?>{}).isAuthenticated,
        isFalse,
      );
    });

    test('a body that is not an object is not authenticated', () {
      expect(LoginResponse.fromBody(null).isAuthenticated, isFalse);
      expect(
        LoginResponse.fromBody('Found. Redirecting to /login').isAuthenticated,
        isFalse,
      );
      expect(LoginResponse.fromBody(<Object?>[1]).isAuthenticated, isFalse);
    });

    test('a user that is not an object is dropped', () {
      final response = LoginResponse.fromBody({'user': 'ayse'});

      expect(response.user, isNull);
      expect(response.isAuthenticated, isFalse);
    });

    test('a message of the wrong type does not break the answer', () {
      final response = LoginResponse.fromBody({
        'success': true,
        'message': {'tr': 'x'},
      });

      expect(response.isAuthenticated, isTrue);
      expect(response.message, isNull);
    });
  });

  group('CheckUserResponse.fromBody', () {
    test('success and a user is signed in', () {
      final response = CheckUserResponse.fromBody({
        'success': true,
        'user': Map<String, Object?>.of(_studentJson),
      });

      expect(response.isSignedIn, isTrue);
      expect(response.user?.id, '66214a6982ff212039ea3294');
    });

    test('success without a user is not signed in', () {
      expect(CheckUserResponse.fromBody({'success': true}).isSignedIn, isFalse);
    });

    test('a user without success is not signed in', () {
      final response = CheckUserResponse.fromBody({
        'user': {'_id': 'x'},
      });

      expect(response.isSignedIn, isFalse);
    });

    test('success: false is not signed in', () {
      expect(
        CheckUserResponse.fromBody({
          'success': false,
          'user': <String, Object?>{},
        }).isSignedIn,
        isFalse,
      );
    });

    test('a body that is not an object is not signed in', () {
      expect(CheckUserResponse.fromBody('<html>').isSignedIn, isFalse);
      expect(CheckUserResponse.fromBody(null).isSignedIn, isFalse);
    });
  });
}
