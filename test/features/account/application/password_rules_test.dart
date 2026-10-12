import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/password_rules.dart';

void main() {
  group('canSubmit', () {
    test('is open only while the three fields hold something', () {
      expect(
        PasswordRules.canSubmit('eski-sifre', 'yeni-sifre1', 'yeni-sifre1'),
        isTrue,
      );
      expect(
        PasswordRules.canSubmit('', 'yeni-sifre1', 'yeni-sifre1'),
        isFalse,
      );
      expect(PasswordRules.canSubmit('eski-sifre', '', 'yeni-sifre1'), isFalse);
      expect(PasswordRules.canSubmit('eski-sifre', 'yeni-sifre1', ''), isFalse);
    });
  });

  group('check', () {
    test('accepts eight characters, different from the old one, repeated', () {
      expect(PasswordRules.check('eski-sifre', '12345678', '12345678'), isNull);
    });

    test('a new password under eight characters is too short', () {
      expect(
        PasswordRules.check('eski-sifre', '1234567', '1234567'),
        PasswordIssue.tooShort,
      );
    });

    test('eight characters is long enough; counts characters, not bytes', () {
      expect(PasswordRules.check('a', 'şifreçğü', 'şifreçğü'), isNull);
      expect(
        PasswordRules.check('a', 'şifreçğ', 'şifreçğ'),
        PasswordIssue.tooShort,
      );
    });

    test('the new password cannot be the current one', () {
      expect(
        PasswordRules.check('ayni-sifre-1', 'ayni-sifre-1', 'ayni-sifre-1'),
        PasswordIssue.sameAsCurrent,
      );
    });

    test('the two new passwords must match', () {
      expect(
        PasswordRules.check('eski-sifre', 'yeni-sifre1', 'yeni-sifre2'),
        PasswordIssue.mismatch,
      );
    });

    test('a short password is reported before a mismatch', () {
      expect(
        PasswordRules.check('eski-sifre', 'kisa', 'baska'),
        PasswordIssue.tooShort,
      );
    });

    test('case matters', () {
      expect(
        PasswordRules.check('eski-sifre', 'Yeni-Sifre1', 'yeni-sifre1'),
        PasswordIssue.mismatch,
      );
    });
  });

  group('field of an issue', () {
    test('each issue is drawn under its own field', () {
      expect(PasswordIssue.wrongCurrent.field, PasswordField.current);
      expect(PasswordIssue.tooShort.field, PasswordField.next);
      expect(PasswordIssue.sameAsCurrent.field, PasswordField.next);
      expect(PasswordIssue.mismatch.field, PasswordField.repeat);
    });
  });
}
