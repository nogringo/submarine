import { clipboardTimeouts, readClipboardTimeout } from "./clipboard";
import { keepBackgroundAlive } from "./core-host";

let pendingClear: {
  timer: ReturnType<typeof setTimeout>;
  keepAlive: ReturnType<typeof setInterval>;
};

/**
 * Empties the clipboard in `afterMs`, unless asked again first: a new copy replaces the one to
 * clear. Keeps the background alive until then.
 */
export function clearClipboardLater(afterMs: number | null, clear = clearClipboard) {
  if (pendingClear) {
    clearTimeout(pendingClear.timer);
    clearInterval(pendingClear.keepAlive);
  }
  if (afterMs === null) return;
  const keepAlive = keepBackgroundAlive();
  const timer = setTimeout(() => {
    clearInterval(keepAlive);
    void clear();
  }, afterMs);
  pendingClear = { timer, keepAlive };
}

/** Copies `secret` from the background, and empties the clipboard after the delay chosen. */
export async function copySecret(secret: string) {
  await writeClipboard(secret);
  clearClipboardLater(clipboardTimeouts[await readClipboardTimeout()]);
}

function clearClipboard() {
  return writeClipboard("");
}

/** What the background asks its offscreen document, in Chrome: to copy `offscreenCopy`. */
export interface OffscreenCopyRequest {
  offscreenCopy: string;
}

export function isOffscreenCopyRequest(message: unknown): message is OffscreenCopyRequest {
  return typeof message === "object" && message !== null && "offscreenCopy" in message;
}

/**
 * Chrome's service worker has no document to copy from: an offscreen document copies. Firefox's
 * background is a page, which copies itself.
 */
async function writeClipboard(text: string) {
  if (!browser.offscreen) {
    copyIn(document, text);
    return;
  }
  const url = browser.runtime.getURL("/offscreen.html");
  const open = await browser.runtime.getContexts({
    contextTypes: ["OFFSCREEN_DOCUMENT"],
    documentUrls: [url],
  });
  if (open.length === 0) {
    await browser.offscreen.createDocument({
      url,
      reasons: ["CLIPBOARD"],
      justification:
        "Copy the verification code of a login filled into a page, and empty the clipboard of a copied secret after the delay chosen.",
    });
  }
  const request: OffscreenCopyRequest = { offscreenCopy: text };
  await browser.runtime.sendMessage(request);
  await browser.offscreen.closeDocument();
}

/**
 * Copies `text` through a copy event: the Clipboard API asks for a focused page, which a background
 * has not.
 */
export function copyIn(page: Document, text: string) {
  page.addEventListener(
    "copy",
    (event) => {
      event.clipboardData?.setData("text/plain", text);
      event.preventDefault();
    },
    { once: true },
  );
  page.execCommand("copy");
}
