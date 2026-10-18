# Privacy policy of the Submarine browser extension

Last updated: October 18, 2026.

Submarine is a password manager. Its browser extension shows the passwords, cards and notes of your vaults, lets you create and edit them, copies them for you, fills your logins into websites, and shows the emails sent to the email addresses you give your logins. This policy explains what the extension does with your data. In short: there is no Submarine server, and the extension sends nothing to its developers.

## What stays in your browser

- The key of each vault you create or open, with the name and color you give it. They are encrypted with a key of this browser, itself protected by your lock password once you set one.
- A copy of your vaults' contents, so that they open without waiting for the network. It is encrypted too.
- The messages of an email address, as they arrived: encrypted to the key of that address. The extension decrypts them each time it shows them, and never stores them decrypted.
- Your settings: the lock delay, the clipboard delay, the options of the password generator, and the email bridge, relays and servers that new email addresses get.
- A form you leave unsaved, so that it shows again when you reopen the extension. It stays in the browser's memory, never on disk, and goes once you save it, discard it, lock the extension or close the browser.

Removing a vault from the extension deletes its key and its copy from your browser. Uninstalling the extension deletes everything it stored.

## What leaves your browser

Your vaults live on Nostr relays: servers run by independent operators, which store data for anyone. Your items are encrypted on your devices before they reach a relay, so relays only hold data they cannot read.

To download your vaults, the extension connects to their relays: the relays each vault lists, or else Submarine's [default relays](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart), and three directory relays where a vault's list of relays is published. Each relay sees your IP address, as any website you visit does, and the public key of each vault you open, with which the extension signs in and asks for that vault's data.

When you create, edit, favorite, trash or restore an item, the extension encrypts its new version on your device and sends it to the relays of its vault. When you delete an item for good, it asks those relays to delete each of its versions. A change that no relay accepted yet waits in the encrypted copy in your browser, and is sent again the next time you open the extension or press its sync button.

The password generator works in your browser: what it generates leaves it only inside an item you save.

When you import a Bitwarden export, the extension reads the file you choose in your browser, then saves its items into the vault you pick, as items you create. When you export a vault, it saves the file to your computer, encrypted with the password you choose, or not encrypted if you turn that off. The file goes nowhere else.

When you ask it to fill a login, from its window or with its keyboard shortcut, the extension writes the username and password into the sign-in form of the current page, and only if the page's address matches the login. The website receives them once you sign in, as when you type them.

## Email addresses

A login can get an email address of its own, such as `npub1...@uid.ovh`, from the menu that adds a field. The extension creates a new key for each address, unrelated to your vaults, and keeps it in a hidden field of the login, encrypted with the rest of the item. The domain is that of an email bridge, `uid.ovh` unless you choose another in the settings: a server run by an independent operator, which receives the emails sent to the address, as any email server does, encrypts them to the address's key and passes them to the address's relays. The extension never sends an email, and never connects to the bridge.

When you save a login with a new email address, the extension publishes three public lists signed with the address's key, so that the bridge knows where to deliver: the relays of the address, sent to those relays and to the three directory relays; the relays its emails arrive on; and the servers that receive the emails too large for a relay. These lists name the address's key and its relays and servers, never your vaults. By default, these are Submarine's [default email relays and servers](https://github.com/nogringo/submarine/blob/main/packages/nostr_passwords/lib/src/defaults.dart); you can change those that new addresses get in the settings.

While a login with an email address shows, the extension connects to that address's relays, found on the directory relays, signs in to them with the address's key, downloads its latest messages, and receives the new ones until you close the login. Each relay sees your IP address and the address's public key. It also receives the private messages (NIP-17) sent to that key. An email too large for a relay is downloaded, encrypted, when you open it, from one of the servers of the address or of the bridge, or else from Submarine's default servers; that server sees your IP address.

When you save an email, the extension writes the whole message, attachments included, to a file on your computer. When you delete a message, it asks the address's relays to delete it. Deleting a login for good does not delete its messages from the relays. A link in a message opens in a new tab only once you confirmed it, after the extension showed where it leads.

## What the extension does not do

- It has no account and no server of its own: its developers receive no data from it.
- It never sends an email, and never shows the pictures or other content an email would load from the web: it shows emails as plain text.
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
