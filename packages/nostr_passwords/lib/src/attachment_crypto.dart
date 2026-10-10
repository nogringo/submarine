import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as cryptography;

import 'cipher/attachment.dart';

/// Encrypts [file] under a key created for it only, for an attachment named
/// [fileName]. Returns the attachment for the item, and the encrypted file for
/// the vault's Blossom servers: the nonce, the cipher text, then the tag.
Future<(Attachment, Uint8List)> encryptAttachment(
  String fileName,
  List<int> file,
) async {
  final key = await _aes.newSecretKey();
  final encrypted = (await _aes.encrypt(file, secretKey: key)).concatenation();
  return (
    Attachment(
      id: _randomId(),
      fileName: fileName,
      key: base64Encode(await key.extractBytes()),
      size: '${encrypted.length}',
      sha256: sha256.convert(encrypted).toString(),
    ),
    encrypted,
  );
}

/// The file of [attachment], from its [encrypted] file. Null when [encrypted]
/// is not that file, or the attachment's key is not a key.
Future<List<int>?> decryptAttachment(
  Attachment attachment,
  List<int> encrypted,
) async {
  try {
    return await _aes.decrypt(
      cryptography.SecretBox.fromConcatenation(
        encrypted,
        nonceLength: _aes.nonceLength,
        macLength: _aes.macAlgorithm.macLength,
      ),
      secretKey: cryptography.SecretKey(base64Decode(attachment.key)),
    );
  } catch (_) {
    return null;
  }
}

final _aes = cryptography.AesGcm.with256bits();

final _random = Random.secure();

String _randomId() => [
  for (var i = 0; i < 16; i++)
    _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();
