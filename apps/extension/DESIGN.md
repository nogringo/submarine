# Submarine browser extension

The direction of the browser extension: what its first version does, how it is built, and what comes after. The spike that settled the architecture is on the `spike/extension` branch.

## Version 1: read-only

The first version brings the vaults into the browser to read them. It does what the app does by hand, minus every change.

It does:

- Open several vaults, each from its key pasted as an nsec or an ncryptsec. Each vault gets a name and a color on this device, as in the app: neither is part of the protocol.
- Rename a vault, change its color, or close it, which removes it from this device while its relays keep it, as in the app.
- Sync them from their relays, download only, when the popup opens, and keep them live while it stays open. The app's sync button syncs now. Nothing syncs while the popup is closed.
- List the items of one vault or of all vaults, with the app's search.
- Show every item type in detail: login, secure note, card, identity, SSH key, bank account, driver's license and passport, with their notes, custom fields and password history. An item edited on two devices at once shows its newest version, without a note, as in the app. Items in the trash stay hidden.
- Copy a username, a password, a verification code or any field, and clear the clipboard after the delay chosen in the settings, 30 seconds by default as in the app.
- Lock with a password, optional as in the app. Once one is set, the extension locks after the delay chosen in the settings, 5 minutes unused by default as in the app.
- Settings: the lock delay and the clipboard delay, with the app's choices.
- Speak the app's 11 languages.
- Be as accessible as the app: usable with the keyboard alone and with a screen reader, with the contrast its tokens are made for.

It leaves to the app:

- Creating, editing, trashing, restoring and deleting items, and the password generator: a password generated where it cannot be saved gets lost.
- Creating a vault, its relays and Blossom servers, attachments, email addresses and their inbox, Bitwarden import and export.
- Opening a vault with a bunker (NIP-46). NIP-07 cannot work at all: a NIP-07 extension injects `window.nostr` into web pages, not into another extension's pages.
- Filling forms on websites.

Read-only means the extension can never damage a vault: it writes no version, so it creates no conflict and has nothing to send. It still holds the vault key, which can write too: read-only limits the extension, not the key.

## Decisions

| Decision | Why |
| --- | --- |
| A device of its own, not a bridge to the desktop app (native messaging) | Works without the desktop app, on Chromebooks and next to the web app. A vault opens on as many devices as one likes, and the extension is one more. |
| [WXT](https://wxt.dev) | The only fully maintained extension framework. One source builds Chrome, Firefox, Edge and Safari, and it zips and submits to the stores, Firefox's sources zip included. |
| React, pnpm, Biome and Vitest | React is what most password manager extensions use (Proton Pass, Passbolt, Psono, Buttercup, AliasVault). The tools are those of openspecs. |
| The Dart core, compiled with dart2js | One implementation of the protocol for the app, the CLI and the extension, while the protocol still moves. Rust would add a third language. A TypeScript port would be a second implementation of version merging, which could disagree with the app's. |
| Crypto primitives from TypeScript | Pure-Dart secp256k1 compiled to JavaScript is far slower than [noble](https://github.com/paulmillr/noble-curves): 62 ms against 0.66 ms to open a gift wrap in Chrome. |
| The app's ARB files, read with [FormatJS](https://formatjs.github.io) (`react-intl`) | They are ICU messages, the syntax FormatJS reads, so the extension words things as the app does and a translation is done once. Only the active language loads, about 25 KB. The 4 dates are formatted in code, since an ARB file keeps their format apart from the message. Strings of the extension alone go in ARB files of its own, `l10n/extension_*.arb`, and the name and description shown by the stores in `_locales`. |
| [React Aria Components](https://react-aria.adobe.com) | Tested by Adobe with real screen readers, complete keyboard behavior (lists, dialogs, drawers), and no styles of its own, so Submarine's tokens apply. It translates its own strings, such as a search field's clear button, into 34 languages, the app's 11 among them. |
| MIT for now | The license is decided again with autofill: Bitwarden's autofill code is GPL-3.0-only. |

## Architecture

```
popup (React) ── runtime messages ──▶ background (Chrome service worker, Firefox event page)
                                       ├─ nostrCrypto (noble, nostr-tools): sign, verify, NIP-44
                                       └─ core.js (dart2js): nostr_passwords, ndk, sync engine
                                            └─ IndexedDB: ndk cache, sync coverage, version caches
```

- The background runs the Dart core, `apps/extension/core`, a pub workspace member that depends on `nostr_passwords`. `dart compile js` builds it before `wxt build`. Chrome loads it with `importScripts` in the service worker, Firefox lists it before `background.js`.
- The core has one narrow API: `submarineCore.call(method, json)` returns a promise of JSON. The popup reaches it through runtime messages. The background answers extension pages only, so a content script, when one comes, gets an API of its own, narrower.
- The popup holds a runtime port open while it stays open. The background syncs the vaults from the first port to the last one closed, and passes on through the ports what the core tells through `coreEvents`: a vault's sync or items moved, for the popup to read them again.
- The core signs, verifies and encrypts through `nostrCrypto`, which the background sets before loading it (`JsEventSigner`, `JsEventSignerFactory` and `JsEventVerifier` on the Dart side). It reads and writes `storage.local` through `extensionStorage`, set the same way (`JsStorage`).
- IndexedDB, through sembast_web opened with `databaseFactoryWebWorker`, holds ndk's `SembastCacheManager`, the sync engine's `SembastSyncStore` and each vault's `VersionCache`, in one database: the sync coverage must never outlive the cache it describes. It opens once a popup asks for the sync.
- The sync engine goes to the relays at each opening of the popup (no staleness), then every 5 minutes while it stays open, next to the live subscription.
- `storage.local` holds the vault records (key, name, color, cache key), encrypted with a random device key, as in the app. With a lock password, it holds that device key wrapped by the password (`PasswordProtectedKey`, Argon2id with Bitwarden's defaults). Without one, it holds the device key as is, as the app does on the web, which has no keystore of the system either.
- With a lock password, `storage.session` holds the device key while the extension is unlocked. It lives in memory only, survives the background being stopped, and is gone once the browser closes.
- The lock delay counts from the last use of a popup, a pointer or a key, which the popup reports and `storage.session` keeps. An alarm wakes the background at the deadline, and the core checks it before each call too, as an alarm may come late. Immediately locks as the last popup closes, and On browser restart leaves it to `storage.session`.
- The popup copies, and the background empties the clipboard of a copied secret after the delay, as the popup is often closed by then. Chrome's service worker has no document: an offscreen document empties it. Firefox's background page does it itself. Both need `clipboardWrite`. Without `clipboardRead`, which would add a warning at install, the clipboard is emptied without checking what it holds, as the app does on the web, but a new copy from the extension cancels the pending one.
- The popup takes the app's narrow layout, as on phones: the vaults in a drawer, All vaults by default, the item list, and the item detail over the list. The settings are the last row of the drawer, as a popup has no room for the app's navigation bar. Same tokens, Atkinson Hyperlegible, light and dark themes. A popup is at most 800 by 600 pixels.

## Browser constraints

What the spike ran into, and what the extension does about it.

- Without a DOM, dart2js runs its microtasks on `setTimeout`, clamped to 4 ms once nested, so each await on a JavaScript promise cost milliseconds. The background sets `scheduleImmediate` to `queueMicrotask` before loading the core: an AES-GCM round trip went from 11.6 ms to 0.03 ms. Known since 2014 as [dart-lang/sdk#20055](https://github.com/dart-lang/sdk/issues/20055).
- `package:cryptography` 2.9.0 reads `window.isSecureContext` and `window.crypto.getRandomValues`, and a service worker has no `window`. The background defines a minimal `window` until a release of the package reads them from `globalThis`.
- `SembastCacheManager.create` opens its database through `window`, so the core opens it with `databaseFactoryWebWorker` and hands it to the constructor. `ndk_drift` (Flutter) and `ndk_sqlite3` (`dart:ffi`) cannot run there.
- Firefox stops an event page after 30 seconds idle, even with a reply pending, a promise returned or a port open, and Chrome a service worker that receives no event. While the core works or a popup is open, the background calls an extension API every 10 seconds.
- Puppeteer's `waitForSelector` does not see a text change in a node already there, as React makes it: the end-to-end tests wait for a text with `waitForFunction`.
- Argon2 is WebAssembly: the extension pages' CSP is `script-src 'self' 'wasm-unsafe-eval'; object-src 'self';`.
- Firefox Add-ons rebuilds the extension from its sources: the sources zip needs the Dart packages and instructions for the Dart SDK.
- Firefox's WebDriver BiDi cannot open `moz-extension://` pages, nor send them mouse or keyboard input. The end-to-end tests start Firefox with `-remote-allow-system-access`, use a build that opens its own page (`--mode e2e`), and dispatch clicks and keys from a script there, as a screen reader does.

## Spike measurements

Measured on 2026-10-11 with Chrome for Testing 155 and Firefox 157, headless, the core built with `dart compile js -O2`, crypto through noble and a version cache.

| | Chrome | Firefox |
| --- | --- | --- |
| `core.js` | 1.15 MB, about 350 KB gzipped | same |
| Background start, core loaded | 16 ms | 65 ms |
| IndexedDB opened with 300 events | 26 ms | 16 ms |
| 300 items listed after a restart | 25 ms | 23 ms |
| Lock password, Argon2id (protect, open) | 111 ms, 79 ms | 139 ms, 85 ms |
| 10 items synced from the 11 default relays into an empty cache | 3 to 5 s | 3 to 4 s |
| One gift wrap opened, pure Dart then noble | 62 ms, 0.66 ms | 70 ms, about 2 ms |

## After version 1

Candidates, added one at a time, in an order to decide:

- The current site's items first. Matching a page with a login's URIs follows Bitwarden's match settings and belongs in `nostr_passwords`, since the app's autofill on phones will need it too.
- Editing: create, edit, trash, restore and delete items, with the generator.
- Filling a login on an explicit action, a button in the popup or a keyboard shortcut. The license question comes back here.
- Offering to save a login after signing in.
- A menu in the page's fields, rendered in an isolated iframe against clickjacking.
- The app's filters: favorites, each type, and the trash.
- Opening a vault with a bunker, attachments, email addresses and their inbox, a side panel, Safari, passkeys.
