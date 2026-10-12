import type { Page } from "puppeteer";

/**
 * Shows `page` in `theme` whatever the system prefers, or as it prefers with null. The build turns
 * light-dark() into rules under prefers-color-scheme, which Firefox lets no script emulate: their
 * media lists are rewritten instead.
 */
export function setTheme(page: Page, theme: "light" | "dark" | null): Promise<void> {
  return page.evaluate((theme) => {
    const page = globalThis as { themeMedia?: Map<CSSMediaRule, string> };
    page.themeMedia ??= new Map(
      [...document.styleSheets]
        .flatMap((sheet) => [...sheet.cssRules])
        .filter(
          (rule): rule is CSSMediaRule =>
            rule instanceof CSSMediaRule && rule.conditionText.includes("prefers-color-scheme"),
        )
        .map((rule) => [rule, rule.media.mediaText]),
    );
    for (const [rule, media] of page.themeMedia) {
      rule.media.mediaText = theme === null ? media : media.includes(theme) ? "all" : "not all";
    }
    if (theme === null) delete page.themeMedia;
    document.documentElement.style.colorScheme = theme ?? "";
  }, theme);
}
