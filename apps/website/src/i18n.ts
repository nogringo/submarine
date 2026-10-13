type Messages = Record<string, string>;

/** By BCP 47 tag: app_pt_BR.arb holds the pt-BR messages. */
function catalogsOf(files: Record<string, string>, prefix: string): Map<string, Messages> {
  return new Map(
    Object.entries(files).map(([path, source]) => [
      path.slice(path.lastIndexOf(prefix) + prefix.length, -4).replace("_", "-"),
      JSON.parse(source) as Messages,
    ]),
  );
}

const appCatalogs = catalogsOf(
  import.meta.glob<string>("../../app/lib/l10n/app_*.arb", {
    query: "?raw",
    import: "default",
    eager: true,
  }),
  "app_",
);

/** The strings of the site alone, which the app does not have. */
export const websiteCatalogs = catalogsOf(
  import.meta.glob<string>("../l10n/website_*.arb", {
    query: "?raw",
    import: "default",
    eager: true,
  }),
  "website_",
);

export const defaultLocale = "en";

/** The app's languages, as BCP 47 tags, by their name in their own language. */
export const locales = [...appCatalogs.keys()].sort((a, b) =>
  languageName(a).localeCompare(languageName(b), "en"),
);

export function languageName(locale: string): string {
  return message(locale, "languageName");
}

/** A message of the site, else of the app, with its `{placeholders}` filled. */
export function message(locale: string, id: string, values: Record<string, string> = {}): string {
  const text = websiteCatalogs.get(locale)?.[id] ?? appCatalogs.get(locale)?.[id];
  if (text === undefined) throw new Error(`No message ${id} in ${locale}`);
  return text.replace(/\{(\w+)\}/g, (_, name: string) => {
    const value = values[name];
    if (value === undefined) throw new Error(`No value for {${name}} in ${id}`);
    return value;
  });
}

/** The language_TERRITORY form Open Graph wants: fr_FR for fr. */
export function openGraphLocaleOf(locale: string): string {
  const { language, region } = new Intl.Locale(locale).maximize();
  // Likely subtags give Brazil for pt, the site's pt is Portugal's.
  return `${language}_${locale === "pt" ? "PT" : region}`;
}

/** The first segment of a page's address: none for English, "pt-br" for pt-BR. */
export function segmentOf(locale: string): string | undefined {
  return locale === defaultLocale ? undefined : locale.toLowerCase();
}

export type Page = "" | "download" | "privacy";

export function pathOf(locale: string, page: Page): string {
  const path = [segmentOf(locale), page].filter(Boolean).join("/");
  return `/${path}`;
}

/** The paths of a page in every language, for its `[...lang]` route. */
export function localePaths() {
  return locales.map((locale) => ({ params: { lang: segmentOf(locale) }, props: { locale } }));
}
