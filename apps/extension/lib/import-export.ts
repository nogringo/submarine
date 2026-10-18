import type { Cipher } from "./cipher";
import { callCore } from "./core";

/** What the settings open in a tab, from their URL's hash. */
export type FileAction = "import" | "export";

/**
 * Whether this page is the popup, which Firefox, and Chrome on macOS and Linux, close as a file
 * dialog opens: as Bitwarden does, the settings then import and export in a tab.
 */
export function inPopup(): boolean {
  return browser.extension.getViews({ type: "popup" }).includes(window);
}

/** Opens the settings in a tab, for `action`, and closes the popup. */
export async function openInTab(action: FileAction) {
  await browser.tabs.create({ url: browser.runtime.getURL(`/popup.html#${action}`) });
  window.close();
}

/** The action a tab opened by {@link openInTab} is for. */
export function tabAction(hash = location.hash): FileAction | undefined {
  if (hash === "#import") return "import";
  if (hash === "#export") return "export";
}

/** As the app names its exports, as Bitwarden does. */
export function exportFileName(now: Date, isProtected: boolean): string {
  const pad = (value: number) => String(value).padStart(2, "0");
  const stamp = [
    now.getFullYear(),
    pad(now.getMonth() + 1),
    pad(now.getDate()),
    pad(now.getHours()),
    pad(now.getMinutes()),
    pad(now.getSeconds()),
  ].join("");
  return `submarine_${isProtected ? "encrypted_" : ""}export_${stamp}.json`;
}

/** Few enough for the progress to move, and for the lists to read the vault again seldom. */
export const importBatch = 50;

/** Saves `ciphers` into `vault` a batch at a time, `onSaved` told how many are saved so far. */
export async function importCiphers(
  vault: string,
  ciphers: Cipher[],
  onSaved: (saved: number) => void,
) {
  for (let start = 0; start < ciphers.length; start += importBatch) {
    const batch = ciphers.slice(start, start + importBatch);
    await callCore("importItems", { vault, ciphers: batch });
    onSaved(start + batch.length);
  }
}
