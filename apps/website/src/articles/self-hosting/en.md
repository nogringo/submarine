---
description: "Keep a copy of your vaults on servers you run yourself: a Nostr relay for your vaults, and a file server for their attachments."
---

# Run your own servers

Submarine has no server of its own: by default, your vaults are copied to public Nostr relays run by independent operators. Add servers you run yourself, and a copy of your vault stays on them for as long as you decide.

## What you need

- A machine reachable from the internet, such as a rented server or a computer at home.
- A domain name pointing to it, with HTTPS.
- Docker, to install the two servers below.

## 1. Install a relay

Install [nostr-relay](https://github.com/nogringo/nostr-relay) by following its instructions. Unlike most relays, it hands a vault's data only to whoever holds the vault key, and lets you delete it.

Put an HTTPS proxy in front of it that forwards the original Host header: the relay needs it to check that Submarine holds the vault key.

Its address starts with `wss://`, for example `wss://relay.example.com`.

## 2. Install a file server

The files attached to your items are kept on file servers, not on relays. To keep your own copy of them too, install [blossom-server](https://github.com/hzrd149/blossom-server) by following its instructions.

In its configuration file, set `rules: []` under `storage`. The example configuration deletes any file nobody has opened for a week, which would delete your attachments.

Its address starts with `https://`, for example `https://blossom.example.com`.

## 3. Add them to your vault

1. Open the vault's settings and, under **Sync**, open **Relays**.
2. Press **Add a relay**, enter your relay's address, turn on **Keep private**, and press **Add**.
3. Press **Save**.
4. Back in the vault's settings, open **File servers**, and add your file server the same way with **Add a server**.

Repeat for each of your vaults. **Keep private** encrypts the address in the vault: otherwise anyone could see that this vault is kept on your server, and guess whose vault it is.

## Keep a few public relays

Keep some public relays next to yours: if your server goes down or loses its data, your vault is still on them. Each of your devices also keeps its own copy.
