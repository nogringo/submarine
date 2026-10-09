## Set the vault's relays

NIP-65 relay list, signed by the vault and published as is:

```jsonc
{
  "kind": 10002,
  "pubkey": "<pk_vault>",
  "created_at": 1790676000,
  "tags": [
    ["r", "wss://relay.primal.net"],
    ["r", "wss://relay.nos.social", "read"]
  ],
  "content": "<nip44_encrypt(sk_vault, pk_vault, private relays)>",
  "sig": "..."
}
```

Private relays, the `content` once decrypted, in the same tag format, as NIP-51 does for private list items:

```jsonc
[
  ["r", "wss://relay.alice.example"]
]
```

Anyone can read the public relays in the tags. Only the vault key decrypts the private ones. The vault reads and writes on every relay. It keeps the `read` and `write` markers for other clients, without using them. The event is replaceable, so its `created_at` is the real time, not a random one as for gift wraps: relays keep the newest list.

## Create a password

Gift wrap, the only event published:

```jsonc
{
  "kind": 1059,
  "pubkey": "<one-time key>",
  "created_at": "<random time in the last two days>",
  "tags": [["p", "<pk_vault>"]],
  "content": "<nip44_encrypt(one-time key, pk_vault, version event)>",
  "sig": "..."
}
```

Version event, inside the wrap:

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

Envelope, the version event's `content`:

```jsonc
{
  "v": 1,
  "id": "<item id>",
  "type": "item",
  "rev": "<revision id>",
  "parents": [],
  "modified_at": 1790762400000,
  "data": {
    "type": 1,
    "name": "GitHub",
    "notes": "Personal account",
    "favorite": false,
    "reprompt": 0,
    "folderId": null,
    "fields": [],
    "login": {
      "uris": [{ "uri": "https://github.com", "match": null }],
      "username": "alice@example.com",
      "password": "]vY$qff.p)iq4y-zDRrg",
      "totp": "otpauth://totp/GitHub:alice?secret=JBSWY3DPEHPK3PXP&issuer=GitHub",
      "fido2Credentials": []
    },
    "passwordHistory": [],
    "creationDate": "2026-09-30T10:00:00.000Z",
    "revisionDate": "2026-09-30T10:00:00.000Z",
    "deletedDate": null
  }
}
```

## Move a password to the trash

A new version of the item, wrapped and published like the first one. Its envelope names the current version as parent (every head, if there is a conflict) and sets `deletedDate`:

```jsonc
{
  "v": 1,
  "id": "<item id>",
  "type": "item",
  "rev": "<new revision id>",
  "parents": ["<current revision id>"],
  "modified_at": 1790848800000,
  "data": {
    // the rest of the item, unchanged
    "revisionDate": "2026-10-01T10:00:00.000Z",
    "deletedDate": "2026-10-01T10:00:00.000Z"
  }
}
```

## Restore a password

Another version, which clears `deletedDate`:

```jsonc
{
  "v": 1,
  "id": "<item id>",
  "type": "item",
  "rev": "<new revision id>",
  "parents": ["<revision id of the trashed version>"],
  "modified_at": 1790935200000,
  "data": {
    // the rest of the item, unchanged
    "revisionDate": "2026-10-02T10:00:00.000Z",
    "deletedDate": null
  }
}
```

## Delete a password permanently

A NIP-09 deletion request for each gift wrap of the item, one per version:

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

It names the gift wrap, the only event relays hold. The gift wrap is signed by a one-time key, but NIP-59 has relays delete a `kind:1059` whose `p` tag matches the signer of the deletion request, here the vault. One request per gift wrap, with a random `created_at` as for gift wraps, keeps the requests from tying the versions of an item together.

Other devices fetch the vault's `kind:5` events when they sync, and drop the gift wraps they name from their cache.

## Give a password an email address

The item holds the private key of its mailbox, a key created for this address only, in a hidden field. The address is that key's npub at a [nostr-mail](https://github.com/nogringo/nostr-mail) bridge:

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

An item has a mailbox when a hidden field holds an nsec and the item holds the address `<npub of that nsec>@<domain>`: as the username, in a field, or as the identity's `email`. The field's name does not matter. The key ties the item to its mailbox, so the tie survives a Bitwarden export, a translated label or a renamed field. The address is required so that an nsec the user keeps in the vault for their own Nostr account is not taken for a mailbox.

A key per address keeps the addresses of a vault from being tied together, keeps email spam out of the vault's events, and lets the client decrypt emails locally, without the vault's signer.
