# NIP-XX

## Password manager

`draft` `optional`

This NIP defines a standard for storing secrets.

## Templates

### Secret

```jsonc
{
    "id": "<random id>", // for versioning
    "title": "<secrettitle>",
    "fields": ["<field 1>", "<field 2>", "<field 3>", "..."],
    "urls": ["<website url>"],
    "note": "<note content>"
}
```

### Fields

#### Text

```jsonc
{
    "name": "<field name>",
    "kind": "text",
    "value": "<visible text>"
}
```

#### Secret text

Same as [Text](#text), but the client `MUST` hide the value.

```jsonc
{
    "name": "<field name>",
    "kind": "secret",
    "value": "<field value>"
}
```

#### OTP

```jsonc
{
    "name": "OTP",
    "kind": "otp",
    "value": {
        "type": "<totp|hotp>",
        "secret": "<otp secret>",
        "algorithm": "<SHA1|SHA256|SHA512>",
        "digits": 6,
        "period": 30,
        "counter": 0,
    }
}
```

## Sending to relays

The content must be json stringified and then encrypted using [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md).

```jsonc
{
    "kind": 4111,
    "content": "nip44.encrypt(JSON.stringify(<secret>))"
}
```

## Secret sharing

To share a secret you must add a "p" tag with the recipient pubkey and you must encrypt the content using [NIP-44](https://github.com/nostr-protocol/nips/blob/master/44.md) and his pubkey.

```jsonc
{
    "kind": 4111,
    "tags": [
        ["p", "<recipient pubkey>"],
    ],
    "content": "nip44.encrypt(JSON.stringify(<secret>), <recipient pubkey>)"
}
```

## Delete a secret

Use [NIP-09](https://github.com/nostr-protocol/nips/blob/master/09.md) to delete a secret.

## Example

### Create a secret

```jsonc
{
    "id": "XkjfyZQEJvsy2Fkz",
    "title": "Github",
    "fields": [
        {
            "name": "Name",
            "kind": "text",
            "value": "Bob"
        },
        {
            "name": "Email",
            "kind": "text",
            "value": "bob@nostr-mail.com"
        },
        {
            "name": "Password",
            "kind": "secret",
            "value": "=[s8p!Nd#KCX6(@r"
        },
        {
            "name": "OTP",
            "kind": "otp",
            "value": {
                "type": "totp",
                "secret": "JBSWY3DPEHPK3PXP",
                "algorithm": "SHA1",
                "digits": 6,
                "period": 30
            }
        }
    ],
    "note": "My main github account"
}
```

### Update a secret

```jsonc
{
    "id": "XkjfyZQEJvsy2Fkz", // keep the same id
    "title": "Github",
    "urls": ["https://github.com"], // update
    "fields": [
        {
            "name": "Name",
            "kind": "text",
            "value": "Bob"
        },
        {
            "name": "Email",
            "kind": "text",
            "value": "bob@nostr-mail.com"
        },
        {
            "name": "Password",
            "kind": "secret",
            "value": "=[s8p!Nd#KCX6(@r"
        },
        {
            "name": "OTP",
            "kind": "otp",
            "value": {
                "type": "totp",
                "secret": "JBSWY3DPEHPK3PXP",
                "algorithm": "SHA1",
                "digits": 6,
                "period": 30
            }
        }
    ],
    "note": "My github account" // update
}
```
