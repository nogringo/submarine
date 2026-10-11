# Submarine app

Flutter app for Submarine, a password manager built on [Nostr](https://nostr.how/). It runs on Android, iOS, macOS, Windows, Linux and the web.

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="screenshots/desktop-dark.png">
  <img alt="Submarine on a desktop: three vaults, the items of all of them, and a login with its verification code" src="screenshots/desktop-light.png">
</picture>

> **Status:** young but ready to use. For your most important passwords, we still recommend a proven password manager such as [KeePassXC](https://keepassxc.org/).

## Features

- **Vaults.** A vault is a Nostr account. Create one, or open one on as many devices as you like, with its key (an nsec, in hex, or an ncryptsec and its password) or through a signer that keeps the key out of the app: a browser extension (NIP-07) on the web, a bunker (NIP-46) everywhere, a signer app such as Amber (NIP-55) on Android. A new vault gives its key encrypted with a password you choose (an ncryptsec, NIP-49), to keep anywhere since only that password opens it, and its settings export it again. Each device gives its vaults its own names and colors. A vault can be removed from a device in its settings, and stays online to be opened again.
- **Items.** Logins, cards and secure notes can be created and edited, with custom fields as in Bitwarden: text, hidden, checkbox or linked, renamed, deleted and reordered by dragging. The other Bitwarden item types (identities, SSH keys, bank accounts, driver's licenses and passports) are shown but not editable yet.
- **Email addresses.** A login can get an email address of its own, at the bridge picked in the settings (`uid.ovh` by default). The item holds the key of its mailbox, and shows its inbox while it is open: the emails and private messages (NIP-17) sent to that address. Nothing decrypted is stored.
- **Search and filters.** Search works as in Bitwarden, ignoring case and accents. Filters narrow the list to a type, the favorites or the trash.
- **Trash.** Items move to the trash, come back out of it, or are deleted for good.
- **Generator.** Passwords, passphrases and usernames with Bitwarden's options and defaults. It opens with the options used last. On a login, the username field opens it on usernames, and "Add a field" offers a first name, a last name and a birth date filled with made-up values.
- **Verification codes.** The TOTP code of a login, with a ring showing the time it has left, red just before it expires.
- **Import and export.** Imports a JSON export from Bitwarden into the vault of your choice, and exports a vault in that format, which Bitwarden imports. Both ways, the file can be protected by a password as Bitwarden does it, and is by default. As in Bitwarden, the export leaves the trash out. Bitwarden exports restricted to their account cannot be imported, and folders are dropped.
- **Sync.** A change is saved on the device first, then sent to the relays. What other devices publish shows up the moment they publish it, and the vault settings show what was not sent yet. They also list the vault's relays and file servers (Blossom), on pages of their own, and run a full sync, which reads the whole vault on every relay and gives each one what it lacks.
- **Lock.** Optional. A lock password encrypts the vault keys on the device and unlocks the app. It cannot be recovered: forgetting it removes the vaults from the device. Where the device can check its user, biometrics or its screen lock unlock the app too, with or without a lock password. The app locks after a delay you choose, on restart, or with Ctrl+L (⌘L on Apple devices), and locking closes the vaults.
- **Clipboard.** Copied passwords are cleared from the clipboard after a delay you choose, as in Bitwarden.
- **Screen capture.** On Android, screenshots, recordings and screen sharing of the app are blocked unless the settings allow them, and the app is hidden in recent apps.
- **Appearance.** The system, light or dark theme.
- **Accessibility.** Every control is named for screen readers, and every screen stays whole with text twice as large.
- **Languages.** English, French, German, Spanish, Italian, Portuguese (Portugal and Brazil), Finnish, Russian, Japanese and Chinese. The app follows the device's language, or the one picked in the settings.

## Platforms

| Platform | Vault keys stored in | Unlocked by |
| --- | --- | --- |
| Android | Storage encrypted with a Keystore key | Lock password, biometrics or screen lock |
| iOS | Keychain | Lock password, Face ID, Touch ID or passcode |
| macOS | Data protection keychain | Lock password, Touch ID or the Mac's password |
| Windows | Files encrypted for the user account (DPAPI) | Lock password or Windows Hello |
| Linux | Keyring, through libsecret | Lock password |
| Web | localStorage, next to the key that encrypts them | Lock password |

The vaults, keys included, are saved encrypted under a key of the device, as Bitwarden encrypts a vault under the user key. A lock password protects that key with Argon2id, as Bitwarden's master password protects the user key. Without one, or with biometrics on, that key is kept as is in the storage above. On the web, only a lock password truly protects the vault keys, since localStorage keeps them next to the key that encrypts them.

A vault opened through a signer leaves its key there: the device stores how to reach the signer, and for a bunker the key it signs its requests with. The signer decrypts each version of an item once per device, which a bunker does over the network, one round trip each. The device keeps what was decrypted, encrypted with a key stored next to the vault keys, so that a later start only asks the signer for what is new, and shows the rest even while the signer is out of reach. In the vault settings, the signer can hold that key instead: it then opens the vault at each launch, and the vault stays closed until it does. When a signer has left requests unanswered for 2 seconds, a button in the rail, or a bar at the bottom of a phone screen, lists what it waits for and lets you cancel it. A signer that approves by itself, such as a bunker set to accept everything, keeps answering within that time and shows nothing.

On Android, the vault keys stay out of backups and device transfers, as another device could not decrypt them. Keep your vault keys: on a new phone, they are the only way to open your vaults again.

On Linux, the app needs libsecret and a keyring service, such as GNOME Keyring or KWallet.

On the web, the app only works over HTTPS or on localhost.

## Development

Get the dependencies from the repository root first, as the [root README](../../README.md) explains. Then, from this directory:

```sh
flutter run
flutter test
```

The macOS and iOS builds are signed, because the keychain requires an Apple development team. Pick yours under Signing & Capabilities of the Runner target in Xcode.

Building on Linux needs the libsecret headers: `libsecret-1-dev` on Debian and Ubuntu, `libsecret-devel` on Fedora.

### Screenshots

The screenshots of the READMEs, in [`screenshots`](screenshots), are rendered by a test from made-up vaults, in the light and dark themes. Render them again after a change to the screens they show:

```sh
flutter test tool/screenshots_test.dart
```

### Translations

The strings live in [`lib/l10n`](lib/l10n): `app_en.arb` is the template, with a description of each string, and the other `app_<code>.arb` files its translations. To add a language, add an `app_<code>.arb` file next to them. After any change, regenerate the Dart files, which are committed:

```sh
flutter gen-l10n
```

## License

[MIT](../../LICENSE)
