/** What the popup asks the background: to fill a login into the page of a tab. */
export interface FillRequest {
  fill: { tabId: number; vault: string; id: string };
}

export function isFillRequest(message: unknown): message is FillRequest {
  return typeof message === "object" && message !== null && "fill" in message;
}

/** The keyboard shortcut's, as the manifest names it. */
export const fillCommand = "fill_login";

/** Fills the login `id` of the vault `vault` into the page of the tab `tabId`. Whether it did. */
export async function fillLogin(tabId: number, vault: string, id: string): Promise<boolean> {
  const request: FillRequest = { fill: { tabId, vault, id } };
  return (await browser.runtime.sendMessage(request)) === true;
}
