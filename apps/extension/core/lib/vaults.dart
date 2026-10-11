import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';

/// Strings kept by the extension: its `storage.local`.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

/// A vault opened on this device. Its name and color stay on the device, as in
/// the app: someone the vault is shared with names it their own way.
class VaultRecord {
  VaultRecord({
    required this.privateKey,
    required this.name,
    required this.color,
    String? cacheKey,
  }) : cacheKey = cacheKey ?? newCacheKey();

  VaultRecord.fromJson(Map<String, dynamic> json)
    : privateKey = json['privateKey'] as String,
      name = json['name'] as String,
      color = json['color'] as int,
      cacheKey = json['cacheKey'] as String;

  /// In hex.
  final String privateKey;
  final String name;

  /// In ARGB, as the app saves it.
  final int color;

  /// The key of the vault's [VersionCache].
  final String cacheKey;

  Map<String, dynamic> toJson() => {
    'privateKey': privateKey,
    'name': name,
    'color': color,
    'cacheKey': cacheKey,
  };
}

/// The vaults of this device, keys included, encrypted with the key of the
/// device as the app keeps them.
class Vaults {
  Vaults(this._store, this._signers);

  final KeyValueStore _store;
  final LocalEventSignerFactory _signers;

  static const _deviceKeyKey = 'deviceKey';
  static const _vaultsKey = 'vaults';

  Future<List<VaultRecord>> records() async {
    final saved = await _store.read(_vaultsKey);
    if (saved == null) return [];
    final json =
        await (await _deviceKey()).decryptString(saved) ??
        (throw CoreException('vaultsUnreadable'));
    return [
      for (final record in jsonDecode(json) as List)
        VaultRecord.fromJson(record as Map<String, dynamic>),
    ];
  }

  /// What the popup shows of each vault: no key.
  Future<List<Map<String, Object>>> list() async => [
    for (final record in await records()) _summary(record),
  ];

  /// Opens the vault of [key], an nsec, a key in hex or an ncryptsec that
  /// [password] decrypts.
  Future<Map<String, Object>> add({
    required String key,
    String? password,
    required String name,
    required int color,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw CoreException('vaultNameRequired');
    final privateKey =
        parseVaultKey(key) ??
        (isEncryptedVaultKey(key)
            ? await decryptVaultKey(key, password ?? '') ??
                  (throw CoreException('vaultKeyPasswordWrong'))
            : throw CoreException('vaultKeyInvalid'));
    final records = await this.records();
    final pubkey = _signers.derivePublicKey(privateKey);
    for (final record in records) {
      if (_signers.derivePublicKey(record.privateKey) == pubkey) {
        throw CoreException('vaultAlreadyOpen', record.name);
      }
    }
    final record = VaultRecord(
      privateKey: privateKey,
      name: trimmed,
      color: color,
    );
    await _store.write(
      _vaultsKey,
      await (await _deviceKey()).encryptString(
        jsonEncode([...records, record]),
      ),
    );
    return _summary(record);
  }

  Map<String, Object> _summary(VaultRecord record) => {
    'pubkey': _signers.derivePublicKey(record.privateKey),
    'name': record.name,
    'color': record.color,
  };

  Future<SymmetricCryptoKey> _deviceKey() async {
    final saved = await _store.read(_deviceKeyKey);
    if (saved != null) return SymmetricCryptoKey(base64.decode(saved));
    final key = SymmetricCryptoKey.generate();
    await _store.write(_deviceKeyKey, base64.encode(key.bytes));
    return key;
  }
}
