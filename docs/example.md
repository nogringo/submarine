## Set the vault's relays

NIP-65 relay list, signed by the vault and published as is:

```jsonc
{
  "kind": 10002,
  "pubkey": "<pk_vault>",
  "created_at": 1790676000,
  "tags": [
    ["r", "wss://relay.primal.net"],
    ["r", "wss://relay.nos.social"]
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

Anyone can read the public relays in the tags. Only the vault key decrypts the private ones. No `read` or `write` marker: the vault reads and writes on every relay. The event is replaceable, so its `created_at` is the real time, not a random one as for gift wraps: relays keep the newest list.

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
