import axe from "axe-core";
import type { Page } from "puppeteer";
import { setTheme } from "./theme";

/**
 * What axe finds against WCAG 2.2 A and AA and its own best practices in the popup as it stands, in
 * the light theme then in the dark one, each as "theme rule: element".
 */
export async function violations(popup: Page): Promise<string[]> {
  // Evaluated by the browser's driver, which the extension's CSP does not hold back, unlike eval.
  if (!(await popup.evaluate(() => "axe" in globalThis))) await popup.evaluate(axe.source);
  const found: string[] = [];
  try {
    for (const theme of ["light", "dark"] as const) {
      await setTheme(popup, theme);
      found.push(
        ...(await popup.evaluate(async (theme) => {
          const { axe } = globalThis as unknown as { axe: typeof import("axe-core") };
          const results = await axe.run(
            // React Aria's live region keeps an announcement 7 s, even once the element naming it is gone.
            { exclude: ["[data-live-announcer]"] },
            { runOnly: ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa", "best-practice"] },
          );
          return results.violations.flatMap((rule) =>
            rule.nodes.map((node) => `${theme} ${rule.id}: ${node.target.join(" ")}`),
          );
        }, theme)),
      );
    }
  } finally {
    await setTheme(popup, null);
  }
  return found;
}
