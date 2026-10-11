import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import type { Browser } from "wxt/browser";
import { fakeBrowser } from "wxt/testing/fake-browser";
import { answer, followPopups, loadCore, type SubmarineCore } from "./core-host";
import { nostrCrypto } from "./nostr-crypto";

function fakeCore(reply: () => Promise<string>) {
  return { call: vi.fn<SubmarineCore["call"]>(reply) };
}

const fromPopup = () => ({
  id: browser.runtime.id,
  url: browser.runtime.getURL("/popup.html"),
});

describe("answer", () => {
  beforeEach(() => {
    fakeBrowser.reset();
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it("passes a call from an extension page to the core", async () => {
    const core = fakeCore(async () => '{"result":1}');
    const reply = answer(core, { method: "items", args: { vault: "a" } }, fromPopup());
    expect(await reply).toBe('{"result":1}');
    expect(core.call).toHaveBeenCalledWith("items", '{"vault":"a"}');
  });

  it("ignores a content script", () => {
    const core = fakeCore(async () => '{"result":1}');
    const sender = { id: browser.runtime.id, url: "https://example.com/" };
    expect(answer(core, { method: "items" }, sender)).toBeUndefined();
    expect(core.call).not.toHaveBeenCalled();
  });

  it("answers an internal error when the core fails", async () => {
    const core = fakeCore(() => Promise.reject(new Error("boom")));
    expect(JSON.parse((await answer(core, { method: "items" }, fromPopup())) ?? "")).toEqual({
      error: { code: "internal", message: "Error: boom" },
    });
  });

  it("keeps the background alive while the core works", async () => {
    vi.useFakeTimers();
    // The overload with a callback, last, sets the spy's type.
    const ping = vi.spyOn(browser.runtime, "getPlatformInfo").mockResolvedValue({} as never);
    let finish = (_reply: string) => {};
    const core = fakeCore(() => new Promise((resolve) => (finish = resolve)));
    const reply = answer(core, { method: "sync" }, fromPopup());
    await vi.advanceTimersByTimeAsync(25_000);
    expect(ping).toHaveBeenCalledTimes(2);
    finish('{"result":null}');
    await reply;
    await vi.advanceTimersByTimeAsync(25_000);
    expect(ping).toHaveBeenCalledTimes(2);
  });
});

/** A port a popup opened, which the test closes as the popup would. */
function fakePort(name = "sync", sender = fromPopup()) {
  const disconnected: (() => void)[] = [];
  const port = {
    name,
    sender,
    postMessage: vi.fn(),
    onDisconnect: { addListener: (listener: () => void) => disconnected.push(listener) },
  };
  return {
    port,
    connection: port as unknown as Browser.runtime.Port,
    close: () => {
      for (const listener of disconnected) listener();
    },
  };
}

function emit(type: string) {
  (globalThis as unknown as { coreEvents: { emit(type: string): void } }).coreEvents.emit(type);
}

describe("followPopups", () => {
  beforeEach(() => {
    fakeBrowser.reset();
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it("syncs from the first popup open to the last one closed", () => {
    const core = fakeCore(async () => '{"result":null}');
    const connect = followPopups(core);
    const first = fakePort();
    const second = fakePort();
    connect(first.connection);
    connect(second.connection);
    expect(core.call.mock.calls).toEqual([["startSync", "{}"]]);
    first.close();
    expect(core.call).toHaveBeenCalledTimes(1);
    second.close();
    expect(core.call.mock.calls).toEqual([
      ["startSync", "{}"],
      ["stopSync", "{}"],
    ]);
  });

  it("tells the open popups what the core tells", () => {
    const connect = followPopups(fakeCore(async () => '{"result":null}'));
    const open = fakePort();
    const closed = fakePort();
    connect(open.connection);
    connect(closed.connection);
    closed.close();
    emit("vaultsChanged");
    expect(open.port.postMessage).toHaveBeenCalledWith("vaultsChanged");
    expect(closed.port.postMessage).not.toHaveBeenCalled();
  });

  it("ignores a content script and other ports", () => {
    const core = fakeCore(async () => '{"result":null}');
    const connect = followPopups(core);
    connect(fakePort("sync", { id: browser.runtime.id, url: "https://example.com/" }).connection);
    connect(fakePort("other").connection);
    expect(core.call).not.toHaveBeenCalled();
  });

  it("keeps the background alive while a popup is open", async () => {
    vi.useFakeTimers();
    const ping = vi.spyOn(browser.runtime, "getPlatformInfo").mockResolvedValue({} as never);
    const connect = followPopups(fakeCore(async () => '{"result":null}'));
    const popup = fakePort();
    connect(popup.connection);
    await vi.advanceTimersByTimeAsync(25_000);
    expect(ping).toHaveBeenCalledTimes(2);
    popup.close();
    await vi.advanceTimersByTimeAsync(25_000);
    expect(ping).toHaveBeenCalledTimes(2);
  });
});

describe("loadCore", () => {
  it("gives the core what it needs from JavaScript", () => {
    const core = fakeCore(async () => "");
    Object.assign(globalThis, { submarineCore: core });
    expect(loadCore()).toBe(core);
    expect(globalThis).toMatchObject({ nostrCrypto, scheduleImmediate: queueMicrotask });
    expect(globalThis).toHaveProperty("window.crypto", globalThis.crypto);
  });
});
