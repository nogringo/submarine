import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:serverpod_argon2/serverpod_argon2.dart';

/// How a key is derived from a password, as Bitwarden's KdfConfig.
class KdfConfig {
  /// PBKDF2-SHA256, Bitwarden's default for an account.
  const KdfConfig.pbkdf2({this.iterations = 600000})
    : type = _pbkdf2,
      memory = null,
      parallelism = null;

  /// Argon2id, with Bitwarden's defaults. [memory] is in MiB.
  const KdfConfig.argon2id({
    this.iterations = 6,
    int this.memory = 32,
    int this.parallelism = 4,
  }) : type = _argon2id;

  /// From Bitwarden's `kdfType`, `kdfIterations`, `kdfMemory` and
  /// `kdfParallelism`. Throws a [FormatException] for a key derivation
  /// Bitwarden does not allow.
  factory KdfConfig.fromJson(Map<String, dynamic> json) {
    final kdf = switch ((
      json['kdfType'],
      json['kdfIterations'],
      json['kdfMemory'],
      json['kdfParallelism'],
    )) {
      (_pbkdf2, final int iterations, _, _) => KdfConfig.pbkdf2(
        iterations: iterations,
      ),
      (_argon2id, final int iterations, final int memory, final int threads) =>
        KdfConfig.argon2id(
          iterations: iterations,
          memory: memory,
          parallelism: threads,
        ),
      _ => null,
    };
    if (kdf == null || !kdf.isAllowed) {
      throw const FormatException('Not a key derivation Bitwarden allows.');
    }
    return kdf;
  }

  static const _pbkdf2 = 0;
  static const _argon2id = 1;

  /// Bitwarden's `KdfType`.
  final int type;
  final int iterations;
  final int? memory;
  final int? parallelism;

  /// Within the bounds of Bitwarden's KdfConfig, which also keep a file from
  /// asking for more memory than a device has.
  bool get isAllowed => switch ((type, memory, parallelism)) {
    (_pbkdf2, _, _) => iterations >= 5000 && iterations <= 2000000,
    (_argon2id, final int memory, final int parallelism) =>
      iterations >= 2 &&
          iterations <= 10 &&
          memory >= 16 &&
          memory <= 1024 &&
          parallelism >= 1 &&
          parallelism <= 16,
    _ => false,
  };

  Map<String, dynamic> toJson() => {
    'kdfType': type,
    'kdfIterations': iterations,
    'kdfMemory': ?memory,
    'kdfParallelism': ?parallelism,
  };

  /// The key of the KDF, stretched as Bitwarden stretches a master key.
  Future<SymmetricCryptoKey> deriveKey(String password, String salt) async {
    final secret = utf8.encode(password);
    final List<int> key;
    if (type == _pbkdf2) {
      final derived =
          await cryptography.Pbkdf2(
            macAlgorithm: cryptography.Hmac.sha256(),
            iterations: iterations,
            bits: 256,
          ).deriveKey(
            secretKey: cryptography.SecretKey(secret),
            nonce: utf8.encode(salt),
          );
      key = await derived.extractBytes();
    } else {
      key = (await _argon2).deriveKey(
        password: secret,
        // Bitwarden hashes the salt for Argon2id.
        salt: sha256.convert(utf8.encode(salt)).bytes,
        parameters: Argon2Parameters(
          iterations: iterations,
          memoryKiB: memory! * 1024,
          parallelism: parallelism!,
        ),
      );
    }
    // HKDF-Expand to 32 bytes, a single HMAC.
    List<int> expand(String info) =>
        Hmac(sha256, key).convert([...utf8.encode(info), 1]).bytes;
    return SymmetricCryptoKey([...expand('enc'), ...expand('mac')]);
  }

  @override
  String toString() => 'KdfConfig(${toJson()})';
}

/// Compiled from Zig: in a browser, cryptography's Argon2id in Dart is about
/// 25 times slower.
final _argon2 = Argon2.load();

/// Bitwarden's SymmetricCryptoKey for AES-256-CBC with HMAC-SHA256: the key
/// that encrypts, then the key that authenticates, 64 bytes together.
class SymmetricCryptoKey {
  /// Throws an [ArgumentError] unless [bytes] are 64 bytes long.
  SymmetricCryptoKey(List<int> bytes)
    : bytes = bytes.length == 64
          ? Uint8List.fromList(bytes)
          : throw ArgumentError.value(bytes.length, 'bytes', 'Not 64 bytes'),
      _enc = cryptography.SecretKey(bytes.sublist(0, 32)),
      _mac = bytes.sublist(32);

  SymmetricCryptoKey.generate() : this(_randomBytes(64));

  final Uint8List bytes;
  final cryptography.SecretKey _enc;
  final List<int> _mac;

  /// [clear] as Bitwarden's EncString of type 2: AES-256-CBC, then
  /// HMAC-SHA256 of the IV and the cipher text.
  Future<String> encryptString(String clear) => _encrypt(utf8.encode(clear));

  /// Null when this key is not the one [encrypted] was encrypted with. Throws
  /// a [FormatException] when [encrypted] is not an EncString of type 2.
  Future<String?> decryptString(String encrypted) async {
    final clear = await _decrypt(encrypted);
    return clear == null ? null : utf8.decode(clear);
  }

  Future<String> _encrypt(List<int> clear) async {
    final iv = _aes.newNonce();
    final box = await _aes.encrypt(clear, secretKey: _enc, nonce: iv);
    final mac = Hmac(sha256, _mac).convert([...iv, ...box.cipherText]);
    return '2.${base64.encode(iv)}|${base64.encode(box.cipherText)}'
        '|${base64.encode(mac.bytes)}';
  }

  Future<List<int>?> _decrypt(String encrypted) async {
    final parts = RegExp(r'^2\.([^|]+)\|([^|]+)\|([^|]+)$')
        .firstMatch(encrypted);
    if (parts == null) throw const FormatException('Not an EncString.');
    final [iv, cipherText, mac] = [
      for (var i = 1; i <= 3; i++) base64.decode(parts[i]!),
    ];
    final expected = Hmac(sha256, _mac).convert([...iv, ...cipherText]);
    if (!_sameBytes(expected.bytes, mac)) return null;
    return _aes.decrypt(
      cryptography.SecretBox(
        cipherText,
        nonce: iv,
        mac: cryptography.Mac.empty,
      ),
      secretKey: _enc,
    );
  }
}

/// A [SymmetricCryptoKey] encrypted under a key derived from a password, as
/// Bitwarden protects the user key of an account with its master password.
class PasswordProtectedKey {
  const PasswordProtectedKey._(this.kdf, this.salt, this.encryptedKey);

  /// From [toJson]. Throws a [FormatException] for anything else, or for a
  /// key derivation Bitwarden does not allow.
  factory PasswordProtectedKey.fromJson(Map<String, dynamic> json) {
    final (salt, key) = (json['salt'], json['key']);
    if (salt is! String || salt.isEmpty || key is! String) {
      throw const FormatException('Not a password protected key.');
    }
    return PasswordProtectedKey._(KdfConfig.fromJson(json), salt, key);
  }

  /// Throws an [ArgumentError] for a [kdf] Bitwarden does not allow.
  static Future<PasswordProtectedKey> protect(
    SymmetricCryptoKey key,
    String password, {
    KdfConfig kdf = const KdfConfig.argon2id(),
  }) async {
    if (!kdf.isAllowed) {
      throw ArgumentError.value(kdf, 'kdf', 'Not allowed by Bitwarden');
    }
    final salt = base64.encode(_randomBytes(16));
    final derived = await kdf.deriveKey(password, salt);
    return PasswordProtectedKey._(kdf, salt, await derived._encrypt(key.bytes));
  }

  final KdfConfig kdf;
  final String salt;

  /// The key, as an EncString of type 2.
  final String encryptedKey;

  /// The key, or null when [password] does not open it.
  Future<SymmetricCryptoKey?> open(String password) async {
    final derived = await kdf.deriveKey(password, salt);
    final bytes = await derived._decrypt(encryptedKey);
    return bytes == null ? null : SymmetricCryptoKey(bytes);
  }

  Map<String, dynamic> toJson() => {
    'salt': salt,
    ...kdf.toJson(),
    'key': encryptedKey,
  };
}

final _aes = cryptography.AesCbc.with256bits(
  macAlgorithm: cryptography.MacAlgorithm.empty,
);

/// In constant time, so that a forged MAC learns nothing from timing.
bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }
  return difference == 0;
}

final _random = Random.secure();

List<int> _randomBytes(int length) => [
  for (var i = 0; i < length; i++) _random.nextInt(256),
];
