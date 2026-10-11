import { answerExtensionPages, loadCore } from "@/lib/core-host";

export default defineBackground(() => {
  if (import.meta.env.MODE === "e2e") {
    // Firefox's WebDriver BiDi cannot open an extension page: the test build opens its own.
    browser.runtime.onInstalled.addListener(() => {
      browser.tabs.create({ url: browser.runtime.getURL("/popup.html") });
    });
  }

  answerExtensionPages(loadCore());
});
