import { defineConfig } from "wxt";

export default defineConfig({
  modules: ["@wxt-dev/module-react"],
  manifestVersion: 3,
  manifest: ({ browser }) => ({
    name: "Submarine",
    // Chrome empties the clipboard from an offscreen document, Firefox from its background page.
    permissions: ["storage", "clipboardWrite", ...(browser === "firefox" ? [] : ["offscreen"])],
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
