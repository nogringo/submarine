# Source code review

How to build the Submarine browser extension for Firefox from these sources, as submitted to Firefox Add-ons.

The extension, in `apps/extension`, is written in TypeScript with [WXT](https://wxt.dev) and React. Its background runs a core written in Dart, `apps/extension/core`, compiled to JavaScript by `dart compile js` into `core.js`. The core depends on `packages/nostr_passwords`, in a Dart workspace shared with the Submarine app and CLI: their `pubspec.yaml` files are here because pub resolves the whole workspace. The popup's texts are the app's translations, in `apps/app/lib/l10n`.

## Requirements

- Flutter 3.47.6, which includes Dart 3.13.5, from the [Flutter SDK archive](https://docs.flutter.dev/install/archive). The workspace holds the Flutter app, so pub needs Flutter, even though the extension only uses Dart.
- Node.js 24.
- pnpm 11.18.0: `npm install -g pnpm@11.18.0`.

## Build

From the root of these sources:

```sh
flutter pub get --enforce-lockfile
cd apps/extension
pnpm install --frozen-lockfile
pnpm zip:firefox
```

`pnpm zip:firefox` compiles the Dart core into `public/core.js`, builds the extension into `.output/firefox-mv3`, then zips it into `.output/submarine-extension-<version>-firefox.zip`.

`dart compile js` also writes a source map, `core.js.map`, left out of the zip: it names the Dart sources by their path from the pub cache, which differs from one machine to another.
