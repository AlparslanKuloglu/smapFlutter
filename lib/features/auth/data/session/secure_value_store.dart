import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The few operations the session code needs from a secure key-value store.
///
/// The production one is [FlutterSecureValueStore] (Keychain, Android
/// Keystore); tests use an in-memory fake.
abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

/// [SecureValueStore] on `flutter_secure_storage`.
///
/// iOS items use `first_unlock_this_device`: readable while the app starts in
/// the background after a reboot, never synced to iCloud Keychain and never
/// restored onto another device.
final class FlutterSecureValueStore implements SecureValueStore {
  const FlutterSecureValueStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
