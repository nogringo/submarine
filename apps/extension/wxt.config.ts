import { defineConfig } from "wxt";

export default defineConfig({
  modules: ["@wxt-dev/module-react"],
  manifestVersion: 3,
  manifest: ({ browser }) => ({
    name: "Submarine",
    // Chrome empties the clipboard from an offscreen document, Firefox from its background page.
    permissions: ["storage", "clipboardWrite", ...(browser === "firefox" ? [] : ["offscreen"])],
    // Argon2id, which protects the key of the device with the lock password, is WebAssembly.
    content_security_policy: {
      extension_pages: "script-src 'self' 'wasm-unsafe-eval'; object-src 'self';",
    },
    ...(browser === "firefox" && {
      browser_specific_settings: { gecko: { id: "submarine@uid.ovh" } },
    }),
  }),
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
