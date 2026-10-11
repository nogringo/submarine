import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { type BrowserName, type Extension, launch } from "./extension";

describe.each<BrowserName>(["chrome", "firefox"])("%s", (name) => {
  let extension: Extension;

  beforeAll(async () => {
    extension = await launch(name);
  });

  afterAll(async () => {
    await extension?.browser.close();
  });

  it("welcomes in the popup", async () => {
    const heading = await extension.popup.waitForSelector("h1");
    expect(await heading?.evaluate((h1) => h1.textContent)).toBe("Submarine");
  });

  it("explains Nostr in a dialog, closed with Escape", async () => {
    const { popup } = extension;
    await extension.click("button::-p-text(Built on Nostr)");
    const dialog = await popup.waitForSelector("[role=dialog]");
    expect(await dialog?.$eval("h2", (title) => title.textContent)).toBe("Built on Nostr");
    await popup.waitForFunction(() =>
      document.querySelector("[role=dialog]")?.contains(document.activeElement),
    );
    await extension.press("Escape");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForFunction(() => document.activeElement?.textContent === "Built on Nostr");
  });

  it("reaches the core in the background", async () => {
    const reply = await extension.popup.evaluate(() => {
      type Api = { runtime: { sendMessage(message: unknown): Promise<string> } };
      const globals = globalThis as unknown as { browser?: Api; chrome: Api };
      return (globals.browser ?? globals.chrome).runtime.sendMessage({ method: "unknown" });
    });
    expect(JSON.parse(reply)).toEqual({ error: { code: "unknownMethod", message: "unknown" } });
  });
});
