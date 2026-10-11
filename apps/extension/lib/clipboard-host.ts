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

/** The message the background sends its offscreen document, in Chrome. */
export const emptyClipboardMessage = "emptyClipboard";

/**
 * Chrome's service worker has no document to copy from: an offscreen document empties the
 * clipboard. Firefox's background is a page, which does it itself.
 */
async function clearClipboard() {
  if (!browser.offscreen) {
    emptyClipboard(document);
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
      justification: "Empty the clipboard of a copied secret after the delay chosen.",
    });
  }
  await browser.runtime.sendMessage(emptyClipboardMessage);
  await browser.offscreen.closeDocument();
}

/**
 * Copies an empty text through a copy event: the Clipboard API asks for a focused page, which a
 * background has not.
 */
export function emptyClipboard(page: Document) {
  page.addEventListener(
    "copy",
    (event) => {
      event.clipboardData?.setData("text/plain", "");
      event.preventDefault();
    },
    { once: true },
  );
  page.execCommand("copy");
}
