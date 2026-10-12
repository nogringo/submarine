import { createServer } from "node:http";
import { resolve } from "node:path";
import puppeteer, { type Browser, type KeyInput, type Page } from "puppeteer";

export type BrowserName = "chrome" | "firefox";

export interface Extension {
  browser: Browser;
  /** The popup, opened in a tab by the extension itself. */
  popup: Page;
  click(selector: string): Promise<void>;
  fill(selector: string, text: string): Promise<void>;
  press(key: string): Promise<void>;
  /** Opens the popup again, as when the user clicks the extension's icon once more. */
  reload(): Promise<void>;
  readClipboard(): Promise<string>;
}

/**
 * Starts a browser with the end-to-end build of the extension installed, preferring `language`
 * whatever the language of the system.
 */
export async function launch(name: BrowserName, language = "en"): Promise<Extension> {
  const path = resolve(import.meta.dirname, `../.output/${name}-mv3-e2e`);
  const browser =
    name === "chrome"
      ? await puppeteer.launch({
          browser: "chrome",
          pipe: true,
          enableExtensions: [path],
          args: [`--accept-lang=${language}`],
        })
      : await puppeteer.launch({
          browser: "firefox",
          // Lets the tests run scripts in the extension's pages.
          args: ["-remote-allow-system-access"],
          extraPrefsFirefox: {
            "intl.accept_languages": language,
            // Lets a page read the clipboard without asking.
            "dom.events.testing.asyncClipboard": true,
          },
        });
  if (name === "chrome") {
    const popup = await waitForPopup(browser);
    return {
      browser,
      popup,
      click: (selector) => popup.locator(selector).click(),
      // Locator.fill sets a password field's value behind React's back: the text is pasted instead.
      fill: async (selector, text) => {
        const input = await popup.waitForSelector(selector);
        await input?.evaluate((input) => (input as HTMLInputElement).select());
        await popup.keyboard.sendCharacter(text);
      },
      press: (key) => popup.keyboard.press(key as KeyInput),
      reload: async () => {
        await popup.reload();
      },
      readClipboard: chromeClipboardReader(browser, popup),
    };
  }
  await browser.installExtension(path);
  const popup = await waitForPopup(browser);
  // WebDriver BiDi sends no input to an extension page: the events come from a script, as from a
  // screen reader. Each waits for its element, as Chrome's locators do.
  return {
    browser,
    popup,
    click: async (selector) => {
      await popup.waitForSelector(selector);
      await popup.$eval(selector, (element) => {
        (element as HTMLElement).focus();
        (element as HTMLElement).click();
      });
    },
    fill: async (selector, text) => {
      await popup.waitForSelector(selector);
      await popup.$eval(
        selector,
        (input, text) => {
          (input as HTMLInputElement).focus();
          // React listens to input events, and reads the value through the prototype's setter.
          Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value")?.set?.call(
            input,
            text,
          );
          input.dispatchEvent(new Event("input", { bubbles: true }));
        },
        text,
      );
    },
    press: (key) =>
      popup.evaluate((key) => {
        const target = document.activeElement ?? document.body;
        for (const type of ["keydown", "keyup"]) {
          target.dispatchEvent(new KeyboardEvent(type, { key, bubbles: true, cancelable: true }));
        }
      }, key),
    reload: async () => {
      // The page goes away with the script that reloads it.
      await popup.evaluate(() => location.reload()).catch(() => {});
      await popup.waitForSelector("#root > *");
    },
    readClipboard: () => popup.evaluate(() => navigator.clipboard.readText()),
  };
}

/**
 * Chrome grants no permission to an extension's origin through the DevTools protocol: a tab of a
 * local page reads the clipboard, which the browser shares, then gives the focus back to the popup.
 */
function chromeClipboardReader(browser: Browser, popup: Page): () => Promise<string> {
  let reader: Promise<Page> | undefined;
  const open = async () => {
    const server = createServer((_request, response) => response.end()).listen(0);
    server.unref();
    browser.once("disconnected", () => server.close());
    await new Promise((listening) => server.once("listening", listening));
    const origin = `http://localhost:${(server.address() as { port: number }).port}`;
    const page = await browser.newPage();
    await page.goto(origin);
    await browser.defaultBrowserContext().overridePermissions(origin, ["clipboard-read"]);
    return page;
  };
  return async () => {
    reader ??= open();
    const page = await reader;
    await page.bringToFront();
    const text = await page.evaluate(() => navigator.clipboard.readText());
    await popup.bringToFront();
    return text;
  };
}

/**
 * Opens a tab on `url`, the page `body` whatever its host, then the popup over it as from the
 * extension's icon. Chrome only: WebDriver BiDi cannot trigger an extension's action.
 */
export async function openPopupOver(
  browser: Browser,
  url: string,
  body = "",
): Promise<{ page: Page; popup: Page }> {
  const page = await browser.newPage();
  await page.setRequestInterception(true);
  page.on("request", (request) => void request.respond({ contentType: "text/html", body }));
  await page.goto(url);
  const [extension] = (await browser.extensions()).values();
  if (!extension) throw new Error("The extension is not installed");
  // The popup opened in a tab by the extension has the same URL.
  const before = new Set(browser.targets());
  const opened = browser.waitForTarget(
    (target) => !before.has(target) && target.url().endsWith("/popup.html"),
  );
  await page.triggerExtensionAction(extension);
  const popup = await (await opened).asPage();
  await popup.waitForSelector("#root > *");
  return { page, popup };
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
