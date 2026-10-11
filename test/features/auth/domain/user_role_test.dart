import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/user_role.dart';

void main() {
  group('UserRole.fromLegacy', () {
    test('reads the documented values', () {
      expect(UserRole.fromLegacy('student'), UserRole.student);
      expect(UserRole.fromLegacy('coach'), UserRole.coach);
    });

    test('the legacy shell\'s "teacher" is a coach', () {
      expect(UserRole.fromLegacy('teacher'), UserRole.coach);
    });

    test('ignores case and surrounding spaces', () {
      expect(UserRole.fromLegacy(' Student '), UserRole.student);
      expect(UserRole.fromLegacy('COACH'), UserRole.coach);
    });

    test('anything else is unknown', () {
      expect(UserRole.fromLegacy('admin'), UserRole.unknown);
      expect(UserRole.fromLegacy(''), UserRole.unknown);
      expect(UserRole.fromLegacy(null), UserRole.unknown);
      expect(UserRole.fromLegacy(2), UserRole.unknown);
      expect(UserRole.fromLegacy(<String>['student']), UserRole.unknown);
    });
  });

  test('flags and wire names', () {
    expect(UserRole.student.isStudent, isTrue);
    expect(UserRole.student.isCoach, isFalse);
    expect(UserRole.coach.isCoach, isTrue);
    expect(UserRole.unknown.isKnown, isFalse);
    expect(UserRole.student.isKnown, isTrue);
    expect(UserRole.student.wireName, 'student');
    expect(UserRole.coach.wireName, 'coach');
    expect(UserRole.unknown.wireName, isNull);
  });
}
