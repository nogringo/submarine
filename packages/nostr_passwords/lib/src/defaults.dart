/// Relays that keep anyone's relay list, where others look for the vault's.
const defaultIndexerRelays = [
  'wss://purplepag.es',
  'wss://user.kindpag.es',
  'wss://indexer.coracle.social',
];

/// Relays a client gives a vault by default.
const defaultVaultRelays = [
  'wss://relay.nmail.li',
  'wss://relay.primal.net',
  'wss://relay.nos.social',
  'wss://relay.coinos.io',
  'wss://relay.ditto.pub',
  'wss://auth.nostr1.com',
  'wss://relay.nostr.com',
  'wss://nostr.oxtr.dev',
  'wss://nostr.data.haus',
  'wss://purplerelay.com',
  'wss://relay.nostr.wirednet.jp',
];

/// Blossom servers a client gives a vault by default, which take an encrypted
/// file from any key and let it delete the file.
const defaultVaultBlossomServers = [
  'https://blossom.nmail.li',
  'https://blossom.yakihonne.com',
  'https://blossom.ditto.pub',
  'https://nostr.download',
];

/// The nostr-mail bridge a client gives new email addresses by default.
const defaultMailBridge = 'uid.ovh';

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

/// Blossom servers a client gives the `kind:10063` list of a new mailbox by
/// default, where the bridge puts its large emails, and looks for a large email
/// on after those the mailbox and its sender list: the defaults of nostr-mail.
const defaultMailboxBlossomServers = [
  'https://blossom.nmail.li',
  'https://blossom.yakihonne.com',
  'https://blossom.ditto.pub',
];
