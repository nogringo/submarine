import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart' as cryptography;
import 'package:ndk/ndk.dart';

import 'envelope.dart';

/// Where a [VersionCache] keeps its entries, already encrypted, by gift wrap
/// id.
abstract interface class VersionStore {
  Future<Map<String, String>> read();

  Future<void> write(Map<String, String> entries);

  Future<void> remove(Iterable<String> wrapIds);
}

/// The versions a vault opened, kept on the device so that its signer opens
/// each gift wrap once rather than at each start. Encrypted with AES-256-GCM,
/// under a key from [newCacheKey].
class VersionCache {
  /// [key] is kept on the device, as safely as a vault key.
  VersionCache(this.store, String key)
    : _key = key,
      _sealedKey = null,
      _signer = null;

  /// [sealedKey], from [sealCacheKey], waits for [unlock]: until [signer]
  /// opens it, the vault shows nothing, even what it opened before.
  VersionCache.sealed(this.store, String sealedKey, EventSigner signer)
    : _sealedKey = sealedKey,
      _signer = signer;

  final VersionStore store;
  final String? _sealedKey;
  final EventSigner? _signer;
  String? _key;
  Future<bool>? _unlocking;

  /// Whether the signer has yet to open the sealed key.
  bool get locked => _key == null;

  /// The key, null while [locked].
  String? get key => _key;

  /// Asks the signer to open the sealed key, unless it did. Returns whether it
  /// did.
  Future<bool> unlock() async {
    if (!locked) return true;
    return _unlocking ??= _unseal().whenComplete(() => _unlocking = null);
  }

  Future<bool> _unseal() async {
    final key = await unsealCacheKey(_sealedKey!, _signer!);
    if (key != null) _key = key;
    return key != null;
  }

  /// The versions in [store], by gift wrap id.
  Future<Map<String, Envelope>> read() async {
    final key = _secretKey();
    final versions = <String, Envelope>{};
    for (final MapEntry(key: wrapId, value: entry)
        in (await store.read()).entries) {
      if (await _decrypt(wrapId, entry, key) case final version?) {
        versions[wrapId] = version;
      }
    }
    return versions;
  }

  Future<void> write(Map<String, Envelope> versions) async {
    final key = _secretKey();
    await store.write({
      for (final MapEntry(key: wrapId, value: version) in versions.entries)
        wrapId: await _encrypt(wrapId, version, key),
    });
  }

  Future<void> remove(Iterable<String> wrapIds) => store.remove(wrapIds);

  cryptography.SecretKey _secretKey() {
    if (_key case final key?) return cryptography.SecretKey(base64Decode(key));
    throw const CacheLockedException();
  }

  Future<String> _encrypt(
    String wrapId,
    Envelope version,
    cryptography.SecretKey key,
  ) async {
    final box = await _aes.encrypt(
      utf8.encode(jsonEncode(version)),
      secretKey: key,
      // Ties the entry to its gift wrap.
      aad: utf8.encode(wrapId),
    );
    return base64Encode(box.concatenation());
  }

  Future<Envelope?> _decrypt(
    String wrapId,
    String entry,
    cryptography.SecretKey key,
  ) async {
    try {
      final box = cryptography.SecretBox.fromConcatenation(
        base64Decode(entry),
        nonceLength: _aes.nonceLength,
        macLength: _aes.macAlgorithm.macLength,
      );
      final clear = await _aes.decrypt(
        box,
        secretKey: key,
        aad: utf8.encode(wrapId),
      );
      return Envelope.fromJson(jsonDecode(utf8.decode(clear)));
    } catch (_) {
      // Written under another key: the vault opens the gift wrap again.
      return null;
    }
  }
}

/// What a vault cannot do while its [VersionCache] is locked.
class CacheLockedException implements Exception {
  const CacheLockedException();

  @override
  String toString() =>
      'CacheLockedException: the signer has yet to open the cache key';
}

final _aes = cryptography.AesGcm.with256bits();

final _random = Random.secure();

/// A new key for a [VersionCache].
String newCacheKey() =>
    base64Encode([for (var i = 0; i < 32; i++) _random.nextInt(256)]);

/// [key] encrypted by [signer] to the vault itself (NIP-44), for
/// [VersionCache.sealed].
Future<String> sealCacheKey(String key, EventSigner signer) async {
  final sealed = await signer.encryptNip44(
    plaintext: key,
    recipientPubKey: signer.getPublicKey(),
  );
  if (sealed == null) throw StateError('The signer did not encrypt the key');
  return sealed;
}

/// The key [sealCacheKey] sealed, or null when [signer] does not open it.
Future<String?> unsealCacheKey(String sealedKey, EventSigner signer) async {
  try {
    final key = await signer.decryptNip44(
      ciphertext: sealedKey,
      senderPubKey: signer.getPublicKey(),
    );
    return key != null && base64Decode(key).length == 32 ? key : null;
  } catch (_) {
    // Refused, out of reach, or not a key.
    return null;
  }
}
