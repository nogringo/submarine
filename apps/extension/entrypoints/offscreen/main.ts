import { emptyClipboard, emptyClipboardMessage } from "@/lib/clipboard-host";

browser.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message !== emptyClipboardMessage) return;
  emptyClipboard(document);
  sendResponse(true);
});
