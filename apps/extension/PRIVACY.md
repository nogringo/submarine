# Privacy policy of the Submarine browser extension

Last updated: October 12, 2026.

Submarine is a password manager. Its browser extension shows the passwords, cards and notes of your vaults, and copies them for you. This policy explains what the extension does with your data. In short: there is no Submarine server, and the extension sends nothing to its developers.

## What stays in your browser

- The key of each vault you open, with the name and color you give it. They are encrypted with a key of this browser, itself protected by your lock password once you set one.
- A copy of your vaults' contents, so that they open without waiting for the network. It is encrypted too.
- Your settings: the lock delay and the clipboard delay.

Removing a vault from the extension deletes its key and its copy from your browser. Uninstalling the extension deletes everything it stored.

## What leaves your browser

Your vaults live on Nostr relays: servers run by independent operators, which store data for anyone. Your items are encrypted on your devices before they reach a relay, so relays only hold data they cannot read.

To download your vaults, the extension connects to their relays: the relays each vault lists, or else Submarine's [default relays](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart), and three directory relays where a vault's list of relays is published. Each relay sees your IP address, as any website you visit does, and the public key of each vault you open, with which the extension signs in and asks for that vault's data.

The extension only downloads: it never sends your items, and it creates, changes or deletes nothing on the relays.

## What the extension does not do

- It has no account and no server of its own: its developers receive no data from it.
- It has no analytics, no tracking and no ads.
- It does not read the pages you visit.
- It writes to the clipboard only what you copy, and empties the clipboard after the delay chosen in the settings. It never reads the clipboard.

## Permissions

- Storage: keeps your vaults and settings in your browser, as described above.
- Clipboard write: copies a password, a code or any other field when you ask.
- Alarms: locks the vaults once the lock delay has passed.
- Offscreen documents, in Chrome only: empties the clipboard after the clipboard delay, even with the extension's window closed.

## Changes and contact

This policy changes with the extension. Its history is that of this file in the [Submarine repository](https://github.com/nogringo/submarine). For any question, open an [issue](https://github.com/nogringo/submarine/issues).
