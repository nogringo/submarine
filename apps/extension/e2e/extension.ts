import { createServer } from "node:http";
import { resolve } from "node:path";
import puppeteer, { type Browser, type ElementHandle, type KeyInput, type Page } from "puppeteer";
import { relayUrl } from "./relay.ts";

export type BrowserName = "chrome" | "firefox";

export interface Extension {
  browser: Browser;
  /** The popup, opened in a tab by the extension itself. */
  popup: Page;
  click(selector: string): Promise<void>;
  rightClick(selector: string): Promise<void>;
  fill(selector: string, text: string): Promise<void>;
  /** Presses `key`, once the focus is in `within` if given. */
  press(key: string, within?: string): Promise<void>;
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
      rightClick: (selector) => popup.locator(selector).click({ button: "right" }),
      // Locator.fill sets a password field's value behind React's back: the text is pasted instead.
      fill: async (selector, text) => {
        const input = await popup.waitForSelector(selector);
        await input?.evaluate((input) => (input as HTMLInputElement).select());
        await popup.keyboard.sendCharacter(text);
      },
      press: async (key, within) => {
        if (within) {
          await popup.waitForFunction(
            (within) => document.querySelector(within)?.contains(document.activeElement),
            {},
            within,
          );
        }
        await popup.keyboard.press(key as KeyInput);
      },
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
      const element = await waitForClickable(popup, selector);
      await element.evaluate((element) => {
        (element as HTMLElement).focus();
        (element as HTMLElement).click();
      });
    },
    rightClick: async (selector) => {
      const element = await waitForClickable(popup, selector);
      await element.evaluate((element) => {
        const { left, top, width, height } = element.getBoundingClientRect();
        const at = { clientX: left + width / 2, clientY: top + height / 2 };
        element.dispatchEvent(
          new MouseEvent("contextmenu", { ...at, button: 2, bubbles: true, cancelable: true }),
        );
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
    press: async (key, within) => {
      // Checked and pressed in one step: React Aria blurs a dialog 500 ms after focusing it, and
      // focuses it again a frame later.
      await popup.waitForFunction(
        (key, within) => {
          const target = document.activeElement ?? document.body;
          if (within && !document.querySelector(within)?.contains(target)) return false;
          for (const type of ["keydown", "keyup"]) {
            target.dispatchEvent(new KeyboardEvent(type, { key, bubbles: true, cancelable: true }));
          }
          return true;
        },
        {},
        key,
        within,
      );
    },
    reload: async () => {
      // Reloads once the script returned, as a page going away under it can leave it unanswered, and
      // marks the page, which matches the selector until it is gone.
      await popup.evaluate(() => {
        Object.assign(window, { reloading: true });
        setTimeout(() => location.reload());
      });
      await popup.waitForFunction(
        () => !("reloading" in window) && document.querySelector("#root > *"),
      );
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

/** Points the relays of new email addresses at the local relay, or back to their defaults. */
export function localMailRelays(popup: Page, local: boolean): Promise<void> {
  return popup.evaluate(
    async (local, relay) => {
      type Api = { runtime: { sendMessage(message: unknown): Promise<string> } };
      const globals = globalThis as unknown as { browser?: Api; chrome: Api };
      const { runtime } = globals.browser ?? globals.chrome;
      const { result: settings } = JSON.parse(
        await runtime.sendMessage({ method: "mailSettings" }),
      );
      for (const list of ["address", "inbox"]) {
        const urls = local ? [relay] : settings[list].defaults;
        await runtime.sendMessage({ method: "setMailList", args: { list, urls } });
      }
    },
    local,
    relayUrl,
  );
}

/**
 * The element of `selector` once a click would reach it, as Chrome's locators wait for one: shown,
 * enabled, still for two frames, and on top, where a drawer or a sheet still closing covers it.
 */
async function waitForClickable(popup: Page, selector: string): Promise<ElementHandle> {
  const deadline = Date.now() + popup.getDefaultTimeout();
  while (Date.now() < deadline) {
    const element = await popup.waitForSelector(selector, { visible: true });
    const clickable = await element
      ?.evaluate(
        (element) =>
          new Promise<boolean>((resolve) => {
            element.scrollIntoView({ block: "nearest" });
            const before = element.getBoundingClientRect();
            requestAnimationFrame(() =>
              requestAnimationFrame(() => {
                const { left, top, width, height } = element.getBoundingClientRect();
                const still =
                  left === before.left &&
                  top === before.top &&
                  width === before.width &&
                  height === before.height;
                const hit = document.elementFromPoint(left + width / 2, top + height / 2);
                resolve(still && !element.matches(":disabled") && !!hit && element.contains(hit));
              }),
            );
          }),
      )
      // Gone meanwhile, as React renders again.
      .catch(() => false);
    if (element && clickable) return element;
    await element?.dispose();
  }
  throw new Error(`${selector} never became clickable`);
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
