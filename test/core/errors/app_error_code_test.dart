import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/errors/app_error_code.dart';

void main() {
  test('every code has its own l10n key', () {
    final keys = AppErrorCode.values.map((c) => c.l10nKey).toList();

    expect(keys.toSet(), hasLength(AppErrorCode.values.length));
    for (final code in AppErrorCode.values) {
      expect(code.l10nKey, 'errors_${code.name}');
    }
  });

  test('every l10n key has a Turkish message in errors_tr.arb', () {
    final arb =
        jsonDecode(File('lib/l10n/arb/errors_tr.arb').readAsStringSync())
            as Map<String, dynamic>;

    for (final code in AppErrorCode.values) {
      final message = arb[code.l10nKey];
      expect(message, isA<String>(), reason: code.l10nKey);
      expect(message as String, isNotEmpty);
      // House rule: "Vazgeç", never "İptal".
      expect(message.toLowerCase(), isNot(contains('iptal')));
    }
  });

  test('errors_tr.arb has no keys without a code', () {
    final arb =
        jsonDecode(File('lib/l10n/arb/errors_tr.arb').readAsStringSync())
            as Map<String, dynamic>;
    final messageKeys = arb.keys.where((k) => !k.startsWith('@'));
    final codeKeys = AppErrorCode.values.map((c) => c.l10nKey).toSet();

    expect(messageKeys.toSet(), codeKeys);
  });

  test('only transient failures are retryable', () {
    final retryable = AppErrorCode.values.where((c) => c.isRetryable).toSet();

    expect(retryable, {
      AppErrorCode.network,
      AppErrorCode.timeout,
      AppErrorCode.offline,
      AppErrorCode.server,
      AppErrorCode.maintenance,
      AppErrorCode.unknown,
    });
  });

  test('session expiry and cancel have their own flags', () {
    expect(AppErrorCode.sessionExpired.requiresSignIn, isTrue);
    expect(AppErrorCode.unauthorized.requiresSignIn, isFalse);
    expect(AppErrorCode.cancelled.isSilent, isTrue);
    expect(AppErrorCode.offline.isSilent, isFalse);
  });
}
