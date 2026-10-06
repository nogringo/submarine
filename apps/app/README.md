# Submarine app

Flutter app for Submarine, a password manager built on [Nostr](https://nostr.how/). It runs on Android, iOS, macOS, Windows, Linux and the web.

> **Status:** early development. Do not trust it with real passwords yet.

## Features

- **Vaults.** A vault is a Nostr account. Create one, or open one on as many devices as you like, with its key (an nsec, in hex, or an ncryptsec and its password) or through a signer that keeps the key out of the app: a browser extension (NIP-07) on the web, a bunker (NIP-46) everywhere, a signer app such as Amber (NIP-55) on Android. Each device gives its vaults its own names and colors.
- **Items.** Logins, cards and secure notes can be created and edited. The other Bitwarden item types (identities, SSH keys, bank accounts, driver's licenses and passports) are shown but not editable yet.
- **Search and filters.** Search works as in Bitwarden, ignoring case and accents. Filters narrow the list to a type, the favorites or the trash.
- **Trash.** Items move to the trash, come back out of it, or are deleted for good.
- **Generator.** Passwords and passphrases with Bitwarden's options and defaults. It opens with the options used last.
- **Verification codes.** The TOTP code of a login, with the time it has left.
- **Import and export.** Imports a JSON export from Bitwarden into the vault of your choice, and exports a vault in that format, which Bitwarden imports. Both ways, the file can be protected by a password as Bitwarden does it, and is by default. As in Bitwarden, the export leaves the trash out. Bitwarden exports restricted to their account cannot be imported, and folders are dropped.
- **Sync.** A change is saved on the device first, then sent to the relays. What other devices publish shows up the moment they publish it, and the vault settings show what was not sent yet.
- **Lock.** Optional: the device's biometrics or screen lock, after a delay you choose.
- **Languages.** English and French.

## Platforms

| Platform | Vault keys stored in | Lock |
| --- | --- | --- |
| Android | Storage encrypted with a Keystore key | Biometrics or screen lock |
| iOS | Keychain | Face ID, Touch ID or passcode |
| macOS | Data protection keychain | Touch ID or password |
| Windows | Files encrypted for the user account (DPAPI) | Windows Hello |
| Linux | Keyring, through libsecret | None |
| Web | localStorage, next to the key that encrypts them | None |

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

### Translations

The strings live in [`lib/l10n`](lib/l10n): `app_en.arb` is the template, with a description of each string, and `app_fr.arb` the French translation. To add a language, add an `app_<code>.arb` file next to them. After any change, regenerate the Dart files, which are committed:

```sh
flutter gen-l10n
```

## License

[MIT](../../LICENSE)
