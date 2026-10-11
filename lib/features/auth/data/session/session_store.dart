import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:smap/core/services/app_logger.dart';
import 'package:smap/features/auth/data/dtos/user_dto.dart';
import 'package:smap/features/auth/data/session/secure_value_store.dart';

/// The device copy of the signed-in user, kept in secure storage so the app can
/// open on the last known user while offline ("iyimser açılış").
///
/// The session itself is the cookie in the cookie jar; this store holds only
/// the user JSON (without `password`, which [UserDto] does not model). One key,
/// one write: a kill between two writes cannot leave half a record.
///
/// Reads and writes never throw. A read that keeps failing answers `null`
/// without deleting anything (the Keychain can fail transiently right after
/// launch), a record that is not valid JSON is deleted.
class SessionStore {
  SessionStore({
    required SecureValueStore storage,
    AppLogger? logger,
    this.legacyMirror = false,
    Future<SharedPreferences> Function()? legacyPreferences,
    Duration retryDelay = const Duration(milliseconds: 300),
  }) : _storage = storage,
       _logger = logger ?? AppLogger.silent(),
       _legacyPreferences = legacyPreferences ?? SharedPreferences.getInstance,
       _retryDelay = retryDelay;

  /// Secure-storage key of the cached user (`{"v": 1, "user": {...}}`).
  static const String userKey = 'smap.session.user';

  static const int _version = 1;
  static const int _readAttempts = 3;

  /// The legacy plain-text copy of the user JSON.
  static const String legacyUserDataKey = 'user_data';

  /// Legacy keys that belonged to a session. `isLoggedIn` and `connect_sid`
  /// are written by the legacy `AuthLocalDataSource`; `bagItemsStr` is the
  /// legacy schedule screen's per-user cache, global in the legacy code, so it
  /// must not survive a sign-out.
  static const List<String> legacySessionKeys = [
    legacyUserDataKey,
    'isLoggedIn',
    'connect_sid',
    'bagItemsStr',
  ];

  final SecureValueStore _storage;
  final AppLogger _logger;
  final Future<SharedPreferences> Function() _legacyPreferences;
  final Duration _retryDelay;

  /// While legacy screens still read `user_data` from `SharedPreferences`
  /// (OMR flow, account settings, analytics, home), every [write] also keeps a
  /// plain copy there, and the legacy migration does not delete it. Turn it
  /// off when the last legacy reader is gone; the plain copy is then removed.
  final bool legacyMirror;

  /// The cached user, or `null` when there is none or it cannot be read.
  Future<UserDto?> read() async {
    final raw = await _readRaw();
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map || decoded['user'] is! Map) {
        throw const FormatException('not a session record');
      }
      return UserDto.fromJson(
        Map<String, dynamic>.from(decoded['user'] as Map),
      );
    } on Object catch (error) {
      _logger.warning(
        'cached user is corrupt, dropped',
        name: 'Session',
        error: error,
      );
      await _deleteSecure();
      return null;
    }
  }

  /// Stores [user]. Returns `false` when the secure store refused the write.
  Future<bool> write(UserDto user) async {
    final json = user.toJson();
    try {
      await _storage.write(
        userKey,
        jsonEncode(<String, Object?>{'v': _version, 'user': json}),
      );
    } on Object catch (error) {
      _logger.warning(
        'cached user write failed',
        name: 'Session',
        error: error,
      );
      return false;
    }
    if (legacyMirror) await _mirror(json);
    return true;
  }

  /// Forgets the cached user and every legacy session key.
  Future<void> clear() async {
    await _deleteSecure();
    await removeLegacyKeys();
  }

  /// Removes the legacy plain-text session keys.
  Future<void> removeLegacyKeys({Iterable<String>? keys}) async {
    try {
      final prefs = await _legacyPreferences();
      for (final key in keys ?? legacySessionKeys) {
        await prefs.remove(key);
      }
    } on Object catch (error) {
      _logger.warning('legacy keys not removed', name: 'Session', error: error);
    }
  }

  Future<String?> _readRaw() async {
    for (var attempt = 1; attempt <= _readAttempts; attempt++) {
      try {
        return await _storage.read(userKey);
      } on Object catch (error) {
        _logger.warning(
          'secure read failed ($attempt/$_readAttempts)',
          name: 'Session',
          error: error,
        );
        if (attempt < _readAttempts) await Future<void>.delayed(_retryDelay);
      }
    }
    return null;
  }

  Future<void> _deleteSecure() async {
    try {
      await _storage.delete(userKey);
    } on Object catch (error) {
      _logger.warning(
        'cached user delete failed',
        name: 'Session',
        error: error,
      );
    }
  }

  Future<void> _mirror(Map<String, dynamic> json) async {
    try {
      final prefs = await _legacyPreferences();
      await prefs.setString(legacyUserDataKey, jsonEncode(json));
    } on Object catch (error) {
      _logger.warning('legacy mirror failed', name: 'Session', error: error);
    }
  }
}
