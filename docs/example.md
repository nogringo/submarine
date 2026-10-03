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
