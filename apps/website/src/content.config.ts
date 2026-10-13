import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";

/**
 * The privacy policy by locale: English is the extension's own, the source of every translation.
 * Read by the loader, not imported: importing from apps/extension pulls in its WXT tsconfig.
 */
const privacy = defineCollection({
  loader: glob({
    base: "..",
    pattern: ["extension/PRIVACY.md", "website/src/privacy/*.md"],
    generateId: ({ entry }) =>
      entry === "extension/PRIVACY.md"
        ? "en"
        : entry.slice(entry.lastIndexOf("/") + 1, -3).replace("_", "-"),
  }),
});

export const collections = { privacy };
