import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:smap/core/services/app_logger.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/session_store.dart';

/// What [LegacySessionMigration.run] found.
enum LegacyMigrationResult {
  /// No legacy session data on the device.
  nothingToMigrate,

  /// The plain `user_data` moved into secure storage.
  migrated,

  /// Secure storage already had a user (a newer copy); the legacy one was not
  /// used.
  secureStoreWins,

  /// The legacy `user_data` was not a usable user object and was dropped.
  corrupt,

  /// The secure store refused the write; the legacy copy is left untouched so
  /// the next launch tries again.
  writeFailed,
}

/// One-time move of the legacy session data into secure storage.
///
/// Before this app version the user JSON sat in plain `SharedPreferences`
/// (`user_data`, with the password hash the student document carries). On the
/// first launch the bridge reads it, writes it to the [SessionStore], checks it
/// reads back, and only then deletes the plain copy. The session cookie
/// (`<documents>/.cookies/`) is not touched, so a user who is signed in today
/// stays signed in.
///
/// Idempotent: a second run finds nothing, or finds a secure copy and keeps it.
/// It never throws.
class LegacySessionMigration {
  LegacySessionMigration({
    required SessionStore store,
    AppLogger? logger,
    Future<SharedPreferences> Function()? legacyPreferences,
  }) : _store = store,
       _logger = logger ?? AppLogger.silent(),
       _legacyPreferences = legacyPreferences ?? SharedPreferences.getInstance;

  final SessionStore _store;
  final AppLogger _logger;
  final Future<SharedPreferences> Function() _legacyPreferences;

  Future<LegacyMigrationResult> run() async {
    try {
      return await _run();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'legacy session migration failed',
        name: 'Session',
        error: error,
        stackTrace: stackTrace,
      );
      return LegacyMigrationResult.writeFailed;
    }
  }

  Future<LegacyMigrationResult> _run() async {
    final prefs = await _legacyPreferences();
    final raw = prefs.getString(SessionStore.legacyUserDataKey);

    // The dead legacy keys never carry data worth moving: drop them whatever
    // happens to the user JSON. With the mirror on, `user_data` itself stays.
    final deadKeys = SessionStore.legacySessionKeys.where(
      (key) => key == 'isLoggedIn' || key == 'connect_sid',
    );
    await _store.removeLegacyKeys(keys: deadKeys);

    if (raw == null || raw.trim().isEmpty) {
      return LegacyMigrationResult.nothingToMigrate;
    }

    final user = _parse(raw);
    if (user == null) {
      _logger.warning('legacy user_data is not a user object', name: 'Session');
      await _dropPlainCopy();
      return LegacyMigrationResult.corrupt;
    }

    if (await _store.read() != null) {
      await _dropPlainCopy();
      return LegacyMigrationResult.secureStoreWins;
    }

    // Write, then read back, then delete: the plain copy is the only copy
    // until the secure one is proven.
    final written = await _store.write(user);
    if (!written || await _store.read() != user) {
      return LegacyMigrationResult.writeFailed;
    }
    await _dropPlainCopy();
    _logger.info('legacy session moved to secure storage', name: 'Session');
    return LegacyMigrationResult.migrated;
  }

  Future<void> _dropPlainCopy() async {
    if (_store.legacyMirror) return;
    await _store.removeLegacyKeys(keys: const [SessionStore.legacyUserDataKey]);
  }

  static UserDto? _parse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded.isEmpty) return null;
      final user = UserDto.fromJson(Map<String, dynamic>.from(decoded));
      // A user object without any identity is not a session.
      return user.id == null && user.role == null && user.userName == null
          ? null
          : user;
    } on Object {
      return null;
    }
  }
}
