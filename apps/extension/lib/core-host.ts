import type { Browser } from "wxt/browser";
import type { CoreReply, CoreRequest } from "./core";
import { nostrCrypto } from "./nostr-crypto";

export interface SubmarineCore {
  call(method: string, args: string): Promise<string>;
}

type CoreGlobals = typeof globalThis & {
  importScripts?: (...urls: string[]) => void;
  submarineCore?: SubmarineCore;
};

/** Loads the Dart core, once what it needs from JavaScript is set. */
export function loadCore(): SubmarineCore {
  const globals = globalThis as CoreGlobals;
  if (typeof window === "undefined") {
    // package:cryptography 2.9.0 reads these two through window, absent from a service worker.
    Object.defineProperty(globals, "window", {
      value: { isSecureContext: globals.isSecureContext, crypto: globals.crypto },
    });
  }
  // Without a DOM, dart2js runs its microtasks on setTimeout, clamped to 4 ms once nested.
  Object.assign(globals, { nostrCrypto, scheduleImmediate: queueMicrotask });
  // Firefox runs the background as a page, where the manifest lists core.js first.
  globals.importScripts?.("/core.js");
  if (!globals.submarineCore) throw new Error("The Dart core did not load");
  return globals.submarineCore;
}

/**
 * The reply of the core to a message, or undefined when it does not come from one of the
 * extension's own pages.
 */
export function answer(
  core: SubmarineCore,
  message: unknown,
  sender: Browser.runtime.MessageSender,
): Promise<string> | undefined {
  // A content script sends from the URL of its web page.
  if (sender.id !== browser.runtime.id || !sender.url?.startsWith(browser.runtime.getURL("/"))) {
    return;
  }
  const { method, args } = message as CoreRequest;
  // Firefox stops an event page after 30 s, a reply pending or not, unless it calls an API.
  const keepAlive = setInterval(() => browser.runtime.getPlatformInfo(), 10_000);
  return core
    .call(method, JSON.stringify(args ?? {}))
    .catch((error) => {
      const reply: CoreReply = { error: { code: "internal", message: String(error) } };
      return JSON.stringify(reply);
    })
    .finally(() => clearInterval(keepAlive));
}

export function answerExtensionPages(core: SubmarineCore) {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    const reply = answer(core, message, sender);
    if (!reply) return;
    reply.then(sendResponse);
    return true;
  });
}
