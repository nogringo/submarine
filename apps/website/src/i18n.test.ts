import { readdir, readFile } from "node:fs/promises";
import { describe, expect, it } from "vitest";
import {
  articles,
  languageName,
  locales,
  message,
  openGraphLocaleOf,
  pathOf,
  websiteCatalogs,
} from "./i18n";
import { pickLocale } from "./pick-locale";

const read = (path: string) => readFile(new URL(path, import.meta.url), "utf8");
const ids = (messages: Record<string, string>) =>
  Object.keys(messages).filter((id) => !id.startsWith("@"));
const placeholders = (text: string) => [...text.matchAll(/\{(\w+)\}/g)].map((match) => match[1]);
/** What the user's writing rules leave out: dashes as separators, curly quotes, the ellipsis. */
const banned = /[\u2013\u2014\u2026\u2018\u2019\u201c\u201d\u2015]/u;

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
    expect(pickLocale(preferred, locales)).toBe(locale);
  });
});

describe("pathOf", () => {
  it.each([
    ["en", "", "/"],
    ["en", "download", "/download"],
    ["fr", "", "/fr"],
    ["pt-BR", "privacy", "/pt-br/privacy"],
  ] as const)("gives %s %j at %s", (locale, page, path) => {
    expect(pathOf(locale, page)).toBe(path);
  });
});

describe("openGraphLocaleOf", () => {
  it.each([
    ["en", "en_US"],
    ["fr", "fr_FR"],
    ["pt", "pt_PT"],
    ["pt-BR", "pt_BR"],
    ["zh", "zh_CN"],
    ["ja", "ja_JP"],
  ])("gives %s as %s", (locale, openGraphLocale) => {
    expect(openGraphLocaleOf(locale)).toBe(openGraphLocale);
  });
});

describe("message", () => {
  it("fills placeholders", () => {
    expect(message("en", "latestVersion", { version: "1.2.0", date: "today" })).toBe(
      "Version 1.2.0, released on today.",
    );
  });

  it("refuses a missing value or message", () => {
    expect(() => message("en", "latestVersion")).toThrow();
    expect(() => message("en", "noSuchMessage")).toThrow();
  });

  it("reads the app's messages too", () => {
    expect(languageName("ja")).toBe("日本語");
  });
});

describe("the site's messages", () => {
  const english = websiteCatalogs.get("en") ?? {};

  it("come in every language of the app", () => {
    expect([...websiteCatalogs.keys()].toSorted()).toEqual(locales.toSorted());
    expect(locales).toHaveLength(11);
  });

  it("leave the app's strings apart", async () => {
    const app = Object.keys(JSON.parse(await read("../../app/lib/l10n/app_en.arb")));
    expect(ids(english).filter((id) => app.includes(id))).toEqual([]);
  });

  it.each(locales)("are all translated, with their placeholders, in %s", (locale) => {
    const messages = websiteCatalogs.get(locale) ?? {};
    expect(ids(messages)).toEqual(ids(english));
    for (const id of ids(english)) {
      expect(placeholders(messages[id] ?? ""), id).toEqual(placeholders(english[id] ?? ""));
      expect(messages[id], id).not.toMatch(banned);
    }
  });
});

const localePrefix = new RegExp(
  `^/(${locales.map((locale) => locale.toLowerCase()).join("|")})(?=/|$)`,
);
/** Its links with the locale taken out of the site's own: /fr/faq is /faq. */
const structure = (markdown: string) => ({
  headings: markdown.split("\n").filter((line) => line.startsWith("#")).length,
  items: markdown.split("\n").filter((line) => /^(- |\d+\. )/.test(line)).length,
  links: [...markdown.matchAll(/\]\(([^)]+)\)/g)].map(
    (match) => match[1]?.replace(localePrefix, "") || "/",
  ),
});
const translations = locales.filter((locale) => locale !== "en");
const fileOf = (locale: string) => `${locale.replace("-", "_")}.md`;

describe("the privacy policy", () => {
  it("is translated in every other language", async () => {
    const files = await readdir(new URL("privacy", import.meta.url));
    expect(files.toSorted()).toEqual(translations.map(fileOf).toSorted());
  });

  it.each(translations)("keeps the English structure and links in %s", async (locale) => {
    const english = await read("../../extension/PRIVACY.md");
    const translation = await read(`privacy/${fileOf(locale)}`);
    expect(structure(translation)).toEqual(structure(english));
    expect(translation).not.toMatch(banned);
  });
});

describe.each(articles)("the %s page", (article) => {
  it("is written in every language", async () => {
    const files = await readdir(new URL(`articles/${article}`, import.meta.url));
    expect(files.toSorted()).toEqual(locales.map(fileOf).toSorted());
  });

  it.each(locales)("keeps the English structure and links in %s", async (locale) => {
    const english = await read(`articles/${article}/en.md`);
    const translation = await read(`articles/${article}/${fileOf(locale)}`);
    expect(structure(translation)).toEqual(structure(english));
    expect(translation).not.toMatch(banned);
  });
});
