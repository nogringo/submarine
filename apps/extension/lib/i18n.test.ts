import { readFile } from "node:fs/promises";
import { parse } from "@formatjs/icu-messageformat-parser";
import { beforeEach, describe, expect, it } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import {
  languageNames,
  loadMessages,
  locales,
  pickLocale,
  readChosenLocale,
  saveChosenLocale,
} from "./i18n";

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

describe("the language chosen", () => {
  beforeEach(() => {
    fakeBrowser.reset();
  });

  it("follows the browser's until one is, in the app's key", async () => {
    expect(await readChosenLocale()).toBeUndefined();
    await saveChosenLocale("pt-BR");
    expect(await readChosenLocale()).toBe("pt-BR");
    expect(await browser.storage.local.get()).toEqual({ locale: "pt-BR" });
    await saveChosenLocale(undefined);
    expect(await readChosenLocale()).toBeUndefined();
    expect(await browser.storage.local.get()).toEqual({});
  });

  it("follows the browser's again when the app no longer speaks it", async () => {
    await browser.storage.local.set({ locale: "ko" });
    expect(await readChosenLocale()).toBeUndefined();
  });
});

describe("languageNames", () => {
  it("names each language in itself", async () => {
    const names = await languageNames();
    expect([...names.keys()].toSorted()).toEqual(locales.toSorted());
    expect(names.get("fr")).toBe("Français");
    expect(names.get("pt-BR")).toBe("Português (Brasil)");
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
