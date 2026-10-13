import { readdir } from "node:fs/promises";
import { preview } from "astro";
import axe from "axe-core";
import puppeteer, { type Page } from "puppeteer";

/** Every built page through axe (WCAG 2.2 AA), light and dark, wide and at 320 px (WCAG 1.4.10). */

const dist = new URL("../dist/", import.meta.url);
const paths = (await readdir(dist, { recursive: true }))
  .filter((file) => file.endsWith(".html") && file !== "404.html")
  .map((file) => `/${file.replace(/\.html$/, "").replace(/^index$/, "")}`)
  .toSorted();
paths.push("/no-such-page", "/fr/no-such-page");

const server = await preview({ root: new URL("..", import.meta.url).pathname, logLevel: "warn" });
const origin = `http://localhost:${server.port}`;
const browser = await puppeteer.launch();
const found: string[] = [];

async function audit(page: Page, label: string) {
  await page.evaluate(axe.source);
  const violations = await page.evaluate(async () => {
    const { axe } = globalThis as unknown as { axe: typeof import("axe-core") };
    const results = await axe.run(document, {
      runOnly: ["wcag2a", "wcag2aa", "wcag21a", "wcag21aa", "wcag22aa", "best-practice"],
    });
    return results.violations.flatMap((rule) =>
      rule.nodes.map((node) => `${rule.id}: ${node.target.join(" ")}`),
    );
  });
  found.push(...violations.map((violation) => `${label} ${violation}`));
}

async function open(page: Page, path: string) {
  await page.goto(origin + path, { waitUntil: "networkidle0" });
}

try {
  const page = await browser.newPage();
  for (const theme of ["light", "dark"]) {
    await page.emulateMediaFeatures([{ name: "prefers-color-scheme", value: theme }]);
    for (const width of [1280, 320]) {
      await page.setViewport({ width, height: 800 });
      for (const path of paths) {
        await open(page, path);
        const label = `${path} ${theme} ${width}px`;
        await audit(page, label);
        if (await page.evaluate(() => document.documentElement.scrollWidth > innerWidth)) {
          found.push(`${label} scrolls sideways`);
        }
      }
    }
  }

  await page.setViewport({ width: 1280, height: 800 });
  await page.evaluateOnNewDocument(() => {
    Object.defineProperty(navigator, "languages", { get: () => ["fr-FR", "fr"] });
  });
  await open(page, "/");
  if (!(await page.$(".language-banner[lang=fr]:not([hidden])"))) {
    found.push("/ shows no banner to a French browser");
  }
  await audit(page, "/ with the banner");
  await page.click("summary");
  await audit(page, "/ with the language menu open");
  await page.keyboard.press("Escape");
  if (await page.$("details[open]")) found.push("/ keeps the language menu open on Escape");
} finally {
  await browser.close();
  await server.stop();
}

for (const line of found) console.error(line);
console.log(`${paths.length} pages checked, ${found.length} problems.`);
process.exitCode = found.length > 0 ? 1 : 0;
