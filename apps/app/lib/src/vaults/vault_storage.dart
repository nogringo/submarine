import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ndk/ndk.dart' show BunkerConnection;
import 'package:nostr_passwords/nostr_passwords.dart';

import '../secure_storage.dart';

/// How this device signs for a vault: with the vault key, or through a signer
/// that holds it.
sealed class VaultLogin {
  const VaultLogin();

  /// A record saved before signers holds a private key only.
  factory VaultLogin.fromJson(Map<String, dynamic> json) =>
      switch (json['login']) {
        'nip07' => ExtensionLogin(json['pubkey'] as String),
        'nip46' => BunkerLogin(
          json['pubkey'] as String,
          BunkerConnection.fromJson(json['bunker'] as Map<String, dynamic>),
        ),
        'nip55' => SignerAppLogin(
          json['pubkey'] as String,
          package: json['package'] as String?,
        ),
        _ => KeyLogin(json['privateKey'] as String),
      };

  Map<String, dynamic> toJson();
}

class KeyLogin extends VaultLogin {
  const KeyLogin(this.privateKey);

  /// In hex.
  final String privateKey;

  @override
  Map<String, dynamic> toJson() => {'privateKey': privateKey};
}

/// The vault key stays in a signer, outside the app.
sealed class SignerLogin extends VaultLogin {
  const SignerLogin(this.pubkey);

  final String pubkey;
}

/// A browser extension (NIP-07).
class ExtensionLogin extends SignerLogin {
  const ExtensionLogin(super.pubkey);

  @override
  Map<String, dynamic> toJson() => {'login': 'nip07', 'pubkey': pubkey};
}

/// A remote signer, reached through relays (NIP-46).
class BunkerLogin extends SignerLogin {
  const BunkerLogin(super.pubkey, this.connection);

  /// Holds the key this device signs its requests to the bunker with.
  final BunkerConnection connection;

  @override
  Map<String, dynamic> toJson() => {
    'login': 'nip46',
    'pubkey': pubkey,
    'bunker': connection.toJson(),
  };
}

/// A signer app on Android (NIP-55).
class SignerAppLogin extends SignerLogin {
  const SignerAppLogin(super.pubkey, {this.package});

  /// The app that answered the login, for the next requests to reach it
  /// without showing it.
  final String? package;

  @override
  Map<String, dynamic> toJson() => {
    'login': 'nip55',
    'pubkey': pubkey,
    'package': package,
  };
}

/// A vault opened on this device. Its name and color stay on the device:
/// someone the vault is shared with names it their own way.
class VaultRecord {
  VaultRecord({
    required this.login,
    required this.name,
    required this.color,
    String? cacheKey,
    this.cacheKeySealed = false,
  }) : cacheKey = cacheKey ?? newCacheKey();

  VaultRecord.fromJson(Map<String, dynamic> json)
    : login = VaultLogin.fromJson(json),
      name = json['name'] as String,
      color = Color(json['color'] as int),
      // A record saved before the cache gets a key, which VaultStorage saves.
      cacheKey = json['cacheKey'] as String? ?? newCacheKey(),
      cacheKeySealed = json['cacheKeySealed'] as bool? ?? false;

  final VaultLogin login;
  final String name;
  final Color color;

  /// The key of the vault's [VersionCache], sealed for its signer when
  /// [cacheKeySealed].
  final String cacheKey;
  final bool cacheKeySealed;

  VaultRecord copyWith({
    String? name,
    Color? color,
    String? cacheKey,
    bool? cacheKeySealed,
  }) => VaultRecord(
    login: login,
    name: name ?? this.name,
    color: color ?? this.color,
    cacheKey: cacheKey ?? this.cacheKey,
    cacheKeySealed: cacheKeySealed ?? this.cacheKeySealed,
  );

  Map<String, dynamic> toJson() => {
    ...login.toJson(),
    'name': name,
    'color': color.toARGB32(),
    'cacheKey': cacheKey,
    'cacheKeySealed': cacheKeySealed,
  };
}

/// Keeps the vaults of this device, keys included, in its secure storage.
class VaultStorage {
  VaultStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? secureStorage;

  static const _key = 'vaults';

  final FlutterSecureStorage _storage;

  Future<List<VaultRecord>> read() async {
    final json = await _storage.read(key: _key);
    if (json == null) return [];
    final saved = (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    final records = [for (final record in saved) VaultRecord.fromJson(record)];
    if (saved.any((record) => !record.containsKey('cacheKey'))) {
      await write(records);
    }
    return records;
  }

  Future<void> write(List<VaultRecord> records) => _storage.write(
    key: _key,
    value: jsonEncode([for (final record in records) record.toJson()]),
  );
}
