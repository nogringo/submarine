import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { generateSecretKey, nip19 } from "nostr-tools";
import * as nip49 from "nostr-tools/nip49";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { type BrowserName, type Extension, launch } from "./extension";
import { publishItems } from "./vault-items";

const english = JSON.parse(await readFile(appArb("en"), "utf8"));

describe.each<BrowserName>(["chrome", "firefox"])("%s", (name) => {
  const secretKey = generateSecretKey();
  let extension: Extension;

  beforeAll(async () => {
    await publishItems(secretKey, [
      { type: 2, name: "wifi" },
      {
        type: 3,
        name: "Visa",
        card: { brand: "Visa", number: "4111111111111111", expMonth: "3", expYear: "2029" },
      },
      {
        type: 1,
        name: "GitHub",
        login: {
          username: "alice",
          password: "hunter2",
          totp: "JBSWY3DPEHPK3PXP",
          uris: [{ uri: "github.com" }],
        },
        notes: "Recovery codes in the safe",
        fields: [{ name: "PIN", value: "1234", type: 1 }],
        passwordHistory: [{ password: "hunter1", lastUsedDate: "2026-10-01T09:30:00.000Z" }],
      },
      { type: 2, name: "Old bank", deletedDate: "2026-10-01T00:00:00.000Z" },
    ]);
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

  it("lists the items of the vault by name, the trash left out", async () => {
    const { popup } = extension;
    await popup.waitForFunction(
      () =>
        [...document.querySelectorAll(".item-row-name")].map((name) => name.textContent).join() ===
        "GitHub,Visa,wifi",
      { timeout: 20_000 },
    );
    expect(await popup.$eval(".item-row-subtitle", (subtitle) => subtitle.textContent)).toBe(
      "alice",
    );
  });

  it("searches the items as the app does, from the field focused at once", async () => {
    const { popup } = extension;
    const rows = (count: number) =>
      popup.waitForFunction(
        (count) => document.querySelectorAll(".item-row").length === count,
        {},
        count,
      );
    expect(await popup.evaluate(() => document.activeElement?.getAttribute("type"))).toBe("search");
    await extension.fill("input[type=search]", "ALICE");
    await rows(1);
    expect(await popup.$eval(".item-row-name", (name) => name.textContent)).toBe("GitHub");
    await extension.fill("input[type=search]", "bank");
    await popup.waitForSelector(`::-p-text(${english.noSearchResults})`);
    await extension.press("Escape");
    await rows(3);
  });

  it("shows an item over the list, its secrets hidden until shown", async () => {
    const { popup } = extension;
    const tiles = () =>
      popup.$$eval(".item-detail .field-tile", (tiles) =>
        tiles.map((tile) =>
          [...tile.querySelectorAll(".field-tile-label, .field-value")]
            .map((part) => part.textContent)
            .join(": "),
        ),
      );
    // The row itself, GitHub before wifi: a text selector would click the name inside it.
    await extension.click(".item-row");
    await popup.waitForFunction(() => document.activeElement?.textContent === "GitHub", {});
    expect(await tiles()).toEqual([
      "Username: alice",
      "Password: ••••••••••••",
      "Verification code",
      "Website: github.com",
      "Notes: Recovery codes in the safe",
      "PIN: ••••••••••••",
    ]);
    expect(await popup.$eval("a[aria-label='Open website']", (link) => link.href)).toBe(
      "https://github.com/",
    );
    await extension.click("button[aria-label=Show]");
    await popup.waitForFunction(() =>
      [...document.querySelectorAll(".field-value")].some(
        (value) => value.textContent === "hunter2",
      ),
    );
  });

  it("copies a field of the item", async () => {
    await extension.click(".field-tile button[aria-label=Copy]");
    await extension.popup.waitForSelector(".field-tile button[aria-label=Copied]");
    expect(await extension.readClipboard()).toBe("alice");
  });

  it("shows the verification code as it counts down, and copies it", async () => {
    const { popup } = extension;
    const shown = () => popup.$eval(".totp-code", (code) => code.textContent ?? "");
    expect(await shown()).toMatch(/^\d{3} \d{3}$/);
    const seconds = Number(await popup.$eval(".totp-seconds", (left) => left.textContent));
    expect(seconds).toBeGreaterThanOrEqual(1);
    expect(seconds).toBeLessThanOrEqual(30);
    const before = await shown();
    await extension.click(".field-tile:has(.totp-code) button[aria-label=Copy]");
    await popup.waitForSelector(".field-tile:has(.totp-code) button[aria-label=Copied]");
    const after = await shown();
    // A code may change between the two.
    expect([before, after].map((code) => code.replace(" ", ""))).toContain(
      await extension.readClipboard(),
    );
  });

  it("unfolds the password history, its passwords hidden until shown", async () => {
    const { popup } = extension;
    const trigger = "h2 > button[aria-expanded]";
    expect(await popup.$eval(trigger, (button) => button.textContent)).toBe("Password history 1");
    expect(await popup.$$(".password-history .field-tile")).toHaveLength(0);
    await extension.click(trigger);
    await popup.waitForSelector(`${trigger}[aria-expanded=true]`);
    expect(
      await popup.$eval(".password-history .field-tile-label", (label) => label.textContent),
    ).toContain("2026");
    await extension.click(".password-history button[aria-label=Show]");
    await popup.waitForFunction(
      () => document.querySelector(".password-history .field-value")?.textContent === "hunter1",
    );
  });

  it("goes back to the list with Escape, onto the item's row", async () => {
    const { popup } = extension;
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await popup.waitForFunction(
      () =>
        document.activeElement?.classList.contains("item-row") &&
        document.activeElement.textContent?.includes("GitHub"),
    );
  });

  it("copies the password of a login from its row, and tells a screen reader", async () => {
    const { popup } = extension;
    await extension.click(".item-row button[aria-label='Copy password']");
    await popup.waitForFunction(
      () => document.querySelector(".item-row [role=status]")?.textContent === "Copied",
    );
    expect(await extension.readClipboard()).toBe("hunter2");
  });

  it("shows a card in detail, its number hidden", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=Visa]");
    await popup.waitForFunction(() => document.activeElement?.textContent === "Visa");
    expect(
      await popup.$$eval(".item-detail .field-tile", (tiles) =>
        tiles.map((tile) =>
          [...tile.querySelectorAll(".field-tile-label, .field-value")]
            .map((part) => part.textContent)
            .join(": "),
        ),
      ),
    ).toEqual(["Brand: Visa", "Number: ••••••••••••", "Expiration: 03 / 2029"]);
    expect(await popup.$eval(".item-detail-meta", (meta) => meta.textContent)).toContain("Card");
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
  });

  it("syncs again at once from the sync button, which waits meanwhile", async () => {
    const { popup } = extension;
    const button = "button[aria-label='Sync now']";
    await extension.click(button);
    await popup.waitForSelector(`${button}[aria-disabled=true]`);
    await popup.waitForSelector(`${button}:not([aria-disabled])`, { timeout: 20_000 });
    expect(await popup.evaluate(() => document.activeElement?.getAttribute("aria-label"))).toBe(
      "Sync now",
    );
    expect(await popup.$eval(".sync-status", (status) => status.textContent)).toBe(
      english.syncedJustNow,
    );
  });

  it("lists the vault in the drawer, and shows it once chosen", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    const rows = await popup.waitForSelector(".drawer [role=grid]");
    expect(
      await rows?.$$eval(".drawer-row-title", (titles) => titles.map((title) => title.textContent)),
    ).toEqual(["All vaults", "Home"]);
    await extension.click(".drawer [role=row]::-p-text(Home)");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForFunction(
      () => document.querySelector(".home-title")?.textContent === "Home",
    );
  });

  it("opens the settings of a vault from the drawer, its name read first", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer [role=row] button[aria-label='Vault settings']");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForFunction(
      () =>
        document.activeElement?.matches(".vault-settings h1") &&
        document.activeElement.textContent === "Home",
    );
  });

  it("renames the vault as the name is typed, never to nothing", async () => {
    const { popup } = extension;
    const field = ".vault-settings input[name=name]";
    await extension.fill(field, "");
    await extension.press("Backspace");
    await popup.waitForSelector(`::-p-text(${english.vaultNameRequired})`);
    await extension.fill(field, "Family");
    await popup.waitForFunction(
      () =>
        document.querySelector(".vault-settings h1")?.textContent === "Family" &&
        document.querySelector(".home-title")?.textContent === "Family",
    );
  });

  it("changes the color of the vault", async () => {
    const { popup } = extension;
    await extension.click(".vault-settings .color-swatch:has(input[aria-label=Green])");
    await popup.waitForFunction(
      () =>
        (document.querySelector(".home-vaults-button .vault-avatar") as HTMLElement | null)?.style
          .background === "rgb(42, 127, 97)",
    );
  });

  it("goes back to the list with Escape, onto the vaults button", async () => {
    const { popup } = extension;
    await extension.press("Escape");
    await popup.waitForSelector(".vault-settings", { hidden: true });
    await popup.waitForFunction(
      () => document.activeElement?.getAttribute("aria-label") === "Vaults",
    );
  });

  it("refuses a vault already open", async () => {
    await extension.click("button[aria-label=Vaults]");
    await extension.click("button::-p-text(Open a vault)");
    await extension.fill("input[name=key]", nip19.nsecEncode(secretKey));
    await extension.fill("input[name=name]", "Work");
    await extension.click("button[type=submit]");
    const error = english.vaultAlreadyOpen.replace("{name}", "Family");
    await extension.popup.waitForSelector(`::-p-text(${error})`);
    await extension.click("button::-p-text(Cancel)");
  });

  it("keeps the vaults when the popup opens again, as renamed", async () => {
    await extension.reload();
    const title = await extension.popup.waitForSelector(".home-title");
    expect(await title?.evaluate((h1) => h1.textContent)).toBe("All vaults");
    await extension.click("button[aria-label=Vaults]");
    const rows = await extension.popup.waitForSelector(".drawer [role=grid]");
    expect(
      await rows?.$$eval(".drawer-row-title", (titles) => titles.map((title) => title.textContent)),
    ).toEqual(["All vaults", "Family"]);
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
