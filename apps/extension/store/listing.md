# Store listing

What the Chrome Web Store and Firefox Add-ons show of the extension, and what their dashboards ask for, all entered by hand. `pnpm screenshots` takes the images of this folder again.

## Name and summary

The manifest gives both: "Submarine Password Manager", and the app's tagline in its 11 languages, "Your passwords, encrypted and synced. No account needed." in English.

## Description

```text
Submarine keeps your passwords, cards and notes safe and in sync across your devices, with no account to create. This extension brings your vaults into your browser.

- Create your vaults, or open those you already have with their key.
- See the logins for the site you are on first, and fill one into the page in one click, or with Alt+Shift+L (Ctrl+Shift+L in Firefox, Control+Shift+L on a Mac).
- Search your logins, cards, notes and identities, across all your vaults, or filter them: favorites, each type, the trash.
- Create and edit your logins, cards and notes, with custom fields. Generate strong passwords, passphrases and usernames as you fill them in.
- Give a login an email address of its own, and read the emails it receives, such as sign-up codes and confirmation links, right in the login.
- Mark your favorites, move items to the trash and restore them, from an item or with a right click on it.
- Import your passwords from a Bitwarden export, and export a vault to a file Bitwarden opens.
- Copy a username, a password or a two-factor code in one click. Copied passwords are cleared from the clipboard after a delay.
- Open it from the keyboard with Ctrl+Shift+Y (Command+Shift+Y on a Mac, Ctrl+Shift+U on Linux).
- Lock the extension with a password, by itself after the delay you choose.

Everything is encrypted before it is synced, so nobody but you can read it, not even us. Your vaults live on Nostr relays: open servers that anyone can run, and that only see encrypted data.

Get the Submarine app for your other devices at https://github.com/nogringo/submarine.

Free and open source. No ads, no tracking.

No independent firm has audited Submarine's security yet. Until one does, keep your most important passwords in a proven password manager.
```

## Category and links

- Category: Privacy & Security, in both stores.
- Homepage and support: https://github.com/nogringo/submarine and its issues, until submarine.li serves a site.
- Privacy policy: https://github.com/nogringo/submarine/blob/main/apps/extension/PRIVACY.md

## Images

- `screenshot-1.png` to `screenshot-4.png`, 1280 by 800, in both stores.
- `promo-tile.png`, 440 by 280: the small promo tile the Chrome Web Store requires.

## Chrome Web Store privacy

- Single purpose: shows and edits the user's Submarine password vaults, copies their items, fills their logins into websites, and shows the emails sent to the email addresses of their logins.
- `storage`: keeps the vault keys, an encrypted copy of their items and of the messages of their email addresses, the settings, and an item form left unsaved until the extension locks, in the browser.
- `clipboardWrite`: copies a username, a password, a code or another field when the user asks, and the verification code of a login filled into a page.
- `alarms`: locks the vaults once the lock delay chosen by the user has passed.
- `activeTab`: the tab the popup or the keyboard shortcut acts on: its address, to show the logins for that site first, and its page, to fill a login when the user asks.
- `scripting`: fills a login into the page of that tab, when the user asks from the popup or with the keyboard shortcut.
- `offscreen`: copies the verification code of a login filled from the keyboard shortcut or the popup, which closes once filled, and empties the clipboard after the delay chosen by the user. The background service worker can do neither.
- Remote code: none.
- Data collected, as declared to Firefox for the complete extension: personally identifiable information, financial and payment information, authentication information, personal communications and web history. None is sold, used for anything but the extension's purpose, or used to determine creditworthiness.

## Firefox Add-ons review notes

```text
The background runs a core written in Dart, compiled to JavaScript (core.js). The sources archive holds it, and SOURCE_CODE_REVIEW.md at its root explains how to rebuild the extension identically.

To try the extension, create a vault from its welcome screen.
```
