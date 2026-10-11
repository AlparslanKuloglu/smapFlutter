import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/domain/legacy_envelope.dart';
import 'package:smap/core/errors/app_error_code.dart';

void main() {
  group('read', () {
    test('anything that is not an object is an empty envelope', () {
      for (final body in [
        null,
        '',
        'html',
        5,
        true,
        <Object?>[],
        [1],
      ]) {
        final envelope = LegacyEnvelope.read(body);
        expect(envelope.hasBody, isFalse, reason: '$body');
        expect(envelope.success, isNull);
        expect(envelope.isSuccess, isFalse);
        expect(envelope.isRejected, isFalse);
        expect(envelope.message, isNull);
      }
    });

    test('reads the success flag leniently', () {
      expect(LegacyEnvelope.read({'success': true}).isSuccess, isTrue);
      expect(LegacyEnvelope.read({'success': 'true'}).isSuccess, isTrue);
      expect(LegacyEnvelope.read({'success': 1}).isSuccess, isTrue);
      expect(LegacyEnvelope.read({'success': false}).isRejected, isTrue);
      expect(LegacyEnvelope.read({'success': ' FALSE '}).isRejected, isTrue);
      expect(LegacyEnvelope.read({'success': 0}).isRejected, isTrue);
      expect(LegacyEnvelope.read({'success': 'maybe'}).success, isNull);
      expect(LegacyEnvelope.read({'success': 2}).success, isNull);
      expect(LegacyEnvelope.read({'ok': true}).success, isNull);
    });

    test('message falls back to msg and ignores blank or long text', () {
      expect(LegacyEnvelope.read({'message': ' Merhaba '}).message, 'Merhaba');
      expect(
        LegacyEnvelope.read({'msg': 'Hesap silinemedi.'}).message,
        'Hesap silinemedi.',
      );
      expect(LegacyEnvelope.read({'message': '  ', 'msg': 'b'}).message, 'b');
      expect(LegacyEnvelope.read({'message': 'a', 'msg': 'b'}).message, 'a');
      expect(LegacyEnvelope.read({'message': 'x' * 301}).message, isNull);
      expect(LegacyEnvelope.read({'message': 5}).message, isNull);
    });
  });

  group('lists and objects', () {
    final envelope = LegacyEnvelope.read({
      'rows': [
        {'n': 1},
        'junk',
        {'n': 2},
        null,
      ],
      'one': {'a': 1},
      'text': 'x',
    });

    test('objects keeps only the objects', () {
      expect(envelope.objects('rows'), [
        {'n': 1},
        {'n': 2},
      ]);
      expect(envelope.objects('one'), isNull);
      expect(envelope.objects('missing'), isNull);
    });

    test('object reads a map or nothing', () {
      expect(envelope.object('one'), {'a': 1});
      expect(envelope.object('rows'), isNull);
      expect(envelope.object('text'), isNull);
    });

    test('readList skips entries that fail to decode', () {
      final numbers = envelope.readList<int>('rows', (json) {
        final n = json['n']! as int;
        if (n == 1) throw const FormatException('bad row');
        return n;
      });

      expect(numbers, [2]);
      expect(envelope.readList<int>('one', (_) => 0), isNull);
    });

    test('operator [] reads the raw value', () {
      expect(envelope['text'], 'x');
      expect(envelope['missing'], isNull);
    });
  });

  group('failures', () {
    test('rejection is a validation failure with the server text', () {
      final error = LegacyEnvelope.read({
        'success': false,
        'message': 'Kod bulunamadı',
      }).rejection('/student/addCoach');

      expect(error.code, AppErrorCode.validation);
      expect(error.serverMessage, 'Kod bulunamadı');
      expect(error.path, '/student/addCoach');
    });

    test('unusable is a server failure', () {
      final error = LegacyEnvelope.read(null).unusable('/x', 'no list');

      expect(error.code, AppErrorCode.server);
      expect(error.message, contains('no list'));
      expect(error.serverMessage, isNull);
      expect(LegacyEnvelope.read(null).unusable('/x').message, isNotEmpty);
    });
  });
}
