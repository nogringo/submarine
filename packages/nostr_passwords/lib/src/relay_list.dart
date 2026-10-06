import 'dart:convert';

import 'package:ndk/domain_layer/entities/nip_65.dart';
import 'package:ndk/domain_layer/entities/read_write_marker.dart';
import 'package:ndk/ndk.dart';

export 'package:ndk/domain_layer/entities/read_write_marker.dart';

/// A vault's relays, in a NIP-65 relay list: the public ones in the tags, the
/// private ones encrypted to the vault in the content, as NIP-51 does for
/// private items.
///
/// The vault reads and writes on every relay: it keeps their marker for other
/// clients only.
class RelayList {
  const RelayList({this.public = const {}, this.private = const {}});

  final Map<String, ReadWriteMarker> public;
  final Map<String, ReadWriteMarker> private;
}

/// Relays a client gives a vault by default.
const defaultRelays = [
  'wss://relay.nmail.li',
  'wss://relay.primal.net',
  'wss://relay.nos.social',
  'wss://relay.coinos.io',
  'wss://relay.ditto.pub',
  'wss://auth.nostr1.com',
  'wss://chat.wisp.talk',
  'wss://relay.nostrfeed.com',
  'wss://relay.nostr.com',
  'wss://nostr.oxtr.dev',
  'wss://nostr.bitcoiner.social',
  'wss://nostr.data.haus',
  'wss://purplerelay.com',
  'wss://relay.nostr.wirednet.jp',
  'wss://nip17.com',
];

/// Relays that keep anyone's relay list, where others look for the vault's.
const indexerRelays = [
  'wss://purplepag.es',
  'wss://user.kindpag.es',
  'wss://indexer.coracle.social',
];

/// [createdAt] is now by default.
Future<Nip01Event> signRelayList(
  RelayList list,
  EventSigner vault, {
  int? createdAt,
}) async {
  final pubkey = vault.getPublicKey();
  final content = list.private.isEmpty
      ? ''
      : await vault.encryptNip44(
          plaintext: jsonEncode(_tags(list.private)),
          recipientPubKey: pubkey,
        );
  if (content == null) throw StateError('Cannot encrypt the private relays');
  return vault.sign(
    Nip01Event(
      pubKey: pubkey,
      kind: Nip65.kKind,
      tags: _tags(list.public),
      content: content,
      createdAt: createdAt ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
    ),
  );
}

Future<RelayList> readRelayList(Nip01Event event, EventSigner vault) async {
  final pubkey = vault.getPublicKey();
  if (event.kind != Nip65.kKind || event.pubKey != pubkey) {
    throw FormatException('Event ${event.id} is not a relay list of the vault');
  }
  var private = <String, ReadWriteMarker>{};
  if (event.content.isNotEmpty) {
    final plaintext = await vault.decryptNip44(
      ciphertext: event.content,
      senderPubKey: pubkey,
    );
    if (plaintext == null) {
      throw FormatException('Cannot decrypt the private relays of ${event.id}');
    }
    private = _relays(jsonDecode(plaintext) as List);
  }
  return RelayList(public: _relays(event.tags), private: private);
}

List<List<String>> _tags(Map<String, ReadWriteMarker> relays) => [
  for (final MapEntry(key: relay, value: marker) in relays.entries)
    switch (marker) {
      ReadWriteMarker.readOnly => ['r', relay, 'read'],
      ReadWriteMarker.writeOnly => ['r', relay, 'write'],
      ReadWriteMarker.readWrite => ['r', relay],
    },
];

Map<String, ReadWriteMarker> _relays(List<dynamic> tags) => {
  for (final tag in tags)
    if (tag case ['r', final String relay, ...final marker])
      relay: switch (marker) {
        ['read', ...] => ReadWriteMarker.readOnly,
        ['write', ...] => ReadWriteMarker.writeOnly,
        _ => ReadWriteMarker.readWrite,
      },
};
