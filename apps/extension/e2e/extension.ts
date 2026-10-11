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
          extraPrefsFirefox: { "intl.accept_languages": language },
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
    };
  }
  await browser.installExtension(path);
  const popup = await waitForPopup(browser);
  // WebDriver BiDi sends no input to an extension page: the events come from a script, as from a
  // screen reader.
  return {
    browser,
    popup,
    click: (selector) =>
      popup.$eval(selector, (element) => {
        (element as HTMLElement).focus();
        (element as HTMLElement).click();
      }),
    fill: (selector, text) =>
      popup.$eval(
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
      ),
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
  };
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
