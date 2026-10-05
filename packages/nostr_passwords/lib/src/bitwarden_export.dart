import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;

import 'cipher/cipher.dart';
import 'item.dart';

/// A Bitwarden export encrypted with the key of a Bitwarden account, which
/// only that account opens.
class EncryptedExportException implements Exception {
  const EncryptedExportException();

  @override
  String toString() =>
      'EncryptedExportException: the export is restricted to its account.';
}

/// A password protected Bitwarden export, which [decryptBitwardenExport]
/// opens.
class PasswordProtectedExportException implements Exception {
  const PasswordProtectedExportException();

  @override
  String toString() =>
      'PasswordProtectedExportException: the export is password protected.';
}

/// The password does not open a password protected Bitwarden export.
class WrongExportPasswordException implements Exception {
  const WrongExportPasswordException();

  @override
  String toString() =>
      'WrongExportPasswordException: the password does not open the export.';
}

/// The items of a Bitwarden JSON export, the file Bitwarden writes for the
/// `.json` format, ready for `Vault.createItem`.
///
/// As Bitwarden's importer does, it drops the ids, the organization, the
/// collections and the cipher keys, keeps 5 password history entries at most,
/// and names an item without a name `--`. Folders are dropped too, as vaults
/// have none.
///
/// Throws a [PasswordProtectedExportException] for a password protected
/// export, an [EncryptedExportException] for one restricted to its account,
/// and a [FormatException] for anything else that is not a Bitwarden JSON
/// export.
List<Cipher> parseBitwardenExport(String source) {
  final json = _decodeExport(source);
  if (json['encrypted'] == true) {
    throw json['passwordProtected'] == true
        ? const PasswordProtectedExportException()
        : const EncryptedExportException();
  }
  final items = json['items'];
  if (items is! List) throw const FormatException('Not a Bitwarden export.');
  try {
    return [for (final item in items) _importCipher(item)];
  } on TypeError {
    throw const FormatException('Not a Bitwarden item.');
  }
}

/// [items] as a Bitwarden JSON export, not encrypted, which Bitwarden imports
/// with its `Bitwarden (json)` format. As in Bitwarden, the trash is left out.
String writeBitwardenExport(Iterable<Item> items) => _encoder.convert({
  'encrypted': false,
  'folders': const [],
  'items': [
    for (final item in items)
      if (!item.cipher.isDeleted) _exportItem(item),
  ],
});

/// The export inside a password protected Bitwarden export, for
/// [parseBitwardenExport], as Bitwarden's importer opens it.
///
/// Throws a [WrongExportPasswordException] when [password] does not open it,
/// and a [FormatException] when [source] is not a password protected export.
Future<String> decryptBitwardenExport(String source, String password) async {
  final json = _decodeExport(source);
  final (salt, validation, data) = (
    json['salt'],
    json['encKeyValidation_DO_NOT_EDIT'],
    json['data'],
  );
  if (json['encrypted'] != true ||
      json['passwordProtected'] != true ||
      salt is! String ||
      salt.isEmpty ||
      validation is! String ||
      data is! String) {
    throw const FormatException('Not a password protected export.');
  }
  final keys = await ExportKdf._fromJson(json)._deriveKeys(password, salt);
  if (await _decryptString(validation, keys) == null) {
    throw const WrongExportPasswordException();
  }
  return await _decryptString(data, keys) ??
      (throw const FormatException('The export is damaged.'));
}

/// [export], as [writeBitwardenExport] writes it, protected by [password] as
/// Bitwarden protects its exports, which Bitwarden imports.
Future<String> encryptBitwardenExport(
  String export,
  String password, {
  ExportKdf kdf = const ExportKdf.argon2id(),
}) async {
  if (!kdf._isAllowed) {
    throw ArgumentError.value(kdf, 'kdf', 'Not allowed by Bitwarden');
  }
  final salt = base64.encode(_randomBytes(16));
  final keys = await kdf._deriveKeys(password, salt);
  return _encoder.convert({
    'encrypted': true,
    'passwordProtected': true,
    'salt': salt,
    ...kdf._toJson(),
    // Any value: an importer only checks that it decrypts.
    'encKeyValidation_DO_NOT_EDIT': await _encryptString(
      base64.encode(_randomBytes(16)),
      keys,
    ),
    'data': await _encryptString(export, keys),
  });
}

/// How a password protected export derives its key from the password, as
/// Bitwarden's KdfConfig.
class ExportKdf {
  /// PBKDF2-SHA256, Bitwarden's default for an account.
  const ExportKdf.pbkdf2({this.iterations = 600000})
    : type = _pbkdf2,
      memory = null,
      parallelism = null;

  /// Argon2id, with Bitwarden's defaults. [memory] is in MiB.
  const ExportKdf.argon2id({
    this.iterations = 6,
    int this.memory = 32,
    int this.parallelism = 4,
  }) : type = _argon2id;

  factory ExportKdf._fromJson(Map<String, dynamic> json) {
    final kdf = switch ((
      json['kdfType'],
      json['kdfIterations'],
      json['kdfMemory'],
      json['kdfParallelism'],
    )) {
      (_pbkdf2, final int iterations, _, _) => ExportKdf.pbkdf2(
        iterations: iterations,
      ),
      (_argon2id, final int iterations, final int memory, final int threads) =>
        ExportKdf.argon2id(
          iterations: iterations,
          memory: memory,
          parallelism: threads,
        ),
      _ => null,
    };
    if (kdf == null || !kdf._isAllowed) {
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
  bool get _isAllowed => switch ((type, memory, parallelism)) {
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

  Map<String, dynamic> _toJson() => {
    'kdfType': type,
    'kdfIterations': iterations,
    'kdfMemory': ?memory,
    'kdfParallelism': ?parallelism,
  };

  /// Bitwarden's deriveVaultExportKey: the key of the KDF, stretched.
  Future<_Keys> _deriveKeys(String password, String salt) async {
    final algorithm = type == _pbkdf2
        ? cryptography.Pbkdf2(
            macAlgorithm: cryptography.Hmac.sha256(),
            iterations: iterations,
            bits: 256,
          )
        : cryptography.Argon2id(
            parallelism: parallelism!,
            memory: memory! * 1024,
            iterations: iterations,
            hashLength: 32,
          );
    final key = await algorithm.deriveKey(
      secretKey: cryptography.SecretKey(utf8.encode(password)),
      // Bitwarden hashes the salt for Argon2id.
      nonce: type == _pbkdf2
          ? utf8.encode(salt)
          : sha256.convert(utf8.encode(salt)).bytes,
    );
    final bytes = await key.extractBytes();
    // HKDF-Expand to 32 bytes, a single HMAC.
    List<int> expand(String info) =>
        Hmac(sha256, bytes).convert([...utf8.encode(info), 1]).bytes;
    return (enc: expand('enc'), mac: expand('mac'));
  }

  @override
  String toString() => 'ExportKdf(${_toJson()})';
}

typedef _Keys = ({List<int> enc, List<int> mac});

final _aes = cryptography.AesCbc.with256bits(
  macAlgorithm: cryptography.MacAlgorithm.empty,
);

/// Bitwarden's EncString of type 2: AES-256-CBC, then HMAC-SHA256 of the IV
/// and the cipher text.
Future<String> _encryptString(String clear, _Keys keys) async {
  final iv = _aes.newNonce();
  final box = await _aes.encrypt(
    utf8.encode(clear),
    secretKey: cryptography.SecretKey(keys.enc),
    nonce: iv,
  );
  final mac = Hmac(sha256, keys.mac).convert([...iv, ...box.cipherText]);
  return '2.${base64.encode(iv)}|${base64.encode(box.cipherText)}'
      '|${base64.encode(mac.bytes)}';
}

/// Null when [keys] are not those [encrypted] was encrypted with.
Future<String?> _decryptString(String encrypted, _Keys keys) async {
  final parts = RegExp(r'^2\.([^|]+)\|([^|]+)\|([^|]+)$').firstMatch(encrypted);
  if (parts == null) throw const FormatException('Not an EncString.');
  final [iv, cipherText, mac] = [
    for (var i = 1; i <= 3; i++) base64.decode(parts[i]!),
  ];
  final expected = Hmac(sha256, keys.mac).convert([...iv, ...cipherText]);
  if (!_sameBytes(expected.bytes, mac)) return null;
  final clear = await _aes.decrypt(
    cryptography.SecretBox(cipherText, nonce: iv, mac: cryptography.Mac.empty),
    secretKey: cryptography.SecretKey(keys.enc),
  );
  return utf8.decode(clear);
}

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

const _encoder = JsonEncoder.withIndent('  ');

Map<String, dynamic> _decodeExport(String source) {
  final Object? json = jsonDecode(
    source.startsWith('\uFEFF') ? source.substring(1) : source,
  );
  if (json is! Map<String, dynamic>) {
    throw const FormatException('Not a Bitwarden export.');
  }
  return json;
}

/// Bitwarden ids and keys, which mean nothing outside their account.
const _accountKeys = {
  'id',
  'organizationId',
  'folderId',
  'collectionIds',
  'key',
};

/// Bitwarden's CipherExport.toView, then BaseImporter.cleanupCipher.
Cipher _importCipher(Object? json) {
  final cipher = Cipher.fromJson({
    for (final MapEntry(:key, :value) in (json as Map<String, dynamic>).entries)
      if (!_accountKeys.contains(key)) key: value,
  });
  if (cipher.passwordHistory.length > 5) {
    cipher.passwordHistory = cipher.passwordHistory.sublist(0, 5);
  }
  if (cipher.type != CipherType.login) cipher.login = null;
  if (cipher.name.trim().isEmpty) cipher.name = '--';
  if (cipher.notes?.trim().isEmpty ?? false) cipher.notes = null;
  cipher.creationDate ??= DateTime.now().toUtc();
  cipher.revisionDate ??= cipher.creationDate;
  return cipher;
}

/// Bitwarden's CipherWithIdExport, as its individual vault export writes it.
Map<String, dynamic> _exportItem(Item item) {
  // A cipher saved by `create` may carry the ids of a Bitwarden account.
  final ids = {
    'id': item.id,
    'organizationId': null,
    'folderId': null,
    'collectionIds': null,
  };
  return {...ids, ...item.cipher.toJson(), ...ids}..remove('key');
}
