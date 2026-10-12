import type { Browser } from "wxt/browser";
import { copySecret } from "./clipboard-host";
import { callLoadedCore, fromExtensionPage, type SubmarineCore } from "./core-host";
import { type FillRequest, fillCommand, isFillRequest } from "./fill";
import { fillPage } from "./fill-page";

/** Fills what the popups ask for, and the first login for the tab from the keyboard shortcut. */
export function followFillRequests(core: SubmarineCore) {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (!fromExtensionPage(sender) || !isFillRequest(message)) return;
    void fillLogin(core, message.fill).then(sendResponse);
    return true;
  });
  browser.commands.onCommand.addListener((command, tab) => {
    if (command === fillCommand) void fillFromShortcut(core, tab);
  });
}

/**
 * Fills the login `id` of the vault `vault` into the page of the tab `tabId`, once the page's address
 * matches the login, in the page's top frame, then copies its verification code, as Bitwarden does:
 * the site asks for it next. Whether a field took the login.
 */
export async function fillLogin(
  core: SubmarineCore,
  { tabId, vault, id }: FillRequest["fill"],
  copy = copySecret,
): Promise<boolean> {
  try {
    const { url } = await browser.tabs.get(tabId);
    if (!url) return false;
    const forPage = await callLoadedCore(core, "items", { vault, url });
    if (!forPage.some((item) => item.id === id)) return false;
    const login = (await callLoadedCore(core, "item", { vault, id }))?.cipher.login;
    if (!login) return false;
    const [injection] = await browser.scripting.executeScript({
      target: { tabId },
      func: fillPage,
      args: [new URL(url).origin, login.username, login.password],
    });
    const filled = injection?.result === true;
    if (filled && login.totp) await copyCode(core, login.totp, copy);
    return filled;
  } catch (error) {
    // A tab closed since, or a page the browser keeps extensions out of.
    console.warn("Filling failed", error);
    return false;
  }
}

/** Without failing the fill it follows. */
async function copyCode(core: SubmarineCore, key: string, copy: (secret: string) => Promise<void>) {
  try {
    await copy((await callLoadedCore(core, "totp", { key, at: Date.now() })).code);
  } catch (error) {
    console.warn("Copying the verification code failed", error);
  }
}

/**
 * Fills the first login for the page of `tab`, or opens the popup where it cannot, the vaults
 * locked or no login for the page.
 */
export async function fillFromShortcut(core: SubmarineCore, tab: Browser.tabs.Tab | undefined) {
  if (await fillFirstLogin(core, tab?.id)) {
    await callLoadedCore(core, "used", {});
    return;
  }
  // Firefox may refuse once the user's action is behind an await.
  await browser.action.openPopup().catch(() => {});
}

async function fillFirstLogin(core: SubmarineCore, tabId: number | undefined): Promise<boolean> {
  if (tabId === undefined) return false;
  try {
    if ((await callLoadedCore(core, "lockState", {})).locked) return false;
    const { url } = await browser.tabs.get(tabId);
    const [first] = url ? await callLoadedCore(core, "items", { url }) : [];
    return !!first && (await fillLogin(core, { tabId, vault: first.vault, id: first.id }));
  } catch (error) {
    console.warn("Filling from the shortcut failed", error);
    return false;
  }
}
