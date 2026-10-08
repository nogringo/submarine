# Submarine

Submarine is a password manager built on [Nostr](https://nostr.how/).

> **Status:** young but ready to use. For your most important passwords, we still recommend a proven password manager such as [KeePassXC](https://keepassxc.org/).

## Repository layout

This repository is a Dart [pub workspace](https://dart.dev/go/pub-workspaces).

| Path | Package | Description |
| --- | --- | --- |
| [`packages/nostr_passwords`](packages/nostr_passwords) | `nostr_passwords` | Reference Dart implementation of the protocol, reusable by any client. |
| [`apps/app`](apps/app) | `submarine` | Flutter app for Android, iOS, macOS, Windows, Linux and web. |
| [`apps/cli`](apps/cli) | `submarine_cli` | Command-line client. |

The protocol specification lives in [`docs`](docs).

## Development

Requires Flutter stable with Dart 3.13.4 or later.

Get the dependencies of the whole workspace from the repository root:

```sh
flutter pub get
```

Run the app:

```sh
cd apps/app
flutter run
```

Run the CLI:

```sh
dart run apps/cli/bin/submarine.dart --help
```

Analyze the whole workspace from the root:

```sh
flutter analyze
```

Run the tests from a package directory: `dart test` for Dart packages, `flutter test` for the Flutter app.

## Contributing

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org). Use the package as scope when a change targets one: `feat(cli): ...`, `fix(app): ...`, `docs(nostr_passwords): ...`.

## Releasing

The app, the CLI and `nostr_passwords` share one version, and the tag `v<version>` marks a release, for example `v0.1.0`. Versions below 1.0.0 are pre-releases.

1. Set the version in `apps/app/pubspec.yaml`, `apps/cli/pubspec.yaml`, `apps/cli/lib/src/version.dart` and `packages/nostr_passwords/pubspec.yaml`. In the app, also raise the build number after the `+`: the stores refuse a build number they already have.
2. Add the changes of the version to each `CHANGELOG.md`.
3. Commit as `chore: release <version>`, then tag that commit and push the tag:

```sh
git tag -a v0.1.0 -m "Submarine 0.1.0"
git push origin v0.1.0
```

The tag runs the [release workflow](.github/workflows/release.yml), which builds the app for Linux, Windows, macOS and Android and the CLI, then publishes them in a GitHub release. The macOS package is signed with Developer ID and notarized, from these repository secrets:

- `APPLE_DEVELOPER_ID_APPLICATION_CERTIFICATE_BASE64`: the Developer ID Application certificate with its private key, exported as `.p12`, in base64.
- `APPLE_DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD`: the password of that `.p12`.
- `APPLE_DEVELOPER_ID_PROVISIONING_PROFILE_BASE64`: a Developer ID provisioning profile for `ovh.uid.submarine`, in base64. The keychain entitlement needs it, or macOS does not launch the app.
- `APPLE_ID` and `APPLE_APP_SPECIFIC_PASSWORD`: an Apple ID of the team and one of its app-specific passwords, for the notary service.

The Android APK is signed with the key of alias `submarine`, from these repository secrets:

- `ANDROID_KEYSTORE_BASE64`: the keystore, in base64.
- `ANDROID_KEYSTORE_PASSWORD`: the password of the keystore and of its key.

Create the keystore once, then keep a copy of it and of its password: Android only installs an update signed with the same key.

```sh
keytool -genkeypair -keystore submarine.jks -storetype PKCS12 -keyalg RSA -keysize 4096 -validity 10000 -alias submarine
```

To sign local release builds with it, write `apps/app/android/key.properties` (ignored by git) with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Without that file, release builds use the debug key.

## License

[MIT](LICENSE)
