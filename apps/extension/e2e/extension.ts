import { resolve } from "node:path";
import puppeteer, { type Browser, type Page } from "puppeteer";

export type BrowserName = "chrome" | "firefox";

export interface Extension {
  browser: Browser;
  /** The popup, opened in a tab by the extension itself. */
  popup: Page;
}

/** Starts a browser with the end-to-end build of the extension installed. */
export async function launch(name: BrowserName): Promise<Extension> {
  const path = resolve(import.meta.dirname, `../.output/${name}-mv3-e2e`);
  const browser =
    name === "chrome"
      ? await puppeteer.launch({ browser: "chrome", pipe: true, enableExtensions: [path] })
      : await puppeteer.launch({
          browser: "firefox",
          // Lets the tests run scripts in the extension's pages.
          args: ["-remote-allow-system-access"],
        });
  if (name === "firefox") await browser.installExtension(path);
  return { browser, popup: await waitForPopup(browser) };
}

async function waitForPopup(browser: Browser): Promise<Page> {
  const deadline = Date.now() + 10_000;
  while (Date.now() < deadline) {
    for (const page of await browser.pages()) {
      // Firefox gives an extension page's target the URL about:blank.
      const url = await page.evaluate(() => location.href).catch(() => "");
      if (url.endsWith("/popup.html")) return page;
    }
    await new Promise((wait) => setTimeout(wait, 100));
  }
  throw new Error("The extension did not open its popup");
}
