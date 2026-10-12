# Store listing

What the Chrome Web Store and Firefox Add-ons show of the extension, and what their dashboards ask for, all entered by hand. `pnpm screenshots` takes the images of this folder again.

## Name and summary

The manifest gives both: "Submarine Password Manager", and the app's tagline in its 11 languages, "Your passwords, encrypted and synced. No account needed." in English.

## Description

```text
Submarine keeps your passwords, cards and notes safe and in sync across your devices, with no account to create. This extension brings your vaults into your browser.

- Open your vaults with their key, the one the Submarine app gave you when you created them.
- See the logins for the site you are on first.
- Search your logins, cards, notes and identities, across all your vaults.
- Copy a username, a password or a two-factor code in one click. Copied passwords are cleared from the clipboard after a delay.
- Open it from the keyboard with Ctrl+Shift+Y (Command+Shift+Y on a Mac, Ctrl+Shift+U on Linux).
- Lock the extension with a password, by itself after the delay you choose.
- In 11 languages: English, Chinese, Finnish, French, German, Italian, Japanese, Portuguese (Brazil and Portugal), Russian and Spanish.

Everything is encrypted before it is synced, so nobody but you can read it, not even us. Your vaults live on Nostr relays: open servers that anyone can run, and that only see encrypted data.

This first version shows your vaults: create and edit your items in the Submarine app, at https://github.com/nogringo/submarine. It does not fill in forms on websites yet.

Free and open source. No ads, no tracking.

Submarine is still young. For your most important passwords, we still recommend a proven password manager.
```

## Category and links

- Category: Privacy & Security, in both stores.
- Homepage and support: https://github.com/nogringo/submarine and its issues, until submarine.li serves a site.
- Privacy policy: https://github.com/nogringo/submarine/blob/main/apps/extension/PRIVACY.md

## Images

- `screenshot-1.png` to `screenshot-4.png`, 1280 by 800, in both stores.
- `promo-tile.png`, 440 by 280: the small promo tile the Chrome Web Store requires.

## Chrome Web Store privacy

- Single purpose: shows the user's Submarine password vaults and copies their items.
- `storage`: keeps the vault keys, an encrypted copy of their items and the settings in the browser.
- `clipboardWrite`: copies a username, a password, a code or another field when the user asks.
- `alarms`: locks the vaults once the lock delay chosen by the user has passed.
- `activeTab`: reads the address of the tab the popup opens over, to show the logins for that site first.
- `offscreen`: empties the clipboard after the delay chosen by the user, which the background service worker cannot do.
- Remote code: none.
- Data collected, as declared to Firefox for the complete extension: personally identifiable information, financial and payment information, authentication information, personal communications and web history. None is sold, used for anything but the extension's purpose, or used to determine creditworthiness.

## Firefox Add-ons review notes

```text
The background runs a core written in Dart, compiled to JavaScript (core.js). The sources archive holds it, and SOURCE_CODE_REVIEW.md at its root explains how to rebuild the extension identically.

To try the extension, create a vault in the Submarine web app, https://nogringo.github.io/submarine/, copy its key from the vault's settings, then open it in the extension.
```
