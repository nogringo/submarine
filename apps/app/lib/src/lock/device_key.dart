import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// The key this device encrypts its vaults with, as Bitwarden's user key: in
/// clear without a lock password, or for biometrics to unlock with one, and
/// protected by the lock password when there is one.
class DeviceKeyStorage {
  DeviceKeyStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? secureStorage;

  static const _clearKey = 'vaultsKey';
  static const _protectedKey = 'vaultsKeyProtected';

  final FlutterSecureStorage _storage;

  /// The key kept in clear, if any.
  Future<SymmetricCryptoKey?> read() async {
    final saved = await _storage.read(key: _clearKey);
    return saved == null ? null : SymmetricCryptoKey(base64.decode(saved));
  }

  /// A new key, kept in clear.
  Future<SymmetricCryptoKey> create() async {
    final key = SymmetricCryptoKey.generate();
    await write(key);
    return key;
  }

  Future<void> write(SymmetricCryptoKey key) =>
      _storage.write(key: _clearKey, value: base64.encode(key.bytes));

  Future<void> delete() => _storage.delete(key: _clearKey);

  Future<PasswordProtectedKey?> readProtected() async {
    final saved = await _storage.read(key: _protectedKey);
    return saved == null
        ? null
        : PasswordProtectedKey.fromJson(
            jsonDecode(saved) as Map<String, dynamic>,
          );
  }

  Future<void> writeProtected(PasswordProtectedKey key) =>
      _storage.write(key: _protectedKey, value: jsonEncode(key));

  Future<void> deleteProtected() => _storage.delete(key: _protectedKey);
}
