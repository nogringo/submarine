import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import {
  copyToClipboard,
  isClipboardRequest,
  readClipboardTimeout,
  saveClipboardTimeout,
} from "./clipboard";

beforeEach(() => {
  fakeBrowser.reset();
});

describe("copyToClipboard", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it("asks the background to empty the clipboard of a secret after the delay chosen", async () => {
    const writeText = vi.fn(async () => {});
    vi.stubGlobal("navigator", { clipboard: { writeText } });
    const send = vi.spyOn(browser.runtime, "sendMessage").mockResolvedValue(undefined as never);
    await copyToClipboard("hunter2", { sensitive: true });
    expect(writeText).toHaveBeenCalledWith("hunter2");
    expect(send).toHaveBeenCalledWith({ clearClipboardAfter: 30_000 });
    await saveClipboardTimeout("oneMinute");
    await copyToClipboard("hunter2", { sensitive: true });
    expect(send).toHaveBeenLastCalledWith({ clearClipboardAfter: 60_000 });
    await saveClipboardTimeout("never");
    await copyToClipboard("hunter2", { sensitive: true });
    expect(send).toHaveBeenLastCalledWith({ clearClipboardAfter: null });
    await copyToClipboard("alice", { sensitive: false });
    expect(send).toHaveBeenLastCalledWith({ clearClipboardAfter: null });
  });
});

describe("readClipboardTimeout", () => {
  it("reads the app's default until a timeout is chosen, and an unknown one as the default", async () => {
    expect(await readClipboardTimeout()).toBe("thirtySeconds");
    await saveClipboardTimeout("tenSeconds");
    expect(await readClipboardTimeout()).toBe("tenSeconds");
    await browser.storage.local.set({ clipboard: "anHour" });
    expect(await readClipboardTimeout()).toBe("thirtySeconds");
  });
});

describe("isClipboardRequest", () => {
  it("tells a clipboard request from a call of the core", () => {
    expect(isClipboardRequest({ clearClipboardAfter: null })).toBe(true);
    expect(isClipboardRequest({ method: "items" })).toBe(false);
    expect(isClipboardRequest("emptyClipboard")).toBe(false);
  });
});
