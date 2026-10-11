/** How long a copied secret stays in the clipboard, the app's default. */
export const clipboardDelay = 30_000;

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
  const request: ClipboardRequest = { clearClipboardAfter: sensitive ? clipboardDelay : null };
  await browser.runtime.sendMessage(request);
}
