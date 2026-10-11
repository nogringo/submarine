import 'dart:convert';

import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';
import 'vaults.dart';

/// As Bitwarden asks of a master password, and the app of its lock password.
const minLockPasswordLength = 12;

/// The key this device encrypts its vaults with, as the app keeps it: in clear
/// without a lock password, protected by it otherwise, and then in the session
/// storage while unlocked, which the browser empties once it closes.
class DeviceKey {
  DeviceKey(this._local, this._session);

  final KeyValueStore _local;
  final KeyValueStore _session;

  static const _clearKey = 'deviceKey';
  static const _protectedKey = 'deviceKeyProtected';
  static const _unlockedKey = 'deviceKey';

  Future<bool> get hasPassword async =>
      await _local.read(_protectedKey) != null;

  Future<bool> get locked async =>
      await hasPassword && await _session.read(_unlockedKey) == null;

  /// The key, new while there is none. Throws a [CoreException] `locked`
  /// while the lock password protects it and nothing unlocked it.
  Future<SymmetricCryptoKey> read() async {
    if (await hasPassword) {
      // Left by a password set halfway: the key must not stay in clear.
      if (await _local.read(_clearKey) != null) await _local.remove(_clearKey);
      final unlocked = await _session.read(_unlockedKey);
      if (unlocked == null) throw CoreException('locked');
      return _decode(unlocked);
    }
    final clear = await _local.read(_clearKey);
    if (clear != null) return _decode(clear);
    final key = SymmetricCryptoKey.generate();
    await _local.write(_clearKey, _encode(key));
    return key;
  }

  /// Protects the key with [password], which then unlocks the vaults. Leaves
  /// them unlocked.
  Future<void> setPassword(String password) async {
    if (password.length < minLockPasswordLength) {
      throw CoreException('lockPasswordTooShort');
    }
    final key = await read();
    final protected = await PasswordProtectedKey.protect(key, password);
    await _session.write(_unlockedKey, _encode(key));
    await _local.write(_protectedKey, jsonEncode(protected));
    await _local.remove(_clearKey);
  }

  Future<void> lock() => _session.remove(_unlockedKey);

  /// Whether [password] is the lock password, which then unlocks the vaults.
  Future<bool> unlock(String password) async {
    final saved = await _local.read(_protectedKey);
    if (saved == null) return true;
    final protected = PasswordProtectedKey.fromJson(
      jsonDecode(saved) as Map<String, dynamic>,
    );
    final key = await protected.open(password);
    if (key == null) return false;
    await _session.write(_unlockedKey, _encode(key));
    return true;
  }

  static String _encode(SymmetricCryptoKey key) => base64.encode(key.bytes);

  static SymmetricCryptoKey _decode(String saved) =>
      SymmetricCryptoKey(base64.decode(saved));
}
