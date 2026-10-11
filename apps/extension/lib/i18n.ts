export type Messages = Record<FormatjsIntl.Message["ids"], string>;

type Catalog = () => Promise<{ default: Record<string, string> }>;

/** By BCP 47 tag: app_pt_BR.arb holds the pt-BR messages. */
function catalogsOf(files: Record<string, Catalog>, prefix: string): Map<string, Catalog> {
  return new Map(
    Object.entries(files).map(([path, load]) => [
      path.slice(path.lastIndexOf(prefix) + prefix.length, -4).replace("_", "-"),
      load,
    ]),
  );
}

const appCatalogs = catalogsOf(
  import.meta.glob<{ default: Messages }>("../../app/lib/l10n/app_*.arb"),
  "app_",
);

/** The strings of the extension alone, which the app does not have. */
const extensionCatalogs = catalogsOf(
  import.meta.glob<{ default: Messages }>("../l10n/extension_*.arb"),
  "extension_",
);

/** The app's languages, as BCP 47 tags. */
export const locales = [...appCatalogs.keys()];

/**
 * The first of the preferred languages the app speaks, else English as in the app. A region the
 * app lacks falls back to its language: pt-PT to pt, zh-TW to zh.
 */
export function pickLocale(preferred: readonly string[], supported = locales): string {
  for (const tag of preferred) {
    const exact = supported.find((locale) => locale.toLowerCase() === tag.toLowerCase());
    if (exact) return exact;
    const language = tag.split("-")[0]?.toLowerCase();
    if (language && supported.includes(language)) return language;
  }
  return "en";
}

/** The messages of one of the app's languages, the extension's own included, loaded alone. */
export async function loadMessages(locale: string): Promise<Messages> {
  const app = appCatalogs.get(locale);
  const extension = extensionCatalogs.get(locale);
  if (!app || !extension) throw new Error(`No messages for ${locale}`);
  const [appMessages, extensionMessages] = await Promise.all([app(), extension()]);
  return { ...appMessages.default, ...extensionMessages.default } as Messages;
}

/** A date as the app writes it, `yMMMd`: "Oct 11, 2026". */
export const dayFormat: Intl.DateTimeFormatOptions = {
  year: "numeric",
  month: "short",
  day: "numeric",
};
