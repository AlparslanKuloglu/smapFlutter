import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:smap/core/config/app_config.dart';
import 'package:smap/core/services/app_logger.dart';

/// Opens a [Uri] outside the app; `launchUrl` unless a test says otherwise.
typedef UriOpener = Future<bool> Function(Uri uri);

/// Opens the places the general screens point to: the store page of the app
/// ("Güncelle") and a mail draft to support ("Destek'e Yaz").
///
/// The addresses come from [AppConfig]; one that is not configured yet (no
/// App Store id, no support mailbox) is reported as unavailable instead of
/// inventing one.
class StoreLauncher {
  StoreLauncher({
    required AppConfig config,
    AppLogger? logger,
    UriOpener? opener,
    TargetPlatform? platform,
  }) : _config = config,
       _logger = logger ?? AppLogger.silent(),
       _open = opener ?? _launchExternal,
       _platform = platform;

  final AppConfig _config;
  final AppLogger _logger;
  final UriOpener _open;
  final TargetPlatform? _platform;

  TargetPlatform get _target => _platform ?? defaultTargetPlatform;

  /// The store page of this platform, `null` when it is not known (iOS before
  /// the App Store id is configured, other platforms).
  Uri? get storeUri => switch (_target) {
    TargetPlatform.iOS => _config.appStoreUri,
    TargetPlatform.android => _config.playStoreUri,
    _ => null,
  };

  /// A support mailbox is configured.
  bool get canWriteSupport => _config.supportMailUri != null;

  /// Opens the store page. `false` when there is none or it did not open.
  Future<bool> openStorePage() => _openOrNull(storeUri);

  /// Opens a mail draft to support. `false` without a configured address.
  Future<bool> writeSupport() => _openOrNull(_config.supportMailUri);

  Future<bool> _openOrNull(Uri? uri) async {
    if (uri == null) return false;
    try {
      return await _open(uri);
    } on Object catch (error) {
      _logger.warning('could not open $uri', name: 'Startup', error: error);
      return false;
    }
  }

  static Future<bool> _launchExternal(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}
