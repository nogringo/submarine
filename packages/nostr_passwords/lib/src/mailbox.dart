import 'package:ndk/ndk.dart';

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
