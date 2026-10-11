/** How long a copied secret may stay in the clipboard, in milliseconds, as the app offers. */
export const clipboardTimeouts = {
  never: null,
  tenSeconds: 10_000,
  twentySeconds: 20_000,
  thirtySeconds: 30_000,
  oneMinute: 60_000,
  twoMinutes: 120_000,
  fiveMinutes: 300_000,
} as const;

export type ClipboardTimeout = keyof typeof clipboardTimeouts;

/** The app's key and names, in `storage.local`. */
const clipboardKey = "clipboard";

/** The timeout chosen on this device, the app's default until one is. */
export async function readClipboardTimeout(): Promise<ClipboardTimeout> {
  const saved = (await browser.storage.local.get(clipboardKey))[clipboardKey];
  return typeof saved === "string" && saved in clipboardTimeouts
    ? (saved as ClipboardTimeout)
    : "thirtySeconds";
}

export async function saveClipboardTimeout(timeout: ClipboardTimeout) {
  await browser.storage.local.set({ [clipboardKey]: timeout });
}

/** What the popup asks the background, which outlives it, after each copy. */
export interface ClipboardRequest {
  /** Milliseconds before the clipboard is emptied, null to keep it as is. */
  clearClipboardAfter: number | null;
}

export function isClipboardRequest(message: unknown): message is ClipboardRequest {
  return typeof message === "object" && message !== null && "clearClipboardAfter" in message;
}

/**
 * Copies `text`. A `sensitive` copy leaves the clipboard after the delay, unless something else is
 * copied first, as in the app. The background empties it, as the popup is often closed by then.
 */
export async function copyToClipboard(text: string, { sensitive }: { sensitive: boolean }) {
  await navigator.clipboard.writeText(text);
  const request: ClipboardRequest = {
    clearClipboardAfter: sensitive ? clipboardTimeouts[await readClipboardTimeout()] : null,
  };
  await browser.runtime.sendMessage(request);
}
