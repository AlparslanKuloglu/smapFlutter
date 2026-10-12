import 'package:flutter_test/flutter_test.dart';
import 'package:smap/features/account/application/support_mail.dart';

void main() {
  group('SupportMail.compose', () {
    test('writes a mailto link with the subject and the details', () {
      final uri = SupportMail.compose(
        address: 'destek@smaptr.com',
        subject: 'SMAP · Destek',
        details: ['Uygulama sürümü: 3.0.0 (300)', 'Sistem: iOS 18.2'],
      );

      expect(uri.scheme, 'mailto');
      expect(uri.path, 'destek@smaptr.com');
      // A mail app reads %20 for a space (a "+" would show as a plus).
      expect(uri.query, contains('subject=SMAP%20%C2%B7%20Destek'));
      expect(uri.query, isNot(contains('+')));
    });

    test('the body leaves room to write and ends with the details, CRLF', () {
      final uri = SupportMail.compose(
        address: 'destek@smaptr.com',
        subject: 'Destek',
        details: ['Uygulama sürümü: 3.0.0 (300)', 'Sistem: iOS 18.2'],
      );

      final body = Uri.splitQueryString(uri.query)['body']!;

      expect(
        body,
        '\r\n\r\n\r\nUygulama sürümü: 3.0.0 (300)\r\nSistem: iOS 18.2\r\n',
      );
    });

    test('leaves out an empty subject and empty details', () {
      final uri = SupportMail.compose(address: 'a@b.com', subject: ' ');

      expect(uri.toString(), 'mailto:a@b.com');
      expect(uri.hasQuery, isFalse);
    });

    test('trims the address', () {
      expect(
        SupportMail.compose(address: ' a@b.com ', subject: 'x').path,
        'a@b.com',
      );
    });
  });
}
