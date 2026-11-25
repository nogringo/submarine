import 'dart:math';

import 'package:ndk/domain_layer/entities/broadcast_state.dart'
    show RelayBroadcastResponse;
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
/// Both are saved in the ndk cache first. Returns once the relays answered,
/// with those that did not accept and why, which ndk keeps sending to.
Future<Map<String, String>> requestToVanish(
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
  Future<List<RelayBroadcastResponse>> send(
    Nip01Event event,
    Iterable<String> to,
  ) async {
    // Without explicit relays, ndk would send to its bootstrap relays.
    if (to.isEmpty) return const [];
    await ndk.config.cache.saveEvent(event);
    return ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: to,
          saveToCache: false,
          auth: auth,
        )
        .broadcastDoneFuture;
  }

  final responses = await Future.wait([
    send(request, relays),
    send(emptyList, indexers),
  ]);
  return {
    for (final response in responses.expand((responses) => responses))
      if (!response.broadcastSuccessful)
        response.relayUrl: response.msg.isEmpty ? 'no answer' : response.msg,
  };
}
