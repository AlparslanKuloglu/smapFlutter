import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';
import 'package:smap/features/auth/presentation/login/login_error_text.dart';
import 'package:smap/l10n/app_localizations_tr.dart';

void main() {
  final l10n = AppLocalizationsTr();

  String text(AppErrorCode code, {bool forgot = true}) =>
      loginErrorText(l10n, code, forgotPasswordOpen: forgot);

  test('wrong credentials read as on the board and name no field', () {
    expect(
      text(AppErrorCode.unauthorized),
      'Kullanıcı adı ya da şifre hatalı. Tekrar dene ya da şifreni sıfırla.',
    );
  });

  test('without the reset link the sentence does not point at it', () {
    expect(
      text(AppErrorCode.unauthorized, forgot: false),
      'Kullanıcı adı ya da şifre hatalı. Tekrar dene.',
    );
  });

  test('a lost connection and a timeout read "Bağlanamadık"', () {
    const expected = 'Bağlanamadık. Bağlantını kontrol edip tekrar dene.';
    expect(text(AppErrorCode.network), expected);
    expect(text(AppErrorCode.timeout), expected);
  });

  test('every code has a sentence, never empty, never a raw code', () {
    for (final code in AppErrorCode.values) {
      final sentence = text(code);
      expect(sentence, isNotEmpty, reason: code.name);
      expect(sentence, isNot(contains('errors_')), reason: code.name);
      expect(sentence, isNot(contains('Exception')), reason: code.name);
    }
  });
}
