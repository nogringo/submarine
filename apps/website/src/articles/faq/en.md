---
description: Answers to common questions about Submarine, the password manager with no account. A lost key, a server going down, offline use, sharing a vault, and what it costs.
---

# Questions and answers

## What if I lose my vault key?

Nobody can recover it, not even us: there is no account and no reset link. If Submarine is still open on one of your devices, copy the key from the vault's settings and keep it somewhere safe. Otherwise, the vault cannot be opened again.

## What if a server shuts down?

Each vault is copied to several relays, and each of your devices keeps its own copy. If a relay goes down, the others still have your vault. You can add or remove relays in the vault's settings, under Sync.

## Who runs the servers?

Nostr relays are run by independent operators, for every app that uses Nostr, not just Submarine. They only see encrypted data. You can also run your own relay and add it to your vault.

## Does Submarine work offline?

Yes. Every change is saved on your device first, and synced once you are back online. Submarine shows how many changes are still waiting to be sent.

## Can I use it on several devices?

Yes: on Android, Windows, macOS and Linux, and on the web for every other device. Open your vault on each of them with the same key. [Download Submarine](/download).

## Can I share a vault?

Yes. Give the vault key to the person you share it with: whoever has it can open and change the vault. A key cannot be taken back once given, so keep shared passwords in a vault of their own, apart from your personal ones.

## What if I edit the same item on two devices at once?

Both edits are kept. Submarine never silently overwrites one with the other.

## Is Submarine free?

Yes. There is nothing to pay, no premium version and no ads. Submarine is open source, under the MIT license.

## How is it different from other password managers?

With most password managers, your vault lives on the servers of the company that makes them, behind an account. Submarine has no account and no server of its own: your vault is copied to open servers that you choose, and only your key opens it. The other side of this is that nobody can recover a lost key. Submarine is also younger, and not audited yet.

## Can I import my passwords?

Yes, from Bitwarden, and from most other password managers through Bitwarden. [Import from Bitwarden](/import-bitwarden). You can export your vaults at any time, in a format other password managers can import.

## Is Submarine secure?

Your vault is encrypted on your devices, and the servers only see encrypted data. No independent firm has audited Submarine yet, though. [How Submarine protects your passwords](/security).

## What is Nostr?

An open protocol for exchanging data through relays: servers that anyone can run. Submarine uses it to sync your vault without a company in the middle. You do not need to know Nostr, or to have a Nostr account, to use Submarine.

## How do I report a problem?

[Report it on GitHub](https://github.com/nogringo/submarine/issues), or [contact us on Nostr](https://njump.me/npub1kg4sdvz3l4fr99n2jdz2vdxe2mpacva87hkdetv76ywacsfq5leqquw5te).
