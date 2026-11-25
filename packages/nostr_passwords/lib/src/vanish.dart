import 'dart:math';

import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/ndk.dart';

import 'relay_list.dart';

/// NIP-62's request to vanish.
const vanishKind = 62;

/// Asks every relay to delete the events of [signer] and the gift wraps sent
/// to it (NIP-62, NIP-59): a request for all relays, sent to [relays]. The
/// [indexers], which take a NIP-65 list only, get an empty one in place of the
/// one they hold.
///
/// Both are saved in the ndk cache first. Returns once the relays answered, and
/// ndk keeps sending to those that did not.
Future<void> requestToVanish(
  Ndk ndk,
  EventSigner signer, {
  required Iterable<String> relays,
  required Iterable<String> indexers,
  required AuthPolicy auth,
}) async {
  final pubkey = signer.getPublicKey();
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final request = await signer.sign(
    Nip01Event(
      pubKey: pubkey,
      kind: vanishKind,
      tags: [
        ['relay', 'ALL_RELAYS'],
      ],
      content: '',
      // Relays delete what is older than the request.
      createdAt: now,
    ),
  );
  final previous = (await ndk.config.cache.loadEvents(
    kinds: [Nip65.kKind],
    pubKeys: [pubkey],
  )).firstOrNull;
  final emptyList = await signRelayList(
    const RelayList(),
    signer,
    createdAt: max(now, (previous?.createdAt ?? 0) + 1),
  );
  Future<void> send(Nip01Event event, Iterable<String> to) async {
    // Without explicit relays, ndk would send to its bootstrap relays.
    if (to.isEmpty) return;
    await ndk.config.cache.saveEvent(event);
    await ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: to,
          saveToCache: false,
          auth: auth,
        )
        .broadcastDoneFuture;
  }

  await Future.wait([send(request, relays), send(emptyList, indexers)]);
}
