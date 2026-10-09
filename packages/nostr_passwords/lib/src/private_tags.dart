import 'dart:convert';

import 'package:ndk/ndk.dart';

/// [tags] encrypted to [vault], for the content of a list of its own, as
/// NIP-51 does for private items. Empty without tags.
Future<String> encryptPrivateTags(
  List<List<String>> tags,
  EventSigner vault,
) async {
  if (tags.isEmpty) return '';
  final content = await vault.encryptNip44(
    plaintext: jsonEncode(tags),
    recipientPubKey: vault.getPublicKey(),
  );
  return content ?? (throw StateError('Cannot encrypt the private items'));
}

/// The tags [encryptPrivateTags] put in the content of [list].
Future<List<dynamic>> decryptPrivateTags(
  Nip01Event list,
  EventSigner vault,
) async {
  if (list.content.isEmpty) return const [];
  final plaintext = await vault.decryptNip44(
    ciphertext: list.content,
    senderPubKey: vault.getPublicKey(),
  );
  if (plaintext == null) {
    throw FormatException('Cannot decrypt the private items of ${list.id}');
  }
  return jsonDecode(plaintext) as List;
}
