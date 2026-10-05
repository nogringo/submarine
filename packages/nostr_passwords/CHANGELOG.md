## 0.1.0

- First release.
- Vault items are NIP-59 gift wraps carrying Bitwarden's cipher JSON. Each version names the versions it replaces, and concurrent edits are kept as heads.
- Writes are done once saved in the ndk cache, and sent to the relays afterwards.
- Sync with NIP-42 authentication, and a live subscription to what other devices publish.
- Trash, restore and permanent deletion (NIP-09).
- The vault's relay list (NIP-65), its private relays encrypted to the vault. The vault lives on the relays it names.
- Bitwarden's search, password history, TOTP codes and generator.
