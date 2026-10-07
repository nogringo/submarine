import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// The key this device encrypts its vaults with, as Bitwarden's user key.
class DeviceKeyStorage {
  DeviceKeyStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? secureStorage;

  static const _key = 'vaultsKey';

  final FlutterSecureStorage _storage;

  /// The key kept in the secure storage, made on the first read.
  Future<SymmetricCryptoKey> read() async {
    if (await _storage.read(key: _key) case final saved?) {
      return SymmetricCryptoKey(base64.decode(saved));
    }
    final key = SymmetricCryptoKey.generate();
    await _storage.write(key: _key, value: base64.encode(key.bytes));
    return key;
  }
}
