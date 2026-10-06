import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/domain_layer/usecases/nip42/auth_event.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip01/helpers.dart';
import 'package:ndk/shared/nips/nip09/deletion.dart';
import 'package:nip49/nip49.dart';

import 'version_event.dart';

/// What a vault asks of a remote signer holding its key (NIP-46 `perms`): to
/// sign its versions, deletion requests, relay list and relay authentications,
/// and to encrypt to itself.
const vaultSignerPermissions = [
  'sign_event:$versionEventKind',
  'sign_event:${Deletion.kKind}',
  'sign_event:${Nip65.kKind}',
  'sign_event:${AuthEvent.KIND}',
  'nip44_encrypt',
  'nip44_decrypt',
];

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// The private key, in hex, of a vault key written as an nsec or in hex.
/// Returns null for anything else, an npub included.
String? parseVaultKey(String text) {
  final value = text.trim().toLowerCase();
  // Nip19.decode decodes an npub too, and returns '' when it fails.
  final key = value.startsWith('nsec1') ? Nip19.decode(value) : value;
  return _hexKey.hasMatch(key) ? key : null;
}

/// Whether [text] is a vault key encrypted with a password (NIP-49), an
/// ncryptsec for [decryptVaultKey].
bool isEncryptedVaultKey(String text) {
  final value = text.trim().toLowerCase();
  if (!value.startsWith('${Nip49.hrp}1')) return false;
  final [data, hrp] = Helpers.decodeBech32(value);
  // Version 2, then log_n, salt, nonce, key security byte, key and tag.
  return hrp == Nip49.hrp && data.length == 91 * 2 && data.startsWith('02');
}

/// The private key, in hex, of [ncryptsec], a vault key encrypted with
/// [password] (NIP-49). Returns null when the password is wrong.
///
/// Slow on purpose: scrypt makes each guess of the password costly.
Future<String?> decryptVaultKey(String ncryptsec, String password) async {
  try {
    return await Nip49.decrypt(ncryptsec.trim().toLowerCase(), password);
  } on ArgumentError {
    return null;
  }
}
