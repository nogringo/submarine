import { readFile } from "node:fs/promises";
import { parse } from "@formatjs/icu-messageformat-parser";
import { describe, expect, it } from "vitest";
import { loadMessages, locales, pickLocale } from "./i18n";

describe("pickLocale", () => {
  it.each([
    [["fr-FR", "en"], "fr"],
    [["pt-BR"], "pt-BR"],
    [["pt-PT"], "pt"],
    [["zh-TW"], "zh"],
    [["ko", "de-CH"], "de"],
    [["ko"], "en"],
    [[], "en"],
  ])("picks from %j: %s", (preferred, locale) => {
    expect(pickLocale(preferred)).toBe(locale);
  });
});

describe("the app's messages", () => {
  it("come in the app's 11 languages", () => {
    expect(locales.toSorted()).toEqual([
      "de",
      "en",
      "es",
      "fi",
      "fr",
      "it",
      "ja",
      "pt",
      "pt-BR",
      "ru",
      "zh",
    ]);
  });

  it("leave the extension's own strings apart", async () => {
    const read = async (path: string) =>
      Object.keys(JSON.parse(await readFile(new URL(path, import.meta.url), "utf8")));
    const app = await read("../../app/lib/l10n/app_en.arb");
    const ids = (await read("../l10n/extension_en.arb")).filter((id) => !id.startsWith("@"));
    expect(ids.filter((id) => app.includes(id))).toEqual([]);
    for (const locale of locales) {
      expect(Object.keys((await loadMessages(locale)) as object), locale).toEqual(
        expect.arrayContaining(ids),
      );
    }
  });

  it.each(locales)("read as ICU messages in %s", async (locale) => {
    const messages = await loadMessages(locale);
    expect(Object.keys(messages).length).toBeGreaterThan(400);
    expect(Object.keys(messages).filter((id) => id.startsWith("@"))).toEqual([]);
    for (const [id, message] of Object.entries(messages)) {
      expect(() => parse(message), id).not.toThrow();
    }
  });
});
