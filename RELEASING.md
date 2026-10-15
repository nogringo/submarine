# Releasing

The app, the CLI, the browser extension and `nostr_passwords` share one version, and the tag `v<version>` marks a release, for example `v0.1.0`. Versions below 1.0.0 are pre-releases.

1. Set the version in `apps/app/pubspec.yaml`, `apps/cli/pubspec.yaml`, `apps/cli/lib/src/version.dart`, `apps/extension/package.json` and `packages/nostr_passwords/pubspec.yaml`. In the app, also raise the build number after the `+`: the stores refuse a build number they already have.
2. Add the changes of the version to each `CHANGELOG.md`, and a short plain ASCII version of the app's to `apps/app/fastlane/metadata/android/en-US/changelogs/<build number>.txt`, 500 bytes at most. IzzyOnDroid reads it at the tag.
3. Commit as `chore: release <version>`, then tag that commit and push the tag:

```sh
git tag -a v0.1.0 -m "Submarine 0.1.0"
git push origin v0.1.0
```

The tag runs the [release workflow](.github/workflows/release.yml), which builds the app for Linux, Windows, macOS and Android, the CLI and the browser extension, then publishes them in a GitHub release, and deploys the [website](apps/website) again so that its download page links them. The macOS package is signed with Developer ID and notarized, from these repository secrets:

- `APPLE_DEVELOPER_ID_APPLICATION_CERTIFICATE_BASE64`: the Developer ID Application certificate with its private key, exported as `.p12`, in base64.
- `APPLE_DEVELOPER_ID_APPLICATION_CERTIFICATE_PASSWORD`: the password of that `.p12`.
- `APPLE_DEVELOPER_ID_PROVISIONING_PROFILE_BASE64`: a Developer ID provisioning profile for `ovh.uid.submarine`, in base64. The keychain entitlement needs it, or macOS does not launch the app.
- `APPLE_ID` and `APPLE_APP_SPECIFIC_PASSWORD`: an Apple ID of the team and one of its app-specific passwords, for the notary service.

Android gets a universal APK and an arm64 one, the only architecture Zapstore distributes. Both are signed with the key of alias `submarine`, from these repository secrets:

- `ANDROID_KEYSTORE_BASE64`: the keystore, in base64.
- `ANDROID_KEYSTORE_PASSWORD`: the password of the keystore and of its key.

Create the keystore once, then keep a copy of it and of its password: Android only installs an update signed with the same key.

```sh
keytool -genkeypair -keystore submarine.jks -storetype PKCS12 -keyalg RSA -keysize 4096 -validity 10000 -alias submarine
```

To sign local release builds with it, write `apps/app/android/key.properties` (ignored by git) with `storeFile`, `storePassword`, `keyAlias` and `keyPassword`. Without that file, release builds use the debug key.

## Browser extension

The release holds three zips of the extension: `submarine-extension-<version>-chrome.zip` for the Chrome Web Store, `submarine-extension-<version>-firefox.zip` for Firefox Add-ons, and `submarine-extension-<version>-sources.zip`, the sources Firefox Add-ons asks for with each version. The stores take them by hand:

- Chrome Web Store: upload the Chrome zip on the Package page of the item, in the [developer dashboard](https://chrome.google.com/webstore/devconsole).
- Firefox Add-ons: upload the Firefox zip in the [developer hub](https://addons.mozilla.org/developers/), then the sources zip once it asks whether the code is generated or minified. [SOURCE_CODE_REVIEW.md](SOURCE_CODE_REVIEW.md) tells the reviewers how to rebuild the extension from it.

The [extension workflow](.github/workflows/extension.yml) builds with the Flutter version given in SOURCE_CODE_REVIEW.md, for the reviewers' build to come out identical: change both together.
