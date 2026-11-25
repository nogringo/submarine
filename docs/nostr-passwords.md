# Nostr Passwords

This document defines a password manager on Nostr. A vault is a Nostr key pair, `sk_vault` and `pk_vault`. Its items are Bitwarden ciphers, and each change to an item is a new version gift wrapped to the vault.

## Item versions

A version is an event of `kind:21270` signed by the vault, whose `created_at` is the envelope's `modified_at` in seconds:

```jsonc
{
  "kind": 21270,
  "pubkey": "<pk_vault>",
  "created_at": 1790762400,
  "tags": [["-"]],
  "content": "<envelope JSON>",
  "sig": "..."
}
```

It goes in a NIP-59 gift wrap to the vault, in place of a seal, and only the gift wrap is published:

```jsonc
{
  "kind": 1059,
  "pubkey": "<one-time key>",
  "created_at": "<random time in the two days before the version's created_at>",
  "tags": [["p", "<pk_vault>"]],
  "content": "<nip44_encrypt(one-time key, pk_vault, version)>",
  "sig": "..."
}
```

## Envelope

The `content` of a version:

```jsonc
{
  "v": 1,
  "id": "<item id>",
  "type": "item",
  "rev": "<revision id>",
  "parents": ["<revision id of the version it replaces>"],
  "modified_at": 1790762400000,
  "data": {
    // the item
  }
}
```

- `v` is the version of the envelope's format, `1` in this document.
- `id` is the item's id, random, the same in all its versions.
- `type` is what the version describes. This document defines `item` only.
- `rev` is the id of this version, random.
- `parents` holds the `rev` of the versions this one replaces. It is empty in an item's first version.
- `modified_at` is when this version was made, in milliseconds since the Unix epoch.
- `data` is the item.

## Item data

`data` is a Bitwarden cipher, as Bitwarden's [JSON export](https://bitwarden.com/help/condition-bitwarden-import/) writes an item, without `id`, `organizationId`, `collectionIds` and `key`.

A client MUST keep the keys of `data` it does not know, at any depth, when it writes a new version of the item.

## Trash

Moving an item to the trash is a new version that sets `deletedDate`. Restoring it is a new version that sets `deletedDate` back to `null`.

## Permanent deletion

Deleting an item permanently is a NIP-09 deletion request for each gift wrap of the item:

```jsonc
{
  "kind": 5,
  "pubkey": "<pk_vault>",
  "created_at": "<random time in the last two days>",
  "tags": [
    ["e", "<gift wrap id>"],
    ["k", "1059"]
  ],
  "content": "",
  "sig": "..."
}
```

## Relay list

The vault's relays are a NIP-65 relay list signed by the vault, its private relays encrypted to the vault in `content`, in the same tag format, as NIP-51 does for private items:

```jsonc
{
  "kind": 10002,
  "pubkey": "<pk_vault>",
  "created_at": 1790676000,
  "tags": [
    ["r", "wss://relay.primal.net"],
    ["r", "wss://relay.nos.social", "read"]
  ],
  "content": "<nip44_encrypt(sk_vault, pk_vault, [[\"r\", \"wss://relay.alice.example\"]])>",
  "sig": "..."
}
```

## Server list

The vault's Blossom servers are a BUD-03 server list (`kind:10063`) signed by the vault, its private servers encrypted to the vault as in the relay list.

## Attachments

A file attached to an item is encrypted and stored on the vault's servers:

```jsonc
"attachments": [
  {
    "id": "<attachment id>",
    "fileName": "passport.pdf",
    "key": "<base64 of a 32-byte key>",
    "size": "482113",
    "sha256": "<sha256 of the encrypted file>"
  }
]
```

The fields are those Bitwarden stores for an attachment, with `sha256` in place of its `url`. A client finds the file on the vault's servers by its `sha256`.

The file is encrypted with AES-256-GCM under `key`, a key for this file only. The encrypted file is the 12-byte nonce, then the ciphertext, then the 16-byte tag. `size` is its size in bytes, as a string.

The encrypted file is uploaded as `application/octet-stream`.

## Email addresses

An item can have an email address, a [nostr-mail](https://github.com/nogringo/nostr-mail) mailbox. The item holds the private key of its mailbox, a key for this address only, in a hidden field. The address is that key's npub at a nostr-mail bridge:

```jsonc
"data": {
  // the rest of the item
  "login": {
    // the rest of the login
    "username": "npub1mbx...@bridge.example"
  },
  "fields": [
    { "name": "Mailbox key", "value": "nsec1...", "type": 1, "linkedId": null }
  ]
}
```

An item has a mailbox when a hidden field holds an nsec and the item holds the address `<npub of that nsec>@<domain>`: as the username, in a field, or as the identity's `email`. The field's name does not matter.

## Vault deletion

Deleting the vault is a NIP-62 request to vanish from all relays, signed by the vault, sent to every relay of the vault:

```jsonc
{
  "kind": 62,
  "pubkey": "<pk_vault>",
  "created_at": 1790762400,
  "tags": [["relay", "ALL_RELAYS"]],
  "content": "",
  "sig": "..."
}
```

Relays delete the events the vault signed and, as NIP-59 asks, the gift wraps whose `p` tag is the vault: every version of every item. `created_at` is the time of the request, as relays delete what is older. A relay that takes relay lists only, such as an indexer, gets an empty relay list of the vault instead.

A client MAY delete the mailboxes of the vault's items the same way, each signed by its own key and sent to the relays of its lists.
