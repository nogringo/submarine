# Submarine

Submarine is a password manager built on [Nostr](https://nostr.how/).

> **Status:** early development. Do not trust it with real passwords yet.

## Repository layout

This repository is a Dart [pub workspace](https://dart.dev/go/pub-workspaces).

| Path | Package | Description |
| --- | --- | --- |
| [`packages/nostr_passwords`](packages/nostr_passwords) | `nostr_passwords` | Reference Dart implementation of the protocol, reusable by any client. |
| [`apps/app`](apps/app) | `submarine` | Flutter app for Android, iOS, macOS, Windows, Linux and web. |
| [`apps/cli`](apps/cli) | `submarine_cli` | Command-line client. |

The protocol specification will live in its own repository.

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
dart run apps/cli/bin/submarine_cli.dart --help
```

Analyze the whole workspace from the root:

```sh
flutter analyze
```

Run the tests from a package directory: `dart test` for Dart packages, `flutter test` for the Flutter app.

## Contributing

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org). Use the package as scope when a change targets one: `feat(cli): ...`, `fix(app): ...`, `docs(nostr_passwords): ...`.

## License

[MIT](LICENSE)
