# Privacy policy of the Submarine browser extension

Last updated: October 12, 2026.

Submarine is a password manager. Its browser extension shows the passwords, cards and notes of your vaults, lets you create and edit them, copies them for you, and fills your logins into websites. This policy explains what the extension does with your data. In short: there is no Submarine server, and the extension sends nothing to its developers.

## What stays in your browser

- The key of each vault you open, with the name and color you give it. They are encrypted with a key of this browser, itself protected by your lock password once you set one.
- A copy of your vaults' contents, so that they open without waiting for the network. It is encrypted too.
- Your settings: the lock delay, the clipboard delay and the options of the password generator.
- A form you leave unsaved, so that it shows again when you reopen the extension. It stays in the browser's memory, never on disk, and goes once you save it, discard it, lock the extension or close the browser.

Removing a vault from the extension deletes its key and its copy from your browser. Uninstalling the extension deletes everything it stored.

## What leaves your browser

Your vaults live on Nostr relays: servers run by independent operators, which store data for anyone. Your items are encrypted on your devices before they reach a relay, so relays only hold data they cannot read.

To download your vaults, the extension connects to their relays: the relays each vault lists, or else Submarine's [default relays](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart), and three directory relays where a vault's list of relays is published. Each relay sees your IP address, as any website you visit does, and the public key of each vault you open, with which the extension signs in and asks for that vault's data.

When you create, edit, favorite, trash or restore an item, the extension encrypts its new version on your device and sends it to the relays of its vault. When you delete an item for good, it asks those relays to delete each of its versions. A change that no relay accepted yet waits in the encrypted copy in your browser, and is sent again the next time you open the extension or press its sync button.

The password generator works in your browser: what it generates leaves it only inside an item you save.

When you ask it to fill a login, from its window or with its keyboard shortcut, the extension writes the username and password into the sign-in form of the current page, and only if the page's address matches the login. The website receives them once you sign in, as when you type them.

## What the extension does not do

- It has no account and no server of its own: its developers receive no data from it.
- It has no analytics, no tracking and no ads.
- It reads nothing of the pages you visit, except the fields of the current page when you ask it to fill a login, to find where the username and password go. As you open it, it reads the address of the current tab to show the logins for that site first. Neither leaves your browser.
- It writes to the clipboard only what you copy, and the verification code of a login it fills, then empties the clipboard after the delay chosen in the settings. It never reads the clipboard.

## Permissions

- Storage: keeps your vaults and settings in your browser, as described above.
- Clipboard write: copies a password, a code or any other field when you ask.
- Alarms: locks the vaults once the lock delay has passed.
- Active tab: gives the extension the tab you open it over or use its shortcut on, and only that one: its address, to show the logins for that site first, and its page, to fill a login when you ask.
- Scripting: fills a login into that tab's page when you ask.
- Offscreen documents, in Chrome only: copies the verification code of a login filled, and empties the clipboard after the clipboard delay, even with the extension's window closed.

## Changes and contact

This policy changes with the extension. Its history is that of this file in the [Submarine repository](https://github.com/nogringo/submarine). For any question, open an [issue](https://github.com/nogringo/submarine/issues).
