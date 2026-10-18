---
description: "Keep a copy of your vaults, and those of the people close to you, on servers you run: a Nostr relay for the vaults, and a file server for their attachments."
---

# Run servers for yourself and the people close to you

Submarine has no server of its own: by default, your vaults are copied to public Nostr relays run by independent operators. You can add servers run by you, or by someone you trust: a copy of your vault then stays with people you know.

## For you and the people close to you

One server can keep the vaults of everyone around you: give them its address, and they add it to their vaults as in step 3.

- If you stop your server, they lose nothing: their vaults are still on their other relays, and on each of their devices.
- Your server only sees encrypted data: it can neither read their passwords nor change them. Like any relay, it sees their IP address.
- If a friend runs a server too, add each other's: each of you keeps a copy for the other.

## What you need

- A machine reachable from the internet, such as a rented server or a computer at home.
- A domain name pointing to it, with HTTPS.
- Docker, to install the two servers below.

## 1. Install a relay

Install [nostr-relay](https://github.com/nogringo/nostr-relay) by following its instructions. Unlike most relays, it hands a vault's data only to whoever holds the vault key, and lets you delete it.

Put an HTTPS proxy in front of it that forwards the original Host header: the relay needs it to check that Submarine holds the vault key.

Its address starts with `wss://`, for example `wss://relay.example.com`.

## 2. Install a file server

The files attached to your items are kept on file servers, not on relays. To keep a copy of them too, install [blossom-server](https://github.com/hzrd149/blossom-server) by following its instructions.

In its configuration file, add this rule at the top of the rules under `storage`:

```yaml
- type: application/octet-stream
  expiration: 100 years
```

Submarine's encrypted files are then kept. Without this rule, the example configuration deletes any file nobody has opened for a week.

Its address starts with `https://`, for example `https://blossom.example.com`.

## 3. Add them to your vault

1. Open the vault's settings and, under **Sync**, open **Relays**.
2. Press **Add a relay**, enter your relay's address, turn on **Keep private**, and press **Add**.
3. Press **Save**.
4. Back in the vault's settings, open **File servers**, and add your file server the same way with **Add a server**.

Repeat for each of your vaults. **Keep private** encrypts the address in the vault: otherwise anyone could see that this vault is kept on your server, and guess whose vault it is.

## Keep a few public relays

Keep some public relays next to yours: if your server goes down or loses its data, your vault is still on them. Each of your devices also keeps its own copy.
