import { readFile } from "node:fs/promises";
import { resolve } from "node:path";
import { generateSecretKey, nip19 } from "nostr-tools";
import * as nip49 from "nostr-tools/nip49";
import type { Page } from "puppeteer";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { fillPage } from "../lib/fill-page";
import { violations } from "./axe";
import { type BrowserName, type Extension, launch, openPopupOver } from "./extension";
import { publishItems } from "./vault-items";

const english = JSON.parse(await readFile(appArb("en"), "utf8"));
// Taller than the popup, for its copy button to sit below it.
const cardNotes = Array(40).fill("Kept in the wallet").join("\n");

describe.each<BrowserName>(["chrome", "firefox"])("%s", (name) => {
  const secretKey = generateSecretKey();
  let extension: Extension;
  let lockPassword = "";

  beforeAll(async () => {
    await publishItems(secretKey, [
      { type: 2, name: "wifi" },
      {
        type: 3,
        name: "Visa",
        card: { brand: "Visa", number: "4111111111111111", expMonth: "3", expYear: "2029" },
        notes: cardNotes,
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
    expect(await violations(extension.popup)).toEqual([]);
  });

  it("explains Nostr in a dialog, closed with Escape", async () => {
    const { popup } = extension;
    await extension.click("button::-p-text(Built on Nostr)");
    const dialog = await popup.waitForSelector("[role=dialog]");
    expect(await dialog?.$eval("h2", (title) => title.textContent)).toBe("Built on Nostr");
    await popup.waitForFunction(() =>
      document.querySelector("[role=dialog]")?.contains(document.activeElement),
    );
    expect(await violations(popup)).toEqual([]);
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

  it("opens and fills with keyboard shortcuts, which the browser gave it", async () => {
    const shortcuts = await extension.popup.evaluate(async () => {
      type Api = { commands: { getAll(): Promise<{ name?: string; shortcut?: string }[]> } };
      const globals = globalThis as unknown as { browser?: Api; chrome: Api };
      const commands = await (globals.browser ?? globals.chrome).commands.getAll();
      return ["_execute_action", "fill_login"].map(
        (name) => commands.find((command) => command.name === name)?.shortcut,
      );
    });
    expect(shortcuts).toEqual([expect.stringMatching(/Y|U/), expect.stringContaining("L")]);
  });

  it("refuses what is not a vault key", async () => {
    await extension.click("button::-p-text(Open a vault)");
    await extension.fill("input[name=key]", "hello");
    await extension.fill("input[name=name]", "Home");
    await extension.click("button[type=submit]");
    await extension.popup.waitForSelector(`::-p-text(${english.vaultKeyInvalid})`);
    expect(await violations(extension.popup)).toEqual([]);
  });

  it("opens a vault from its ncryptsec, once the password is right", async () => {
    const { popup } = extension;
    await extension.fill("input[name=key]", nip49.encrypt(secretKey, "a long password"));
    await extension.fill("input[name=password]", "wrong");
    await extension.click("button[type=submit]");
    await popup.waitForSelector(`::-p-text(${english.vaultKeyPasswordWrong})`);
    expect(await violations(popup)).toEqual([]);
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
    expect(await violations(popup)).toEqual([]);
  });

  it.skipIf(name === "firefox")("lists the logins for the page it opens over first", async () => {
    const { page, popup } = await openPopupOver(extension.browser, "https://github.com/login");
    try {
      await popup.waitForFunction(
        () =>
          [...document.querySelectorAll(".item-list-header, .item-row-name")]
            .map((element) => element.textContent)
            .join() === "For this site,GitHub,All items,GitHub,Visa,wifi",
        { timeout: 20_000 },
      );
      expect(await violations(popup)).toEqual([]);
      // The page has no form.
      await popup.locator(".item-row button::-p-text(Fill)").click();
      const alert = await popup.waitForSelector("[role=alert]:not(:empty)");
      expect(await alert?.evaluate((alert) => alert.textContent)).toBe(
        "No sign-in form to fill on this page.",
      );
      expect(await violations(popup)).toEqual([]);
    } finally {
      if (!popup.isClosed()) await popup.close();
      await page.close();
      await extension.popup.bringToFront();
    }
  });

  it.skipIf(name === "firefox")("fills the login into the page, then closes", async () => {
    const { page, popup } = await openPopupOver(
      extension.browser,
      "https://github.com/login",
      signInForm,
    );
    try {
      const closed = new Promise((resolve) => popup.once("close", resolve));
      await popup.locator(".item-row button::-p-text(Fill)").click();
      await closed;
      // The verification code, which the site asks for next.
      expect(await extension.readClipboard()).toMatch(/^\d{6}$/);
      expect(await fieldValues(page)).toEqual({
        search: "",
        login: "alice",
        decoy: "",
        password: "hunter2",
      });
    } finally {
      if (!popup.isClosed()) await popup.close();
      await page.close();
      await extension.popup.bringToFront();
    }
  });

  it("fills the fields a person sees, of the sign-in form", async () => {
    const page = await extension.browser.newPage();
    try {
      const fill = async (html: string, username = "alice") => {
        await page.setContent(html);
        const origin = await page.evaluate(() => location.origin);
        const filled = await page.evaluate(fillPage, origin, username, "hunter2");
        return { filled, ...(await fieldValues(page)) };
      };
      expect(await fill(signInForm)).toEqual({
        filled: true,
        search: "",
        login: "alice",
        decoy: "",
        password: "hunter2",
      });
      // A sign-in that asks for the username first.
      expect(
        await fill(
          '<input name="search"><form><input name="login" autocomplete="username"></form>',
        ),
      ).toEqual({ filled: true, search: "", login: "alice" });
      expect(await fill('<input name="search">')).toEqual({ filled: false, search: "" });
      await page.setContent(signInForm);
      expect(await page.evaluate(fillPage, "https://other.example", "alice", "hunter2")).toBe(
        false,
      );
      expect(await fieldValues(page)).toEqual({ search: "", login: "", decoy: "", password: "" });
    } finally {
      await page.close();
      // Firefox shows the popup's tab again by itself, and refuses to bring an extension page front.
      if (name === "chrome") await extension.popup.bringToFront();
    }
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
    expect(await violations(popup)).toEqual([]);
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
    expect(await violations(popup)).toEqual([]);
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
    ).toEqual([
      "Brand: Visa",
      "Number: ••••••••••••",
      "Expiration: 03 / 2029",
      `Notes: ${cardNotes}`,
    ]);
    expect(await popup.$eval(".item-detail-meta", (meta) => meta.textContent)).toContain("Card");
    // The item scrolls on its own, the popup under it does not.
    expect(
      await popup.evaluate(
        () => document.documentElement.scrollHeight - document.documentElement.clientHeight,
      ),
    ).toBe(0);
    expect(await violations(popup)).toEqual([]);
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
  });

  it("shows the item again as the popup opens again, until back to the list", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=GitHub]");
    await popup.waitForFunction(() => document.activeElement?.textContent === "GitHub");
    await extension.reload();
    await popup.waitForFunction(() => document.activeElement?.textContent === "GitHub");
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await popup.waitForFunction(() => document.activeElement?.matches(".search-field-input"));
    await extension.reload();
    await popup.waitForSelector(".home-title");
    expect(await popup.$(".item-detail")).toBeNull();
  });

  /** Waits for the rows of the list to name `names`, joined by commas. */
  const rowNames = (names: string) =>
    extension.popup.waitForFunction(
      (names) =>
        [...document.querySelectorAll(".item-row-name")].map((name) => name.textContent).join() ===
        names,
      {},
      names,
    );

  it("filters the items with the app's chips, the trash among them", async () => {
    const { popup } = extension;
    // Shown once the types of the items are read.
    await popup.waitForSelector(".filter-chips .chip");
    expect(await popup.$$eval(".chip", (chips) => chips.map((chip) => chip.textContent))).toEqual([
      "All",
      "Favorites",
      "Logins",
      "Cards",
      "Secure notes",
      "Trash",
    ]);
    await extension.click(".chip::-p-text(Trash)");
    await rowNames("Old bank");
    expect(await violations(popup)).toEqual([]);
    await extension.click(".chip::-p-text(Cards)");
    await rowNames("Visa");
    await extension.click(".chip::-p-text(Favorites)");
    await popup.waitForSelector(`::-p-text(${english.noItemsHere})`);
    await extension.click(".chip::-p-text(All)");
    await rowNames("GitHub,Visa,wifi");
  });

  it("adds an item to the favorites from its page", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=wifi]");
    await popup.waitForFunction(() => document.activeElement?.textContent === "wifi");
    await extension.click("button[aria-label='Add to favorites']");
    await popup.waitForSelector("button[aria-label='Remove from favorites']");
    expect(await violations(popup)).toEqual([]);
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await extension.click(".chip::-p-text(Favorites)");
    await rowNames("wifi");
    await extension.click(".chip::-p-text(All)");
    await rowNames("GitHub,Visa,wifi");
  });

  it("moves an item to the trash from its menu, then out of it", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=wifi]");
    await popup.waitForFunction(() => document.activeElement?.textContent === "wifi");
    await extension.click("button[aria-label='More actions']");
    await popup.waitForSelector("[role=menu]");
    expect(await violations(popup)).toEqual([]);
    await extension.click("[role=menuitem]::-p-text(Move to trash)");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await rowNames("GitHub,Visa");
    await popup.waitForFunction(() => document.activeElement?.matches(".search-field-input"));
    await extension.click(".chip::-p-text(Trash)");
    await rowNames("Old bank,wifi");
    await extension.click(".item-row[aria-label=wifi]");
    await extension.click("button::-p-text(Restore)");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await rowNames("Old bank");
  });

  it("deletes an item in the trash for good, once confirmed", async () => {
    const { popup } = extension;
    const deleteFromMenu = async () => {
      await extension.click("button[aria-label='More actions']");
      await extension.click("[role=menuitem]::-p-text(Delete permanently)");
      await popup.waitForSelector(`[role=alertdialog]::-p-text(${english.deleteItemTitle})`);
    };
    await extension.click(".item-row[aria-label='Old bank']");
    await popup.waitForFunction(() => document.activeElement?.textContent === "Old bank");
    await deleteFromMenu();
    expect(await violations(popup)).toEqual([]);
    await extension.press("Escape");
    await popup.waitForSelector("[role=alertdialog]", { hidden: true });
    expect(await popup.$(".item-detail")).not.toBeNull();
    await deleteFromMenu();
    await extension.click("[role=alertdialog] button::-p-text(Delete)");
    await popup.waitForSelector(".item-detail", { hidden: true });
    await popup.waitForSelector(`::-p-text(${english.noItemsHere})`);
    await extension.click(".chip::-p-text(All)");
    await rowNames("GitHub,Visa,wifi");
  });

  it("opens the menu of a row where it is right-clicked, and copies from it", async () => {
    const { popup } = extension;
    await extension.rightClick(".item-row[aria-label=GitHub]");
    await popup.waitForSelector("[role=menu]");
    expect(
      await popup.$$eval("[role=menuitem]", (items) => items.map((item) => item.textContent)),
    ).toEqual([
      english.copyUsername,
      english.copyPassword,
      english.copyTotp,
      english.addToFavorites,
      english.edit,
      english.moveToTrash,
    ]);
    expect(await violations(popup)).toEqual([]);
    await extension.click(`[role=menuitem]::-p-text(${english.copyUsername})`);
    await popup.waitForSelector("[role=menu]", { hidden: true });
    await popup.waitForFunction(() =>
      document.activeElement?.matches(".item-row[aria-label=GitHub]"),
    );
    // Told a screen reader once copied, as nothing shows it.
    await popup.waitForFunction(
      () => document.querySelector(".home-status")?.textContent === "Copied",
    );
    expect(await extension.readClipboard()).toBe("alice");
  });

  it("moves an item to the trash from its row's menu, and restores it", async () => {
    const { popup } = extension;
    await extension.rightClick(".item-row[aria-label=wifi]");
    await extension.click(`[role=menuitem]::-p-text(${english.moveToTrash})`);
    await rowNames("GitHub,Visa");
    await extension.click(".chip::-p-text(Trash)");
    await extension.rightClick(".item-row[aria-label=wifi]");
    await extension.click(`[role=menuitem]::-p-text(${english.restore})`);
    await popup.waitForSelector(`::-p-text(${english.noItemsHere})`);
    await extension.click(".chip::-p-text(All)");
    await rowNames("GitHub,Visa,wifi");
  });

  /** The labels of the item's fields, then of its custom fields. */
  const fieldLabels = () =>
    extension.popup.$$eval(".item-detail .field-tile-label", (labels) =>
      labels.map((label) => label.textContent),
    );
  const save = ".item-form .page-bar button[type=submit]";

  it("creates a login from the New item menu, and shows it once saved", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label='New item']");
    await extension.click("[role=menuitem]::-p-text(Login)");
    await popup.waitForSelector(`.item-form .page-bar-title::-p-text(${english.newLogin})`);
    await popup.waitForSelector(`${save}[disabled]`);
    expect(await violations(popup)).toEqual([]);
    await extension.fill(".item-form input[name=name]", "Forum");
    await extension.fill(".item-form input[name=username]", "bob");
    await extension.fill(".item-form input[name=password]", "correct horse");
    await extension.click("button::-p-text(Add a field)");
    await extension.click("[role=menuitem]::-p-text(Custom field)");
    await popup.waitForSelector(`[role=dialog]::-p-text(${english.addField})`);
    expect(await violations(popup)).toEqual([]);
    await extension.fill("[role=dialog] input[type=text]", "PIN");
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await extension.fill(".custom-field input", "0000");
    await extension.click("button::-p-text(Add a field)");
    await extension.click("[role=menuitem]::-p-text(First name)");
    await popup.waitForFunction(() => document.querySelectorAll(".custom-field").length === 2);
    await popup.$eval(".custom-field:nth-child(2) .custom-field-handle", (handle) =>
      (handle as HTMLElement).focus(),
    );
    await extension.press("ArrowUp");
    await popup.waitForFunction(
      () =>
        document.querySelector(".custom-fields [role=status]")?.textContent ===
        "First name: position 1 of 2",
    );
    expect(await popup.evaluate(() => document.activeElement?.getAttribute("aria-label"))).toBe(
      "Move First name",
    );
    expect(await violations(popup)).toEqual([]);
    await extension.click(save);
    await popup.waitForSelector(".item-form", { hidden: true });
    await popup.waitForFunction(() => document.activeElement?.textContent === "Forum");
    expect(await fieldLabels()).toEqual(["Username", "Password", "First name", "PIN"]);
    await extension.press("Escape");
    await rowNames("Forum,GitHub,Visa,wifi");
  });

  it("edits a login, what the form leaves out kept", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=GitHub]");
    await extension.click(".item-detail button::-p-text(Edit)");
    await popup.waitForSelector(`.item-form .page-bar-title::-p-text(${english.editItem})`);
    expect(await popup.$eval(".item-form input[name=username]", (input) => input.value)).toBe(
      "alice",
    );
    await extension.fill(".item-form input[name=username]", "alice@example.com");
    await extension.click(save);
    await popup.waitForSelector(".item-form", { hidden: true });
    await popup.waitForFunction(() =>
      [...document.querySelectorAll(".item-detail .field-value")].some(
        (value) => value.textContent === "alice@example.com",
      ),
    );
    expect(await fieldLabels()).toEqual([
      "Username",
      "Password",
      "Verification code",
      "Website",
      "Notes",
      "PIN",
    ]);
    expect(await popup.$eval("h2 > button[aria-expanded]", (button) => button.textContent)).toBe(
      "Password history 1",
    );
    await extension.press("Escape");
    await popup.waitForSelector(".item-detail", { hidden: true });
  });

  it("asks before leaving a form changed, and keeps editing on Escape", async () => {
    const { popup } = extension;
    await extension.click(".item-row[aria-label=wifi]");
    await extension.click(".item-detail button::-p-text(Edit)");
    await extension.fill(".item-form input[name=name]", "Home wifi");
    await extension.press("Escape");
    await popup.waitForSelector(`[role=alertdialog]::-p-text(${english.discardChanges})`);
    expect(await violations(popup)).toEqual([]);
    await extension.press("Escape");
    await popup.waitForSelector("[role=alertdialog]", { hidden: true });
    expect(await popup.$eval(".item-form input[name=name]", (input) => input.value)).toBe(
      "Home wifi",
    );
    await extension.click(".item-form .page-bar button::-p-text(Cancel)");
    await extension.click(`[role=alertdialog] button::-p-text(${english.discard})`);
    await popup.waitForSelector(".item-form", { hidden: true });
    await popup.waitForFunction(() => document.activeElement?.textContent === "wifi");
    await extension.press("Escape");
    await rowNames("Forum,GitHub,Visa,wifi");
  });

  it("shows a form left unsaved again as the popup opens again, until discarded", async () => {
    const { popup } = extension;
    const name = ".item-form input[name=name]";
    await extension.click(".item-row[aria-label=wifi]");
    await extension.click(".item-detail button::-p-text(Edit)");
    await extension.fill(name, "Home wifi");
    await extension.reload();
    await popup.waitForFunction(
      (name) => document.querySelector<HTMLInputElement>(name)?.value === "Home wifi",
      {},
      name,
    );
    await extension.click(".item-form .page-bar button::-p-text(Cancel)");
    await extension.click(`[role=alertdialog] button::-p-text(${english.discard})`);
    await popup.waitForSelector(".item-form", { hidden: true });
    await extension.reload();
    await popup.waitForFunction(() => document.activeElement?.textContent === "wifi");
    expect(await popup.$(".item-form")).toBeNull();
    await extension.press("Escape");
    await rowNames("Forum,GitHub,Visa,wifi");
  });

  it("fills a new login's password and username from the generator, in a sheet", async () => {
    const { popup } = extension;
    const generated = async (title: string) => {
      await popup.waitForSelector(`.sheet .sheet-title::-p-text(${title})`);
      const value = await popup.waitForSelector(".sheet .generator-preview .field-value");
      return value?.evaluate((value) => String(value.textContent));
    };
    await extension.click("button[aria-label='New item']");
    await extension.click("[role=menuitem]::-p-text(Login)");
    await extension.click(`button[aria-label='${english.generatePassword}']`);
    const password = await generated(english.generator);
    expect(password).toMatch(/^[A-Za-z0-9]{14}$/);
    expect(await violations(popup)).toEqual([]);
    await extension.click(`.sheet button::-p-text(${english.usePassword})`);
    await popup.waitForSelector(".sheet", { hidden: true });
    expect(await popup.$eval(".item-form input[name=password]", (input) => input.value)).toBe(
      password,
    );
    await popup.waitForFunction(
      (label) => document.activeElement?.getAttribute("aria-label") === label,
      {},
      english.generatePassword,
    );
    await extension.click(`button[aria-label='${english.generateUsername}']`);
    const username = await generated(english.generateUsername);
    await extension.click(`.sheet button::-p-text(${english.useUsername})`);
    await popup.waitForSelector(".sheet", { hidden: true });
    expect(await popup.$eval(".item-form input[name=username]", (input) => input.value)).toBe(
      username,
    );
    await extension.click(`button[aria-label='${english.generateUsername}']`);
    await generated(english.generateUsername);
    await extension.click(`.sheet button[aria-label='${english.close}']`);
    await popup.waitForSelector(".sheet", { hidden: true });
    expect(await popup.$eval(".item-form input[name=username]", (input) => input.value)).toBe(
      username,
    );
    await extension.click(".item-form .page-bar button::-p-text(Cancel)");
    await extension.click(`[role=alertdialog] button::-p-text(${english.discard})`);
    await popup.waitForSelector(".item-form", { hidden: true });
  });

  it.skipIf(name === "firefox")("names a new login after the page it opens over", async () => {
    const { page, popup } = await openPopupOver(extension.browser, "https://www.example.com/a?b");
    try {
      await popup.locator("button[aria-label='New item']").click();
      await popup.locator("[role=menuitem]::-p-text(Login)").click();
      await popup.waitForSelector(".item-form");
      expect(
        await popup.$$eval(".item-form input[type=text]", (inputs) =>
          inputs.map((input) => input.value).filter((value) => value),
        ),
      ).toEqual(["example.com", "https://www.example.com"]);
      expect(await popup.$(`${save}[disabled]`)).toBeNull();
    } finally {
      if (!popup.isClosed()) await popup.close();
      await page.close();
      await extension.popup.bringToFront();
    }
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
    // The status reads the states again once the core tells they changed, after the button.
    await expect
      .poll(() => popup.$eval(".sync-status", (status) => status.textContent), {
        timeout: 10_000,
      })
      .toBe(english.syncedJustNow);
  });

  it("lists the vault in the drawer, and shows it once chosen", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    const rows = await popup.waitForSelector(".drawer [role=grid]");
    expect(
      await rows?.$$eval(".drawer-row-title", (titles) => titles.map((title) => title.textContent)),
    ).toEqual(["All vaults", "Home"]);
    expect(await violations(popup)).toEqual([]);
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
    expect(await violations(popup)).toEqual([]);
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

  it("opens the generator from the drawer, its options kept for the next time", async () => {
    const { popup } = extension;
    const preview = ".generator-page .generator-preview .field-value";
    const generated = (pattern: RegExp) =>
      popup.waitForFunction(
        (preview, pattern) =>
          new RegExp(pattern).test(document.querySelector(preview)?.textContent ?? ""),
        {},
        preview,
        pattern.source,
      );
    const openGenerator = async () => {
      await extension.click("button[aria-label=Vaults]");
      await extension.click(`.drawer button::-p-text(${english.generator})`);
      await popup.waitForSelector(preview);
    };
    await openGenerator();
    expect(await popup.evaluate(() => document.activeElement?.textContent)).toBe(english.generator);
    expect(await violations(popup)).toEqual([]);
    await extension.click(`.chip[aria-label^='${english.specialCharacters}']`);
    await generated(/^(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{14}$/);
    // The length's Increase button.
    await extension.click(".generator-options > .count-field:first-child button:last-child");
    await generated(/^.{15}$/);
    // Words of EFF's list, some of them hyphenated.
    await extension.click(`.chip::-p-text(${english.passphrase})`);
    await generated(/^[a-z]+(-[a-z]+){5,}$/);
    expect(await violations(popup)).toEqual([]);
    await extension.press("Escape");
    await popup.waitForSelector(".generator-page", { hidden: true });
    await openGenerator();
    await popup.waitForSelector(`.chip[aria-checked=true]::-p-text(${english.passphrase})`);
    await extension.click(`.chip::-p-text(${english.password})`);
    await generated(/^(?=.*[!@#$%^&*])[A-Za-z0-9!@#$%^&*]{15}$/);
    await extension.press("Escape");
    await popup.waitForSelector(".generator-page", { hidden: true });
  });

  it("opens the settings from the drawer", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer button::-p-text(Settings)");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForFunction(
      () =>
        document.activeElement?.matches(".settings h1") &&
        document.activeElement.textContent === "Settings",
    );
  });

  it("empties the clipboard of a password after the delay chosen", async () => {
    const { popup } = extension;
    const select = ".settings .select-tile-button";
    // Shown once the delay is read.
    await popup.waitForSelector(select);
    expect(await popup.$eval(select, (button) => button.textContent)).toContain("30 seconds");
    await extension.click(select);
    await popup.waitForSelector("[role=option]");
    expect(await violations(popup)).toEqual([]);
    await extension.click("[role=option]::-p-text(10 seconds)");
    await popup.waitForFunction(
      (select) => document.querySelector(select)?.textContent?.includes("10 seconds"),
      {},
      select,
    );
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    await extension.click(".item-row[aria-label=GitHub] button[aria-label='Copy password']");
    await popup.waitForFunction(
      () =>
        document.querySelector(".item-row[aria-label=GitHub] [role=status]")?.textContent ===
        "Copied",
    );
    const copied = Date.now();
    expect(await extension.readClipboard()).toBe("hunter2");
    // Firefox refused, once, a read made as the background emptied the clipboard.
    const read = () =>
      extension.readClipboard().catch((error: Error) => {
        if (!String(error).includes("NotAllowedError")) throw error;
      });
    while ((await read()) !== "") {
      expect(Date.now() - copied).toBeLessThan(20_000);
      await new Promise((wait) => setTimeout(wait, 500));
    }
    expect(Date.now() - copied).toBeGreaterThan(9_000);
  });

  it("sets a lock password in the settings, 12 characters long at least", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer button::-p-text(Settings)");
    await extension.click(".settings button::-p-text(Set up)");
    await extension.fill("[role=dialog] input[name=password]", "too short");
    await extension.fill("[role=dialog] input[name=confirmation]", "too short");
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForFunction(
      (error) => document.querySelector("[role=dialog] .text-field-error")?.textContent === error,
      {},
      english.passwordMinLength.replace("{count}", "12"),
    );
    expect(await violations(popup)).toEqual([]);
    await extension.click("[role=dialog] button::-p-text(Generate a passphrase)");
    await popup.waitForFunction(() => {
      const [password, confirmation] =
        document.querySelectorAll<HTMLInputElement>("[role=dialog] input");
      return (
        password?.type === "text" &&
        password.value.length >= 12 &&
        password.value === confirmation?.value
      );
    });
    lockPassword = await popup.$eval(
      "[role=dialog] input[name=password]",
      (input) => (input as HTMLInputElement).value,
    );
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await popup.waitForSelector(".settings button::-p-text(Set up)", { hidden: true });
  });

  it("locks the vaults from the list, behind the lock password", async () => {
    const { popup } = extension;
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    await extension.click("button[aria-label=Lock]");
    await popup.waitForSelector(`::-p-text(${english.vaultsLocked})`);
    expect(await popup.$(".home")).toBeNull();
    await extension.fill("input[name=password]", "not the lock password");
    await extension.click("button[type=submit]");
    await popup.waitForSelector(`::-p-text(${english.wrongLockPassword})`);
    expect(await violations(popup)).toEqual([]);
    await extension.fill("input[name=password]", lockPassword);
    await extension.click("button[type=submit]");
    await popup.waitForSelector(".home-title");
  });

  it("stays unlocked as the popup opens again, until the browser closes", async () => {
    const { popup } = extension;
    await extension.reload();
    await popup.waitForSelector(".home-title");
    // As the browser does once it closes.
    await popup.evaluate(() => {
      type Api = { storage: { session: { clear(): Promise<void> } } };
      const globals = globalThis as unknown as { browser?: Api; chrome: Api };
      return (globals.browser ?? globals.chrome).storage.session.clear();
    });
    await extension.reload();
    await popup.waitForSelector(`::-p-text(${english.vaultsLocked})`);
    await extension.fill("input[name=password]", lockPassword);
    await extension.click("button[type=submit]");
    await popup.waitForSelector(".home-title");
  });

  it("locks as the popup closes, once set to lock immediately, the item shown forgotten", async () => {
    const { popup } = extension;
    const choose = async (from: string, to: string) => {
      await extension.click("button[aria-label=Vaults]");
      await extension.click(".drawer button::-p-text(Settings)");
      // Shown once the core tells the timeout.
      await popup.waitForSelector(`.settings .select-tile-button::-p-text(${from})`);
      await extension.click(`.settings .select-tile-button::-p-text(${from})`);
      await extension.click(`[role=option]::-p-text(${to})`);
      await popup.waitForSelector(`.settings .select-tile-button::-p-text(${to})`);
    };
    await choose("5 minutes", english.lockImmediately);
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    await extension.click(".item-row[aria-label=GitHub]");
    await popup.waitForSelector(".item-detail");
    await extension.reload();
    await popup.waitForSelector(`::-p-text(${english.vaultsLocked})`);
    await extension.fill("input[name=password]", lockPassword);
    await extension.click("button[type=submit]");
    await popup.waitForSelector(".home-title");
    expect(await popup.$(".item-detail")).toBeNull();
    await choose(english.lockImmediately, "On browser restart");
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
  });

  it("changes the lock password, once given the current one", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer button::-p-text(Settings)");
    await extension.click(".settings button::-p-text(Change)");
    // Nothing kept from the password typed before, in the dialog that set it.
    await popup.waitForSelector("[role=dialog] input[name=current]");
    expect(
      await popup.$$eval("[role=dialog] input", (inputs) =>
        inputs.map((input) => (input as HTMLInputElement).value),
      ),
    ).toEqual(["", "", ""]);
    await extension.fill("[role=dialog] input[name=current]", "not the lock password");
    await extension.fill("[role=dialog] input[name=password]", "a new lock password");
    await extension.fill("[role=dialog] input[name=confirmation]", "a new lock password");
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForFunction(
      (error) => document.querySelector("[role=dialog] .text-field-error")?.textContent === error,
      {},
      english.wrongLockPassword,
    );
    await extension.fill("[role=dialog] input[name=current]", lockPassword);
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    lockPassword = "a new lock password";
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    await extension.click("button[aria-label=Lock]");
    await extension.fill("input[name=password]", lockPassword);
    await extension.click("button[type=submit]");
    await popup.waitForSelector(".home-title");
  });

  it("removes the lock password, once given the current one", async () => {
    const { popup } = extension;
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer button::-p-text(Settings)");
    await extension.click(".settings button::-p-text(Remove)");
    await extension.fill("[role=dialog] input[name=current]", lockPassword);
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    // In place of the button pressed, gone with the password.
    await popup.waitForFunction(() => document.activeElement?.textContent === "Set up");
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    expect(await popup.$("button[aria-label=Lock]")).toBeNull();
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

  it("asks before removing a vault from this device, and keeps it on Escape", async () => {
    const { popup } = extension;
    await extension.click(".drawer [role=row] button[aria-label='Vault settings']");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await extension.click(".vault-settings .settings-tile button");
    const dialog = await popup.waitForSelector("[role=alertdialog]");
    expect(await dialog?.$eval("h2", (title) => title.textContent)).toBe(
      english.removeVaultTitle.replace("{name}", "Family"),
    );
    expect(await violations(popup)).toEqual([]);
    // Waited for after axe: in Firefox under load, the focus can leave the dialog during the check.
    await popup.waitForFunction(() =>
      document.querySelector("[role=alertdialog]")?.contains(document.activeElement),
    );
    await extension.press("Escape");
    await popup.waitForSelector("[role=alertdialog]", { hidden: true });
    expect(await popup.$(".vault-settings")).not.toBeNull();
  });

  it("removes the vault from this device, for good", async () => {
    const { popup } = extension;
    await extension.click(".vault-settings .settings-tile button");
    await extension.click("[role=alertdialog] button::-p-text(Remove)");
    await popup.waitForSelector(".tagline");
    await extension.reload();
    await popup.waitForSelector(".tagline");
  });
});

describe.each<BrowserName>(["chrome", "firefox"])("%s, the lock password forgotten", (name) => {
  let extension: Extension;

  beforeAll(async () => {
    extension = await launch(name);
  });

  afterAll(async () => {
    await extension?.browser.close();
  });

  it("removes the vaults from this device, and the lock password with them", async () => {
    const { popup } = extension;
    await extension.click("button::-p-text(Open a vault)");
    await extension.fill("input[name=key]", nip19.nsecEncode(generateSecretKey()));
    await extension.fill("input[name=name]", "Home");
    await extension.click("button[type=submit]");
    await popup.waitForSelector(".home-title");
    await extension.click("button[aria-label=Vaults]");
    await extension.click(".drawer button::-p-text(Settings)");
    await extension.click(".settings button::-p-text(Set up)");
    await extension.fill("[role=dialog] input[name=password]", "a forgotten password");
    await extension.fill("[role=dialog] input[name=confirmation]", "a forgotten password");
    await extension.click("[role=dialog] button[type=submit]");
    await popup.waitForSelector("[role=dialog]", { hidden: true });
    await extension.press("Escape");
    await popup.waitForSelector(".settings", { hidden: true });
    await extension.click("button[aria-label=Lock]");
    await extension.click(`button::-p-text(${english.forgotLockPassword})`);
    await popup.waitForSelector("[role=alertdialog]");
    expect(await violations(popup)).toEqual([]);
    await extension.click(`[role=alertdialog] button::-p-text(${english.forgetVaults})`);
    await popup.waitForSelector(".tagline");
    await extension.reload();
    await popup.waitForSelector(".tagline");
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

/** A search field above a sign-in form, with a field hidden from people before its password. */
const signInForm = `
  <input name="search" placeholder="Search">
  <form>
    <input name="login" type="email">
    <input name="decoy" style="display: none">
    <input name="password" type="password">
  </form>`;

/** The values of the page's fields, by name. */
function fieldValues(page: Page): Promise<Record<string, string>> {
  return page.$$eval("input", (inputs) =>
    Object.fromEntries(inputs.map((input) => [input.name, input.value])),
  );
}

function appArb(locale: string) {
  return resolve(import.meta.dirname, `../../app/lib/l10n/app_${locale}.arb`);
}
