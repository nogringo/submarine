import { satteri } from "@astrojs/markdown-satteri";
import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://submarine.li",
  // fr/privacy.html, served at /fr/privacy by Firebase Hosting's cleanUrls.
  trailingSlash: "never",
  build: { format: "file" },
  markdown: {
    // Keeps the straight quotes of the sources.
    processor: satteri({ features: { smartPunctuation: false } }),
  },
});
