import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import { answer, loadCore, type SubmarineCore } from "./core-host";
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

describe("loadCore", () => {
  it("gives the core what it needs from JavaScript", () => {
    const core = fakeCore(async () => "");
    Object.assign(globalThis, { submarineCore: core });
    expect(loadCore()).toBe(core);
    expect(globalThis).toMatchObject({ nostrCrypto, scheduleImmediate: queueMicrotask });
    expect(globalThis).toHaveProperty("window.crypto", globalThis.crypto);
  });
});
