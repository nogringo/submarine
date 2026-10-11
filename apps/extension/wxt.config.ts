import { resolve } from "node:path";
import { defineConfig } from "wxt";

export default defineConfig({
  modules: ["@wxt-dev/module-react"],
  manifestVersion: 3,
  manifest: ({ browser }) => ({
    name: "Submarine Password Manager",
    // Chrome empties the clipboard from an offscreen document, Firefox from its background page.
    permissions: [
      "storage",
      "clipboardWrite",
      // Locks the vaults once unused for the timeout, the popup closed.
      "alarms",
      ...(browser === "firefox" ? [] : ["offscreen"]),
    ],
    // Argon2id, which protects the key of the device with the lock password, is WebAssembly.
    content_security_policy: {
      extension_pages: "script-src 'self' 'wasm-unsafe-eval'; object-src 'self';",
    },
    ...(browser === "firefox" && {
      browser_specific_settings: {
        gecko: {
          id: "submarine@uid.ovh",
          // The first version with Firefox's own consent to the data below.
          strict_min_version: "140.0",
          // What the extension sends to the vault's relays once it does all the app does, encrypted.
          data_collection_permissions: {
            required: [
              "authenticationInfo",
              "financialAndPaymentInfo",
              "personallyIdentifyingInfo",
              "personalCommunications",
              "browsingActivity",
            ],
          },
        },
      },
    }),
  }),
  zip: {
    // Firefox Add-ons rebuilds the extension from its sources, the Dart core and the app's texts too.
    sourcesRoot: resolve(import.meta.dirname, "../.."),
    includeSources: [
      "SOURCE_CODE_REVIEW.md",
      "pubspec.yaml",
      "pubspec.lock",
      // pub resolves the whole workspace, the app and the CLI included.
      "apps/app/pubspec.yaml",
      "apps/cli/pubspec.yaml",
      "apps/app/lib/l10n/*.arb",
      "packages/nostr_passwords/pubspec.yaml",
      "packages/nostr_passwords/lib/**",
      "apps/extension/**",
    ],
    excludeSources: [
      "apps/extension/e2e/**",
      "apps/extension/core/test/**",
      "apps/extension/public/core.js*",
    ],
    // Names its sources by their path from the pub cache, which differs from one machine to another.
    exclude: ["core.js.map"],
  },
  hooks: {
    "build:manifestGenerated": (_wxt, manifest) => {
      // Firefox runs the background as a page, where importScripts does not exist.
      const background = manifest.background;
      if (background && "scripts" in background && background.scripts) {
        background.scripts.unshift("core.js");
      }
    },
  },
});
