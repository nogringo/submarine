import 'dart:math';

import 'package:ndk/ndk.dart';
import 'package:sync_engine_shim_for_ndk/sync_engine_shim_for_ndk.dart';

import 'cipher/cipher.dart';
import 'envelope.dart';
import 'item.dart';
import 'version_event.dart';

class Vault {
  Vault({required this.ndk, required this.signer, required this.relays});

  final Ndk ndk;
  final EventSigner signer;
  final List<String> relays;

  /// Decrypted on demand and kept in memory only: ndk's own decrypted payload
  /// cache would write the passwords to disk in clear.
  final _versions = <String, Envelope>{};

  /// Keeps the vault's gift wraps synced from [relays] into the ndk cache.
  ///
  /// Some relays serve gift wraps to their recipient only, so this
  /// authenticates as the vault (NIP-42): [signer] must be in `ndk.accounts`.
  SyncHandle sync(SyncEngine engine) => engine.ensure(
    SyncRequest(
      filters: [
        Filter(
          kinds: [GiftWrap.kGiftWrapEventkind],
          pTags: [signer.getPublicKey()],
        ),
      ],
      relays: relays,
      authPubkey: signer.getPublicKey(),
    ),
  );

  /// Items found in the ndk cache, see [sync] to fill it.
  Future<List<Item>> items() async {
    final wraps = await ndk.config.cache.loadEvents(
      kinds: [GiftWrap.kGiftWrapEventkind],
      tags: {
        'p': [signer.getPublicKey()],
      },
    );
    final versions = <Envelope>[];
    for (final wrap in wraps) {
      if (await _open(wrap) case final version?) versions.add(version);
    }
    return resolveItems(versions);
  }

  Future<Envelope> createItem(Cipher cipher) async {
    final envelope = Envelope(
      id: _randomId(),
      type: 'item',
      rev: _randomId(),
      parents: const [],
      modifiedAt: DateTime.now().toUtc(),
      data: cipher.toJson(),
    );
    await _publish(envelope);
    return envelope;
  }

  Future<Envelope?> _open(Nip01Event wrap) async {
    if (_versions[wrap.id] case final version?) return version;
    try {
      return _versions[wrap.id] = await unwrapEnvelope(
        wrap,
        signer,
        verifier: ndk.config.eventVerifier,
      );
    } catch (_) {
      // Anyone can send a wrap to the vault: one that does not open is skipped.
      return null;
    }
  }

  Future<void> _publish(Envelope envelope) async {
    final wrap = await wrapEnvelope(envelope, signer);
    final responses = await ndk.broadcast
        .broadcast(
          nostrEvent: wrap,
          specificRelays: relays,
          // Without it, a relay asking for AUTH would see the logged account.
          auth: AuthPolicy.allow(
            Account(
              type: AccountType.externalSigner,
              pubkey: signer.getPublicKey(),
              signer: signer,
            ),
          ),
        )
        .broadcastDoneFuture;
    if (!responses.any((response) => response.broadcastSuccessful)) {
      throw PublishException(envelope, {
        for (final response in responses) response.relayUrl: response.msg,
      });
    }
  }
}

class PublishException implements Exception {
  PublishException(this.envelope, this.relayMessages);

  final Envelope envelope;
  final Map<String, String> relayMessages;

  @override
  String toString() =>
      'PublishException: no relay accepted rev ${envelope.rev} of ${envelope.id}';
}

final _random = Random.secure();

String _randomId() => [
  for (var i = 0; i < 16; i++)
    _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
].join();
