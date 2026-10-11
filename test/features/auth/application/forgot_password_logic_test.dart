import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/core/errors/app_exception.dart';
import 'package:smap/features/auth/application/forgot_password_logic.dart';
import 'package:smap/features/auth/application/forgot_password_repository.dart';

void main() {
  group('ForgotPasswordStep.previous', () {
    test('goes back one step; the first and the last have none', () {
      expect(ForgotPasswordStep.email.previous, isNull);
      expect(ForgotPasswordStep.code.previous, ForgotPasswordStep.email);
      expect(ForgotPasswordStep.newPassword.previous, ForgotPasswordStep.code);
      expect(ForgotPasswordStep.done.previous, isNull);
    });
  });

  group('ForgotPasswordRules.isEmail', () {
    test('accepts something@something.something', () {
      expect(ForgotPasswordRules.isEmail('ad@alan.com'), isTrue);
      expect(ForgotPasswordRules.isEmail(' alparslan@ornek.com '), isTrue);
      expect(ForgotPasswordRules.isEmail('a.b+c@d.e.tr'), isTrue);
    });

    test('refuses an address that is missing a part', () {
      expect(ForgotPasswordRules.isEmail(''), isFalse);
      expect(ForgotPasswordRules.isEmail('ad'), isFalse);
      expect(ForgotPasswordRules.isEmail('ad@'), isFalse);
      expect(ForgotPasswordRules.isEmail('ad@alan'), isFalse);
      expect(ForgotPasswordRules.isEmail('@alan.com'), isFalse);
      expect(ForgotPasswordRules.isEmail('ad @alan.com'), isFalse);
    });
  });

  group('ForgotPasswordRules passwords', () {
    test('eight characters are enough, seven are not', () {
      expect(ForgotPasswordRules.isLongEnough('1234567'), isFalse);
      expect(ForgotPasswordRules.isLongEnough('12345678'), isTrue);
    });

    test('the two fields must match exactly', () {
      expect(ForgotPasswordRules.matches('Sifre123', 'Sifre123'), isTrue);
      expect(ForgotPasswordRules.matches('Sifre123', 'sifre123'), isFalse);
      expect(ForgotPasswordRules.matches('Sifre123', ''), isFalse);
    });
  });

  group('ForgotPasswordRules.formatCountdown', () {
    test('reads minutes:seconds as the button shows it', () {
      expect(ForgotPasswordRules.formatCountdown(24), '0:24');
      expect(ForgotPasswordRules.formatCountdown(30), '0:30');
      expect(ForgotPasswordRules.formatCountdown(5), '0:05');
      expect(ForgotPasswordRules.formatCountdown(0), '0:00');
      expect(ForgotPasswordRules.formatCountdown(60), '1:00');
      expect(ForgotPasswordRules.formatCountdown(-3), '0:00');
    });

    test('the wait is 30 seconds, ticking once a second (T7.8)', () {
      expect(ForgotPasswordRules.resendDelay, const Duration(seconds: 30));
      expect(ForgotPasswordRules.tick, const Duration(seconds: 1));
    });
  });

  group('ForgotPasswordFailures', () {
    test('status 429 means too many attempts', () {
      const tooMany = AppException(
        code: AppErrorCode.validation,
        statusCode: 429,
      );
      const wrong = AppException(
        code: AppErrorCode.validation,
        statusCode: 400,
      );
      expect(ForgotPasswordFailures.isTooManyAttempts(tooMany), isTrue);
      expect(ForgotPasswordFailures.isTooManyAttempts(wrong), isFalse);
    });
  });
}
