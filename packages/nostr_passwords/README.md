# nostr_passwords

Reference Dart implementation of a password manager protocol built on [Nostr](https://nostr.how/). It powers [Submarine](../..), but carries no Submarine branding so that any client can use it.

> **Status:** young. The protocol may still change before 1.0.0.

The protocol is specified in [`docs`](../../docs).

## Features

- **Bitwarden items.** An item's data is Bitwarden's cipher JSON: logins, secure notes, cards, identities, SSH keys, bank accounts, driver's licenses and passports.
- **Private on relays.** Each version of an item is an event signed by the vault key and gift wrapped to that same key (NIP-59). Relays see a one-time key, the vault's public key and a randomized date, never the content.
- **History and conflicts.** A version names the versions it replaces. Edits made concurrently on several devices are all kept as the item's heads, and the next edit resolves them.
- **Local first.** A change is done once it is saved in the ndk cache. ndk sends it to the relays afterwards, and the vault lists what no relay accepted yet.
- **Opened once per device.** The vault can keep the versions its signer opened, encrypted with AES-256-GCM, so that a start asks the signer only for what is new rather than for every gift wrap, which matters with a remote signer (NIP-46). The cache key stays on the device, or is sealed for the signer alone (NIP-44), which then opens it once at each start. The items opened before show without waiting for the signer.
- **Sync.** Keeps the vault synced from its relays with [`sync_engine_shim_for_ndk`](https://pub.dev/packages/sync_engine_shim_for_ndk), and authenticates as the vault (NIP-42) to relays that serve gift wraps to their recipient only. A live subscription brings in what other devices publish the moment they do.
- **Reconciliation.** Reads every event of the vault from each of its relays, a page at a time, then gives the cache and each relay what it lacks, such as what a relay dropped over time. Nothing is sent before every relay answered, so a gift wrap deleted on one relay does not spread to the others. A relay that did not give everything it holds gets nothing, and is reported with the reason.
- **Relay list.** The vault's relays are a NIP-65 relay list signed by the vault: the public ones in clear, the private ones encrypted to the vault, as NIP-51 does for private items. It goes as wide as it can, to the relays the vault starts on, to the relays it lists and to well-known indexers, and is fetched from there apart from the sync of the items. Once it has a list, the vault lives on the relays it names, and the relays a new list adds get a copy of the vault.
- **Server list.** The vault's Blossom servers are a BUD-03 server list signed by the vault, its private servers encrypted to the vault as for the relay list. It lives on the vault's relays and comes with the sync. Until the vault has one, it uses the servers it starts on, `defaultVaultBlossomServers` by default.
- **File attachments.** A file attached to an item is encrypted with AES-256-GCM under a key of its own, which the item holds with the file's name, size and SHA-256, its address on Blossom.
- **Trash and deletion.** Items go to the trash and come back out of it, as in Bitwarden. Deleting one permanently asks the relays to delete each of its gift wraps (NIP-09).
- **Bitwarden behavior.** Password history, search, TOTP codes and the generator work as in Bitwarden: the last 5 replaced passwords are kept, search ignores case and accents, TOTP keys can be base32 secrets, `otpauth://` or `steam://` URIs, and passwords, passphrases and usernames are generated with Bitwarden's options and defaults.
- **Made-up personal details.** For the sites that ask for a name or a birth date: common English first names and surnames, from US public domain data, and the birth date of someone from 18 to 60 years old, as an ISO date.
- **Bitwarden import and export.** Reads Bitwarden's JSON export as Bitwarden's importer does, and writes items in that format, which Bitwarden imports. Both ways, the file can be password protected as Bitwarden does it: a key derived with PBKDF2-SHA256 or Argon2id, AES-256-CBC and HMAC-SHA256. Exports restricted to a Bitwarden account are refused, and folders are dropped.
- **Password lock.** A client can keep what it stores on the device under a `SymmetricCryptoKey` protected by a password, as Bitwarden protects the user key of an account with its master password: Argon2id with Bitwarden's defaults (or PBKDF2-SHA256), AES-256-CBC and HMAC-SHA256. Argon2id runs as native code, and as WebAssembly on the web, through [`serverpod_argon2`](https://pub.dev/packages/serverpod_argon2).

## Getting started

A `Vault` needs:

- an `Ndk` instance with a persistent cache: the cache is where the vault lives on the device;
- the vault's `EventSigner`, also added to `ndk.accounts` so that sync can authenticate as the vault;
- the relays the vault starts on, `defaultVaultRelays` for instance, until it has a relay list;
- optionally, a `VersionCache` over a `VersionStore` of the app, for the signer to open each gift wrap once per device.

To sync, it also needs a `SyncEngine` and a `SyncStore` from `sync_engine_shim_for_ndk`.

## Usage

```dart
final vault = Vault(
  ndk: ndk,
  signer: signer,
  relays: ['wss://relay.primal.net'],
);

await vault.createItem(
  Cipher(
    type: CipherType.login,
    name: 'Boulanger',
    login: Login(
      uris: [LoginUri('https://www.boulanger.com')],
      username: 'alice@example.com',
      password: 'correct horse battery staple',
    ),
  ),
);

final items = await vault.items();
for (final item in searchItems(items, 'boulanger')) {
  print('${item.cipher.name}: ${item.cipher.subtitle}');
}
```

[`example/nostr_passwords_example.dart`](example/nostr_passwords_example.dart) goes through the whole flow: setup, password lock, relay list, sync, generate a password and made-up details, Bitwarden import and export, attach a file, edit, trash, restore and permanent deletion.

## License

[MIT](../../LICENSE)
