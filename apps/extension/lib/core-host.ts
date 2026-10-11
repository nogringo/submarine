import type { Browser } from "wxt/browser";
import { type CoreReply, type CoreRequest, syncPort } from "./core";
import { nostrCrypto } from "./nostr-crypto";

export interface SubmarineCore {
  call(method: string, args: string): Promise<string>;
}

/** The strings the Dart core keeps, in one of the extension's storage areas. */
function storageFor(area: Browser.storage.StorageArea) {
  return {
    get: async (key: string): Promise<string | undefined> =>
      (await area.get(key))[key] as string | undefined,
    set: (key: string, value: string) => area.set({ [key]: value }),
    remove: (key: string) => area.remove(key),
  };
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
  Object.assign(globals, {
    nostrCrypto,
    extensionStorage: storageFor(browser.storage.local),
    // Emptied once the browser closes, and out of reach of content scripts.
    extensionSessionStorage: storageFor(browser.storage.session),
    scheduleImmediate: queueMicrotask,
  });
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
  if (!fromExtensionPage(sender) || !isCoreRequest(message)) return;
  const { method, args } = message;
  const keepAlive = keepBackgroundAlive();
  return core
    .call(method, JSON.stringify(args ?? {}))
    .catch((error) => {
      const reply: CoreReply = { error: { code: "internal", message: String(error) } };
      return JSON.stringify(reply);
    })
    .finally(() => clearInterval(keepAlive));
}

/**
 * Keeps the vaults synced while a popup holds the sync port open, and passes on to the popups what
 * the core tells, as `coreEvents`. Returns what to do with a port that connects.
 */
export function followPopups(core: SubmarineCore): (port: Browser.runtime.Port) => void {
  const popups = new Set<Browser.runtime.Port>();
  let keepAlive: ReturnType<typeof setInterval> | undefined;
  const coreEvents = {
    emit: (type: string) => {
      for (const popup of popups) popup.postMessage(type);
    },
  };
  Object.assign(globalThis, { coreEvents });
  return (port) => {
    if (port.name !== syncPort || !port.sender || !fromExtensionPage(port.sender)) return;
    popups.add(port);
    if (popups.size === 1) {
      keepAlive = keepBackgroundAlive();
      void core.call("startSync", "{}");
    }
    port.onDisconnect.addListener(() => {
      popups.delete(port);
      if (popups.size > 0) return;
      clearInterval(keepAlive);
      void core.call("stopSync", "{}");
    });
  };
}

export function answerExtensionPages(core: SubmarineCore) {
  browser.runtime.onMessage.addListener((message, sender, sendResponse) => {
    const reply = answer(core, message, sender);
    if (!reply) return;
    reply.then(sendResponse);
    return true;
  });
}

/** Whether a message or a port comes from one of the extension's own pages. */
export function fromExtensionPage(sender: Browser.runtime.MessageSender): boolean {
  // A content script sends from the URL of its web page.
  return sender.id === browser.runtime.id && !!sender.url?.startsWith(browser.runtime.getURL("/"));
}

/**
 * Firefox stops an event page after 30 s, a reply pending or a port open, and Chrome a service
 * worker, unless it calls an extension API. Clear the interval returned once done.
 */
export function keepBackgroundAlive(): ReturnType<typeof setInterval> {
  return setInterval(() => browser.runtime.getPlatformInfo(), 10_000);
}

function isCoreRequest(message: unknown): message is CoreRequest {
  return typeof message === "object" && message !== null && "method" in message;
}
