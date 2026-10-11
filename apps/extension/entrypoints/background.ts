import { isClipboardRequest } from "@/lib/clipboard";
import { clearClipboardLater } from "@/lib/clipboard-host";
import { answerExtensionPages, followPopups, fromExtensionPage, loadCore } from "@/lib/core-host";

export default defineBackground(() => {
  if (import.meta.env.MODE === "e2e") {
    // Firefox's WebDriver BiDi cannot open an extension page: the test build opens its own.
    browser.runtime.onInstalled.addListener(() => {
      browser.tabs.create({ url: browser.runtime.getURL("/popup.html") });
    });
  }

  const core = loadCore();
  answerExtensionPages(core);
  browser.runtime.onConnect.addListener(followPopups(core));
  browser.runtime.onMessage.addListener((message, sender) => {
    if (fromExtensionPage(sender) && isClipboardRequest(message)) {
      clearClipboardLater(message.clearClipboardAfter);
    }
  });
});
