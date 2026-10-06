## 0.1.0

- First release.
- Vault items are NIP-59 gift wraps carrying Bitwarden's cipher JSON. Each version names the versions it replaces, and concurrent edits are kept as heads.
- Writes are done once saved in the ndk cache, and sent to the relays afterwards.
- Sync with NIP-42 authentication, and a live subscription to what other devices publish.
- Trash, restore and permanent deletion (NIP-09).
- The vault's relay list (NIP-65), its private relays encrypted to the vault. The vault lives on the relays it names.
- `Vault.currentRelayList()` gives the list to change, and `RelayList.withRelay()` and `without()` change it. `parseRelayUrl()` reads a relay address as a user types it.
- Bitwarden's search, password history, TOTP codes and generator.
- Vault keys as an nsec, in hex, or encrypted with a password (NIP-49). A vault takes any `EventSigner`, so a NIP-46 bunker or a NIP-07 extension can hold its key. `vaultSignerPermissions` lists what to ask a bunker for.
