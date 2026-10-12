import 'package:flutter/foundation.dart';

/// Build-time configuration, read from `--dart-define-from-file`.
///
/// Run with `flutter run --dart-define-from-file=config/dev.json` (copy
/// `config/dev.json.example` to `config/dev.json`). Every key is optional: a
/// missing or blank value falls back to the production value the app already
/// talks to, so a plain `flutter run` keeps working.
///
/// A value that is present but malformed (a URL without a scheme, a date that
/// is not ISO-8601) trips an `assert` in debug builds, so a typo in the config
/// file is caught on the first launch; release builds use the default instead
/// of crashing.
///
/// Nothing secret belongs here: dart-define values are readable from the
/// shipped binary.
@immutable
final class AppConfig {
  const AppConfig._({
    required this.apiBaseUrl,
    required this.omrBaseUrl,
    required this.cdnBaseUrl,
    required this.supportEmail,
    required this.yksDate,
    required this.appStoreId,
    required this.playPackage,
  });

  /// Reads the `--dart-define` values of this build.
  factory AppConfig.fromEnvironment() => AppConfig.resolve(
    apiBaseUrl: _apiBaseUrlDefine,
    omrBaseUrl: _omrBaseUrlDefine,
    cdnBaseUrl: _cdnBaseUrlDefine,
    supportEmail: _supportEmailDefine,
    yksDate: _yksDateDefine,
    appStoreId: _appStoreIdDefine,
    playPackage: _playPackageDefine,
  );

  /// Pure resolver behind [AppConfig.fromEnvironment]; exposed for tests.
  factory AppConfig.resolve({
    String? apiBaseUrl,
    String? omrBaseUrl,
    String? cdnBaseUrl,
    String? supportEmail,
    String? yksDate,
    String? appStoreId,
    String? playPackage,
  }) {
    final api = _url(apiBaseUrl, 'API_BASE_URL') ?? defaultApiBaseUrl;
    return AppConfig._(
      apiBaseUrl: api,
      // The real OMR host is still an open backend question (spec §6.3 #1);
      // until it is configured the OMR endpoints share the API host, which is
      // better than the placeholder host the legacy code points at.
      omrBaseUrl: _url(omrBaseUrl, 'OMR_BASE_URL') ?? api,
      cdnBaseUrl: _url(cdnBaseUrl, 'CDN_BASE_URL') ?? defaultCdnBaseUrl,
      supportEmail: _email(supportEmail),
      yksDate: _date(yksDate) ?? defaultYksDate,
      appStoreId: _trimmedOrNull(appStoreId),
      playPackage: _trimmedOrNull(playPackage) ?? defaultPlayPackage,
    );
  }

  /// The API host, session cookie included.
  static const String defaultApiBaseUrl = 'https://www.smaptr.com';

  /// Host of `/uploads/<file>` exam images in the legacy screens. The subject
  /// icons still live under `smaptr.com/subjectIcons/` (open question).
  static const String defaultCdnBaseUrl = 'https://smaptr.com.tr';

  /// Example date of the YKS countdown (spec D-21); the real date comes from
  /// `YKS_DATE`.
  static final DateTime defaultYksDate = DateTime(2027, 6, 19);

  /// Current template application id (`android/app/build.gradle.kts`); the
  /// owner still has to pick the permanent one (FIN5).
  static const String defaultPlayPackage = 'com.smap.smap';

  static const _apiBaseUrlDefine = String.fromEnvironment('API_BASE_URL');
  static const _omrBaseUrlDefine = String.fromEnvironment('OMR_BASE_URL');
  static const _cdnBaseUrlDefine = String.fromEnvironment('CDN_BASE_URL');
  static const _supportEmailDefine = String.fromEnvironment('SUPPORT_EMAIL');
  static const _yksDateDefine = String.fromEnvironment('YKS_DATE');
  static const _appStoreIdDefine = String.fromEnvironment('APP_STORE_ID');
  static const _playPackageDefine = String.fromEnvironment('PLAY_PACKAGE');

  /// Backend host, no trailing slash. Request paths start with `/`.
  final String apiBaseUrl;

  /// Host of the optical-mark-reading endpoints.
  final String omrBaseUrl;

  /// Host of uploaded images, no trailing slash.
  final String cdnBaseUrl;

  /// Support mailbox, or `null` until the owner provides one (the "Bize Yaz"
  /// row is hidden meanwhile; no address is invented).
  final String? supportEmail;

  /// Day of the YKS exam, local midnight.
  final DateTime yksDate;

  /// Numeric App Store id, or `null` (the store link is hidden).
  final String? appStoreId;

  /// Google Play package name.
  final String playPackage;

  /// App Store page of the app, `null` without [appStoreId].
  Uri? get appStoreUri {
    final id = appStoreId;
    return id == null ? null : Uri.https('apps.apple.com', '/app/id$id');
  }

  /// Google Play page of the app.
  Uri get playStoreUri =>
      Uri.https('play.google.com', '/store/apps/details', {'id': playPackage});

  /// `mailto:` link of the support mailbox, `null` without [supportEmail].
  Uri? get supportMailUri {
    final mail = supportEmail;
    return mail == null ? null : Uri(scheme: 'mailto', path: mail);
  }

  static String? _trimmedOrNull(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  static String? _url(String? raw, String key) {
    final value = _trimmedOrNull(raw);
    if (value == null) return null;
    final uri = Uri.tryParse(value);
    final valid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
    assert(valid, '$key must be an absolute http(s) URL, got "$value".');
    if (!valid) return null;
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  static String? _email(String? raw) {
    final value = _trimmedOrNull(raw);
    if (value == null) return null;
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    assert(valid, 'SUPPORT_EMAIL must be an e-mail address, got "$value".');
    return valid ? value : null;
  }

  static DateTime? _date(String? raw) {
    final value = _trimmedOrNull(raw);
    if (value == null) return null;
    final parsed = DateTime.tryParse(value);
    assert(parsed != null, 'YKS_DATE must be ISO-8601, got "$value".');
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
}
