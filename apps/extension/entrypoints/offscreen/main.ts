import { copyIn, isOffscreenCopyRequest } from "@/lib/clipboard-host";

browser.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (!isOffscreenCopyRequest(message)) return;
  copyIn(document, message.offscreenCopy);
  sendResponse(true);
});
