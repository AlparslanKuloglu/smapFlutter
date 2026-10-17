import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smap/core/config/app_config.dart';

void main() {
  group('AppConfig.resolve defaults', () {
    test('nothing configured falls back to the hosts the app uses today', () {
      final config = AppConfig.resolve();

      expect(config.apiBaseUrl, 'https://www.smaptr.com');
      expect(config.omrBaseUrl, config.apiBaseUrl);
      expect(config.cdnBaseUrl, 'https://smaptr.com.tr');
      expect(config.supportEmail, isNull);
      expect(config.yksDate, DateTime(2027, 6, 19));
      expect(config.appStoreId, isNull);
      expect(config.playPackage, 'com.studentmap.smap');
    });

    test('blank and whitespace values count as missing', () {
      final config = AppConfig.resolve(
        apiBaseUrl: '',
        omrBaseUrl: '   ',
        cdnBaseUrl: '',
        supportEmail: ' ',
        yksDate: '',
        appStoreId: '  ',
        playPackage: '',
      );

      expect(config.apiBaseUrl, AppConfig.defaultApiBaseUrl);
      expect(config.omrBaseUrl, AppConfig.defaultApiBaseUrl);
      expect(config.cdnBaseUrl, AppConfig.defaultCdnBaseUrl);
      expect(config.supportEmail, isNull);
      expect(config.yksDate, AppConfig.defaultYksDate);
      expect(config.appStoreId, isNull);
      expect(config.playPackage, AppConfig.defaultPlayPackage);
    });

    test('omrBaseUrl follows a configured apiBaseUrl', () {
      final config = AppConfig.resolve(apiBaseUrl: 'https://api.example.com');

      expect(config.omrBaseUrl, 'https://api.example.com');
    });

    test('a build without dart-defines equals the defaults', () {
      final fromEnvironment = AppConfig.fromEnvironment();
      final defaults = AppConfig.resolve();

      expect(fromEnvironment.apiBaseUrl, defaults.apiBaseUrl);
      expect(fromEnvironment.yksDate, defaults.yksDate);
      expect(fromEnvironment.playPackage, defaults.playPackage);
    });
  });

  group('AppConfig.resolve values', () {
    test('uses every configured value', () {
      final config = AppConfig.resolve(
        apiBaseUrl: 'https://api.example.com',
        omrBaseUrl: 'https://omr.example.com',
        cdnBaseUrl: 'https://cdn.example.com',
        supportEmail: 'destek@example.com',
        yksDate: '2027-06-20',
        appStoreId: '123456789',
        playPackage: 'com.example.smap',
      );

      expect(config.apiBaseUrl, 'https://api.example.com');
      expect(config.omrBaseUrl, 'https://omr.example.com');
      expect(config.cdnBaseUrl, 'https://cdn.example.com');
      expect(config.supportEmail, 'destek@example.com');
      expect(config.yksDate, DateTime(2027, 6, 20));
      expect(config.appStoreId, '123456789');
      expect(config.playPackage, 'com.example.smap');
    });

    test('trailing slashes are removed from base URLs', () {
      final config = AppConfig.resolve(
        apiBaseUrl: 'https://api.example.com/',
        omrBaseUrl: 'https://omr.example.com//',
        cdnBaseUrl: ' https://cdn.example.com/ ',
      );

      expect(config.apiBaseUrl, 'https://api.example.com');
      expect(config.omrBaseUrl, 'https://omr.example.com');
      expect(config.cdnBaseUrl, 'https://cdn.example.com');
    });

    test('a timestamped YKS date is cut to the day', () {
      final config = AppConfig.resolve(yksDate: '2027-06-19T10:30:00');

      expect(config.yksDate, DateTime(2027, 6, 19));
    });

    test('store and mail links are built from the values', () {
      final config = AppConfig.resolve(
        supportEmail: 'destek@example.com',
        appStoreId: '123456789',
        playPackage: 'com.example.smap',
      );

      expect(
        config.appStoreUri,
        Uri.parse('https://apps.apple.com/app/id123456789'),
      );
      expect(
        config.playStoreUri,
        Uri.parse(
          'https://play.google.com/store/apps/details?id=com.example.smap',
        ),
      );
      expect(config.supportMailUri, Uri.parse('mailto:destek@example.com'));
    });

    test('links are null without their value', () {
      final config = AppConfig.resolve();

      expect(config.appStoreUri, isNull);
      expect(config.supportMailUri, isNull);
    });
  });

  group('AppConfig.resolve malformed values (debug asserts)', () {
    test('a URL without scheme or host', () {
      expect(
        () => AppConfig.resolve(apiBaseUrl: 'www.smaptr.com'),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => AppConfig.resolve(cdnBaseUrl: 'ftp://cdn.example.com'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('an e-mail without domain', () {
      expect(
        () => AppConfig.resolve(supportEmail: 'destek'),
        throwsA(isA<AssertionError>()),
      );
    });

    test('a date that is not ISO-8601', () {
      expect(
        () => AppConfig.resolve(yksDate: '19.06.2027'),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  test('config/dev.json.example is a valid config file', () {
    final json =
        jsonDecode(File('config/dev.json.example').readAsStringSync())
            as Map<String, dynamic>;

    expect(
      json.keys,
      unorderedEquals(<String>[
        'API_BASE_URL',
        'OMR_BASE_URL',
        'CDN_BASE_URL',
        'SUPPORT_EMAIL',
        'YKS_DATE',
        'APP_STORE_ID',
        'PLAY_PACKAGE',
      ]),
    );
    expect(
      () => AppConfig.resolve(
        apiBaseUrl: json['API_BASE_URL'] as String,
        omrBaseUrl: json['OMR_BASE_URL'] as String,
        cdnBaseUrl: json['CDN_BASE_URL'] as String,
        supportEmail: json['SUPPORT_EMAIL'] as String,
        yksDate: json['YKS_DATE'] as String,
        appStoreId: json['APP_STORE_ID'] as String,
        playPackage: json['PLAY_PACKAGE'] as String,
      ),
      returnsNormally,
    );
  });
}
