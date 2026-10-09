import 'package:ndk/ndk.dart';

import 'cipher/cipher.dart';
import 'cipher/field.dart';
import 'mail_bridge.dart';
import 'relay_list.dart';

/// A new mailbox at [bridge]: the nsec of a key made for it alone, for a
/// hidden field of the item, and its address, that key's npub at [bridge].
/// The key comes from [signerFactory], the one the app gives ndk.
({String key, String address}) generateMailbox(
  String bridge, {
  required LocalEventSignerFactory signerFactory,
}) {
  final (privateKey, publicKey) = signerFactory.generateKeyPair();
  return (
    key: Nip19.encodePrivateKey(privateKey),
    address: '${Nip19.encodePubKey(publicKey)}@$bridge',
  );
}

/// The mailboxes [cipher] holds: each nsec of a hidden field whose address,
/// its npub at a bridge, is the username, a field or the identity's email.
List<({String key, String address})> mailboxesOf(
  Cipher cipher, {
  required LocalEventSignerFactory signerFactory,
}) {
  final values = [
    ?cipher.login?.username,
    ?cipher.identity?.email,
    for (final field in cipher.fields) ?field.value,
  ].map((value) => value.trim());
  final mailboxes = <({String key, String address})>[];
  for (final field in cipher.fields) {
    final key = field.value?.trim();
    if (field.type != FieldType.hidden || key == null) continue;
    final npub = _npubOf(key, signerFactory);
    if (npub == null) continue;
    for (final address in values) {
      if (address.startsWith('$npub@') &&
          parseMailBridge(address.substring(npub.length + 1)) != null) {
        mailboxes.add((key: key, address: address));
        break;
      }
    }
  }
  return mailboxes;
}

String? _npubOf(String key, LocalEventSignerFactory signerFactory) {
  if (!key.startsWith('nsec1')) return null;
  try {
    return Nip19.encodePubKey(signerFactory.derivePublicKey(Nip19.decode(key)));
  } catch (_) {
    return null;
  }
}

/// Publishes the relay lists of the mailbox of [key], an nsec, signed by that
/// key: a NIP-65 list of [relays], to them and to [indexers], and a
/// `kind:10050` list of [inboxRelays], the relays its emails arrive on, to
/// [relays]. A bridge finds the first on the indexers, then the second.
///
/// Local first, as a vault: done once the lists are saved in the ndk cache,
/// which then sends them in the background.
Future<void> publishMailboxRelays(
  Ndk ndk,
  String key, {
  required List<String> relays,
  required List<String> inboxRelays,
  List<String> indexers = indexerRelays,
}) async {
  final signer = ndk.config.eventSignerFactory.create(
    privateKey: Nip19.decode(key),
  );
  final relayList = await signRelayList(
    RelayList(
      public: {for (final relay in relays) relay: ReadWriteMarker.readWrite},
    ),
    signer,
  );
  final inboxList = await signer.sign(
    Nip01Event(
      pubKey: signer.getPublicKey(),
      kind: 10050,
      tags: [
        for (final relay in inboxRelays) ['relay', relay],
      ],
      content: '',
    ),
  );
  final account = Account(
    type: AccountType.privateKey,
    pubkey: signer.getPublicKey(),
    signer: signer,
  );
  for (final (event, to) in [
    (relayList, {...relays, ...indexers}),
    (inboxList, relays),
  ]) {
    await ndk.config.cache.saveEvent(event);
    await ndk.broadcast
        .broadcast(
          nostrEvent: event,
          specificRelays: to,
          timeout: Duration.zero,
          saveToCache: false,
          // Without it, a relay asking for AUTH would see the logged account.
          auth: AuthPolicy.allow(account),
        )
        .broadcastDoneFuture;
  }
}

/// Relays a client gives the NIP-65 list of a new mailbox by default, those
/// of the nmail app.
const defaultMailboxRelays = [
  'wss://relay.nmail.li',
  'wss://nostr-01.yakihonne.com',
  'wss://relay.primal.net',
];

/// Relays a client gives the `kind:10050` list of a new mailbox by default,
/// those of the nmail app: the bridge sends the mailbox's emails to them.
const defaultMailboxInboxRelays = [
  'wss://relay.nmail.li',
  'wss://auth.nostr1.com',
];
