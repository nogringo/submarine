import 'dart:convert';
import 'dart:math';

import 'bitwarden_crypto.dart';
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
  final key = await KdfConfig.fromJson(json).deriveKey(password, salt);
  if (await key.decryptString(validation) == null) {
    throw const WrongExportPasswordException();
  }
  return await key.decryptString(data) ??
      (throw const FormatException('The export is damaged.'));
}

/// [export], as [writeBitwardenExport] writes it, protected by [password] as
/// Bitwarden protects its exports, which Bitwarden imports.
Future<String> encryptBitwardenExport(
  String export,
  String password, {
  KdfConfig kdf = const KdfConfig.argon2id(),
}) async {
  if (!kdf.isAllowed) {
    throw ArgumentError.value(kdf, 'kdf', 'Not allowed by Bitwarden');
  }
  final salt = base64.encode(_randomBytes(16));
  final key = await kdf.deriveKey(password, salt);
  return _encoder.convert({
    'encrypted': true,
    'passwordProtected': true,
    'salt': salt,
    ...kdf.toJson(),
    // Any value: an importer only checks that it decrypts.
    'encKeyValidation_DO_NOT_EDIT': await key.encryptString(
      base64.encode(_randomBytes(16)),
    ),
    'data': await key.encryptString(export),
  });
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
