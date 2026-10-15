## 0.2.0

- File attachments in `Cipher.attachments`, as Bitwarden stores them with the SHA-256 of the encrypted file in place of a URL. `encryptAttachment()` encrypts a file with AES-256-GCM under a key of its own, and `decryptAttachment()` opens it.
- The vault's Blossom servers (BUD-03), its private servers encrypted to the vault, kept on its relays with the rest of the vault. `Vault.currentServerList()` gives the list to change, `defaultVaultBlossomServers` while it has none, and `ServerList.withServer()` and `without()` change it. `parseServerUrl()` reads a server address as a user types it.
- `SembastVersionStore` keeps the versions of a `VersionCache` in a sembast database.
- `compareItemsByName()` orders items as a list shows them.
- `itemsForUrl()` gives the logins for a web page, and `uriMatches()` tells whether a login URI matches it, by its match detection as in Bitwarden. The base domain, the default, is read with the Public Suffix List, its private domains included.
- `encryptVaultKey()` encrypts a vault key with a password (NIP-49), of `minVaultKeyPasswordLength` characters at least, for the user to keep anywhere.
- Email addresses held by items. `generateMailbox()` makes a mailbox at a nostr-mail bridge, `mailboxesOf()` finds those an item holds, and `publishMailboxLists()` publishes its relay lists, signed by its own key. `parseMailBridge()` reads a bridge's domain as a user types it.
- `Mailbox` reads the emails (nostr-mail, kind 1301) and the private messages (NIP-17) of a mailbox, live while it is open, without storing anything decrypted. `download()` fetches a large email from Blossom, and `delete()` deletes the gift wrap of a message, which the mailbox key may do although a random key signed it (NIP-59). `Email.mime` is the whole message, as a `.eml` file holds it, and `htmlToText()` gives an HTML email as the text a reader sees.
- The defaults a client gives a vault and a new mailbox, in `defaultVaultRelays`, `defaultIndexerRelays`, `defaultMailBridge`, `defaultMailboxRelays`, `defaultMailboxInboxRelays` and `defaultMailboxBlossomServers`.

## 0.1.0

- First release.
- Vault items are NIP-59 gift wraps carrying Bitwarden's cipher JSON. Each version names the versions it replaces, and concurrent edits are kept as heads.
- Writes are done once saved in the ndk cache, and sent to the relays afterwards.
- Sync with NIP-42 authentication, and a live subscription to what other devices publish.
- `Vault.reconcile()` reads the whole vault from each relay, then sends each relay what it lacks, once every relay answered.
- `Vault.forget()` removes a vault from the device, and its relays keep it.
- Trash, restore and permanent deletion (NIP-09).
- The vault's relay list (NIP-65), its private relays encrypted to the vault. The vault lives on the relays it names.
- `Vault.currentRelayList()` gives the list to change, and `RelayList.withRelay()` and `without()` change it. `parseRelayUrl()` reads a relay address as a user types it.
- Bitwarden's search, password history, TOTP codes and generator, usernames included. Made-up first names, last names and birth dates for the sites that ask for them.
- Bitwarden JSON exports, password protected or not, read by `parseBitwardenExport()` and `decryptBitwardenExport()`, and written by `writeBitwardenExport()` and `encryptBitwardenExport()`.
- Vault keys as an nsec, in hex, or encrypted with a password (NIP-49). A vault takes any `EventSigner`, so a NIP-46 bunker or a NIP-07 extension can hold its key. `vaultSignerPermissions` lists what to ask a bunker for.
- `VersionCache` keeps the versions a vault opened, encrypted, so that its signer opens each gift wrap once per device. Its key stays on the device, or is sealed for the signer with `sealCacheKey()`. `Vault.openedItems()` and `Vault.open()` show the items without waiting for the signer.
- `PasswordProtectedKey` protects a `SymmetricCryptoKey` with a password, as Bitwarden protects the user key of an account, for a client to lock what it keeps on the device. `KdfConfig` derives keys with Argon2id, as native code or WebAssembly (`serverpod_argon2`), or with PBKDF2-SHA256.
