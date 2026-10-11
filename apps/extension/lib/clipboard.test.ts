import { afterEach, describe, expect, it, vi } from "vitest";
import { clipboardDelay, copyToClipboard, isClipboardRequest } from "./clipboard";

describe("copyToClipboard", () => {
  afterEach(() => {
    vi.unstubAllGlobals();
    vi.restoreAllMocks();
  });

  it("asks the background to empty the clipboard of a secret after the delay", async () => {
    const writeText = vi.fn(async () => {});
    vi.stubGlobal("navigator", { clipboard: { writeText } });
    const send = vi.spyOn(browser.runtime, "sendMessage").mockResolvedValue(undefined as never);
    await copyToClipboard("hunter2", { sensitive: true });
    expect(writeText).toHaveBeenCalledWith("hunter2");
    expect(send).toHaveBeenCalledWith({ clearClipboardAfter: clipboardDelay });
    await copyToClipboard("alice", { sensitive: false });
    expect(send).toHaveBeenLastCalledWith({ clearClipboardAfter: null });
  });
});

describe("isClipboardRequest", () => {
  it("tells a clipboard request from a call of the core", () => {
    expect(isClipboardRequest({ clearClipboardAfter: null })).toBe(true);
    expect(isClipboardRequest({ method: "items" })).toBe(false);
    expect(isClipboardRequest("emptyClipboard")).toBe(false);
  });
});
