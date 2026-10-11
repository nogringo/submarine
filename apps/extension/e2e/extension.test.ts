import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { generateSecretKey, nip19 } from "nostr-tools";
import * as nip49 from "nostr-tools/nip49";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { type BrowserName, type Extension, launch } from "./extension";

const english = JSON.parse(await readFile(appArb("en"), "utf8"));

describe.each<BrowserName>(["chrome", "firefox"])("%s", (name) => {
  const secretKey = generateSecretKey();
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

  it("refuses what is not a vault key", async () => {
    await extension.click("button::-p-text(Open a vault)");
    await extension.fill("input[name=key]", "hello");
    await extension.fill("input[name=name]", "Home");
    await extension.click("button[type=submit]");
    await extension.popup.waitForSelector(`::-p-text(${english.vaultKeyInvalid})`);
  });

  it("opens a vault from its ncryptsec, once the password is right", async () => {
    const { popup } = extension;
    await extension.fill("input[name=key]", nip49.encrypt(secretKey, "a long password"));
    await extension.fill("input[name=password]", "wrong");
    await extension.click("button[type=submit]");
    await popup.waitForSelector(`::-p-text(${english.vaultKeyPasswordWrong})`);
    await extension.fill("input[name=password]", "a long password");
    await extension.click("button[type=submit]");
    const title = await popup.waitForSelector(".home-title");
    expect(await title?.evaluate((h1) => h1.textContent)).toBe("All vaults");
  });

  it("syncs the vault from its relays while the popup is open", async () => {
    await extension.popup.waitForFunction(
      (synced) => document.querySelector(".sync-status")?.textContent === synced,
      { timeout: 20_000 },
      english.syncedJustNow,
    );
  });

  it("lists the vault in the drawer, and shows it once chosen", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    const options = await popup.waitForSelector("[role=listbox]");
    expect(
      await options?.$$eval(".drawer-row-title", (titles) =>
        titles.map((title) => title.textContent),
      ),
    ).toEqual(["All vaults", "Home"]);
    await extension.click("[role=option]::-p-text(Home)");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForFunction(
      () => document.querySelector(".home-title")?.textContent === "Home",
    );
  });

  it("refuses a vault already open", async () => {
    await extension.click("button[aria-label=Vaults]");
    await extension.click("button::-p-text(Open a vault)");
    await extension.fill("input[name=key]", nip19.nsecEncode(secretKey));
    await extension.fill("input[name=name]", "Work");
    await extension.click("button[type=submit]");
    const error = english.vaultAlreadyOpen.replace("{name}", "Home");
    await extension.popup.waitForSelector(`::-p-text(${error})`);
    await extension.click("button::-p-text(Cancel)");
  });

  it("keeps the vaults when the popup opens again", async () => {
    await extension.reload();
    const title = await extension.popup.waitForSelector(".home-title");
    expect(await title?.evaluate((h1) => h1.textContent)).toBe("All vaults");
  });
});

describe.each<BrowserName>(["chrome", "firefox"])("%s in French", (name) => {
  let extension: Extension;

  beforeAll(async () => {
    extension = await launch(name, "fr");
  });

  afterAll(async () => {
    await extension?.browser.close();
  });

  it("speaks the language the browser prefers", async () => {
    const french = JSON.parse(await readFile(appArb("fr"), "utf8"));
    const tagline = await extension.popup.waitForSelector(".tagline");
    expect(await tagline?.evaluate((p) => p.textContent)).toBe(french.welcomeTagline);
    expect(await extension.popup.evaluate(() => document.documentElement.lang)).toBe("fr");
  });
});

function appArb(locale: string) {
  return resolve(import.meta.dirname, `../../app/lib/l10n/app_${locale}.arb`);
}
