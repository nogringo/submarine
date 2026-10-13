---
description: How Submarine protects your passwords. They are encrypted on your devices, kept on open servers that only see encrypted data, and opened by a key that only you hold.
---

# How Submarine protects your passwords

Submarine encrypts your vault on your devices, before anything leaves them. The servers that keep it only ever see encrypted data, and there is no Submarine account or Submarine server in between. This page explains what is protected, how, and what is not done yet.

## Your vault key

Each vault has its own key, made on your device when you create the vault. Whoever holds this key can open the vault, and nobody else can: not the servers, not us.

- Submarine shows you the key when you create the vault. Keep it somewhere safe, such as on paper or in a password manager you already use.
- You can also keep it encrypted with a password of your choice. You then need both the encrypted key and its password to open the vault.
- Nobody can recover a lost key. There is no account and no reset link, so keep a copy of the key, or of the encrypted key and its password.

## On your devices

- Your vaults are encrypted on each device, with a key of that device.
- Your lock password protects that key. Submarine turns it into a key with Argon2id, a method designed to make guessing passwords slow and costly. A forgotten lock password cannot be recovered either: you then open your vaults again with their keys.
- Your fingerprint, face or screen lock can unlock Submarine instead of the lock password.
- Submarine locks itself after a delay you choose, from right away to a few hours, and clears your vaults from memory when it locks.
- Copied passwords are cleared from the clipboard after a delay you choose.
- On Android, screenshots and screen recordings of Submarine are blocked unless you allow them.

## On the servers

Your vaults are kept on Nostr relays: open servers run by independent operators, which anyone can use or run. Each vault is copied to several relays, so it survives if one of them goes down, and you choose which relays keep it, your own included.

Each change you make is encrypted on your device and sent to the relays in a sealed envelope. A relay sees:

- encrypted data that it cannot read,
- the public key of the vault, which tells it which envelopes go together, but not what they hold,
- a date picked at random in the two days before the change, rather than the time of the change,
- your IP address, like any website you visit.

A relay cannot change your passwords either. Each change is signed with the vault key, and Submarine ignores anything the vault did not sign.

## No account, no tracking

- There is no Submarine account, and no Submarine server holds your data.
- Submarine has no analytics, no crash reporting and no ads.
- The code is open source under the MIT license, so anyone can check what Submarine does. [See the source code](https://github.com/nogringo/submarine).

## Not done yet

No independent firm has audited Submarine's security yet. Until one does, keep your most critical passwords, like your email and bank, in a password manager with a longer track record, and start with the rest.

If you find a security problem, please [report it](https://github.com/nogringo/submarine/issues) or [contact us on Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).

## Technical details

The full format is described in the [Nostr Passwords protocol](https://openspecs.uid.ovh/spec/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te/nostr-passwords).

- A vault is a Nostr key pair. Its key is shown as an `nsec`, and its encrypted form is a NIP-49 `ncryptsec` (scrypt, then XChaCha20-Poly1305).
- Each change is a new version of the item: an event signed by the vault, encrypted to the vault with NIP-44 (ChaCha20 and HMAC-SHA256, padded to hide the exact length) and put in a NIP-59 gift wrap, signed by a one-time key and dated at random in the two previous days.
- Items are Bitwarden items, which is why Submarine imports and exports Bitwarden's format.
- On a device, the vault keys are encrypted with AES-256-CBC and HMAC-SHA256 under a device key. That key is protected by the lock password through Argon2id, or kept in the system's secure storage. The local copy of the vaults is encrypted with AES-256-GCM.
- If you use Nostr, a signer can hold the vault key so that it never enters Submarine: a bunker (NIP-46), a signer app such as Amber (NIP-55) or a browser extension (NIP-07).
