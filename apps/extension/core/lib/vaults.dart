import 'dart:convert';

import 'package:ndk/ndk.dart';
import 'package:nostr_passwords/nostr_passwords.dart';

import 'core.dart';
import 'device_key.dart';

/// Strings kept by the extension: its `storage.local` or `storage.session`.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
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

  VaultRecord copyWith({String? name, int? color}) => VaultRecord(
    privateKey: privateKey,
    name: name ?? this.name,
    color: color ?? this.color,
    cacheKey: cacheKey,
  );

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
  Vaults(this._store, this._signers, this._deviceKey);

  final KeyValueStore _store;
  final LocalEventSignerFactory _signers;
  final DeviceKey _deviceKey;

  static const _vaultsKey = 'vaults';

  /// The popup saves a name at each key typed: each write reads what the
  /// previous one saved.
  Future<void> _writing = Future.value();

  Future<List<VaultRecord>> records() async {
    final saved = await _store.read(_vaultsKey);
    if (saved == null) return [];
    final json =
        await (await _deviceKey.read()).decryptString(saved) ??
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
  }) => _write(() async {
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
    await _save([...records, record]);
    return _summary(record);
  });

  /// Renames the vault [pubkey], or changes its color.
  Future<Map<String, Object>> edit(String pubkey, {String? name, int? color}) =>
      _write(() async {
        final trimmed = name?.trim();
        if (trimmed != null && trimmed.isEmpty) {
          throw CoreException('vaultNameRequired');
        }
        final records = await this.records();
        final index = records.indexWhere(
          (record) => _signers.derivePublicKey(record.privateKey) == pubkey,
        );
        if (index == -1) throw CoreException('vaultNotFound');
        final record = records[index] = records[index].copyWith(
          name: trimmed,
          color: color,
        );
        await _save(records);
        return _summary(record);
      });

  /// Removes the vault [pubkey] from this device, and returns its record.
  Future<VaultRecord> remove(String pubkey) => _write(() async {
    final records = await this.records();
    final index = records.indexWhere(
      (record) => _signers.derivePublicKey(record.privateKey) == pubkey,
    );
    if (index == -1) throw CoreException('vaultNotFound');
    final record = records.removeAt(index);
    await _save(records);
    return record;
  });

  /// Removes every vault from this device, without reading them: what a
  /// forgotten lock password leaves.
  Future<void> forget() => _write(() => _store.remove(_vaultsKey));

  Future<T> _write<T>(Future<T> Function() write) {
    final written = _writing.then((_) => write());
    _writing = written.then((_) {}, onError: (_) {});
    return written;
  }

  Future<void> _save(List<VaultRecord> records) async => _store.write(
    _vaultsKey,
    await (await _deviceKey.read()).encryptString(jsonEncode(records)),
  );

  Map<String, Object> _summary(VaultRecord record) => {
    'pubkey': _signers.derivePublicKey(record.privateKey),
    'name': record.name,
    'color': record.color,
  };
}
