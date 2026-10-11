export type Messages = Record<FormatjsIntl.Message["ids"], string>;

// app_pt_BR.arb holds the pt-BR messages.
const catalogs = new Map(
  Object.entries(import.meta.glob<{ default: Messages }>("../../app/lib/l10n/app_*.arb")).map(
    ([path, load]) => [path.slice(path.lastIndexOf("app_") + 4, -4).replace("_", "-"), load],
  ),
);

/** The app's languages, as BCP 47 tags. */
export const locales = [...catalogs.keys()];

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

/** The messages of one of the app's languages, loaded alone. */
export async function loadMessages(locale: string): Promise<Messages> {
  const load = catalogs.get(locale);
  if (!load) throw new Error(`No messages for ${locale}`);
  return (await load()).default;
}
