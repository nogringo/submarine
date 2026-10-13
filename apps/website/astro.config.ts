import { readdirSync } from "node:fs";
import { satteri } from "@astrojs/markdown-satteri";
import sitemap from "@astrojs/sitemap";
import { defineConfig } from "astro/config";

/** The app's languages, as BCP 47 tags, by the segment of their pages: "pt-br" for pt-BR. */
const locales = Object.fromEntries(
  readdirSync("../app/lib/l10n")
    .filter((file) => file.startsWith("app_") && file.endsWith(".arb"))
    .map((file) => file.slice(4, -4).replace("_", "-"))
    .map((locale) => [locale.toLowerCase(), locale]),
);

export default defineConfig({
  site: "https://submarine.li",
  // fr/privacy.html, served at /fr/privacy by Firebase Hosting's cleanUrls.
  trailingSlash: "never",
  build: { format: "file" },
  markdown: {
    // Keeps the straight quotes of the sources.
    processor: satteri({ features: { smartPunctuation: false } }),
  },
  integrations: [sitemap({ i18n: { defaultLocale: "en", locales } })],
});
