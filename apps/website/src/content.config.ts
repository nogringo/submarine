import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { z } from "astro/zod";

/** "pt_BR" in a file name is the pt-BR locale. */
const localeOf = (entry: string) => entry.slice(entry.lastIndexOf("/") + 1, -3).replace("_", "-");

/**
 * The privacy policy by locale: English is the extension's own, the source of every translation.
 * Read by the loader, not imported: importing from apps/extension pulls in its WXT tsconfig.
 */
const privacy = defineCollection({
  loader: glob({
    base: "..",
    pattern: ["extension/PRIVACY.md", "website/src/privacy/*.md"],
    generateId: ({ entry }) => (entry === "extension/PRIVACY.md" ? "en" : localeOf(entry)),
  }),
});

/** The site's longer pages, as articles/<page>/<locale>.md, under the id <page>/<locale>. */
const articles = defineCollection({
  loader: glob({
    base: "src/articles",
    pattern: "*/*.md",
    generateId: ({ entry }) => `${entry.slice(0, entry.indexOf("/"))}/${localeOf(entry)}`,
  }),
  schema: z.object({ description: z.string() }),
});

export const collections = { privacy, articles };
