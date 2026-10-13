/**
 * The first of the preferred languages the site speaks, else English. A region the site lacks
 * falls back to its language: pt-PT to pt, zh-TW to zh.
 */
export function pickLocale(preferred: readonly string[], supported: readonly string[]): string {
  for (const tag of preferred) {
    const exact = supported.find((locale) => locale.toLowerCase() === tag.toLowerCase());
    if (exact) return exact;
    const language = tag.split("-")[0]?.toLowerCase();
    if (language && supported.includes(language)) return language;
  }
  return "en";
}
