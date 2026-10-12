import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import { clearClipboardLater, copyIn } from "./clipboard-host";

describe("clearClipboardLater", () => {
  beforeEach(() => {
    fakeBrowser.reset();
    vi.useFakeTimers();
    vi.spyOn(browser.runtime, "getPlatformInfo").mockResolvedValue({} as never);
  });

  afterEach(() => {
    clearClipboardLater(null);
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it("empties the clipboard after the delay, the background kept alive until then", async () => {
    const clear = vi.fn(async () => {});
    clearClipboardLater(30_000, clear);
    await vi.advanceTimersByTimeAsync(29_000);
    expect(clear).not.toHaveBeenCalled();
    expect(browser.runtime.getPlatformInfo).toHaveBeenCalledTimes(2);
    await vi.advanceTimersByTimeAsync(1_000);
    expect(clear).toHaveBeenCalledOnce();
    const pings = vi.mocked(browser.runtime.getPlatformInfo).mock.calls.length;
    await vi.advanceTimersByTimeAsync(30_000);
    expect(browser.runtime.getPlatformInfo).toHaveBeenCalledTimes(pings);
  });

  it("counts from the last copy, which replaces the one to clear", async () => {
    const clear = vi.fn(async () => {});
    clearClipboardLater(30_000, clear);
    await vi.advanceTimersByTimeAsync(20_000);
    clearClipboardLater(30_000, clear);
    await vi.advanceTimersByTimeAsync(20_000);
    expect(clear).not.toHaveBeenCalled();
    await vi.advanceTimersByTimeAsync(10_000);
    expect(clear).toHaveBeenCalledOnce();
  });

  it("keeps what a copy that is no secret put in the clipboard", async () => {
    const clear = vi.fn(async () => {});
    clearClipboardLater(30_000, clear);
    clearClipboardLater(null, clear);
    await vi.advanceTimersByTimeAsync(60_000);
    expect(clear).not.toHaveBeenCalled();
  });
});

describe("copyIn", () => {
  it("copies the text in place of the page's selection", () => {
    let listener: ((event: ClipboardEvent) => void) | undefined;
    const setData = vi.fn();
    const preventDefault = vi.fn();
    const page = {
      addEventListener: (_type: string, added: (event: ClipboardEvent) => void) => {
        listener = added;
      },
      execCommand: () => {
        listener?.({ clipboardData: { setData }, preventDefault } as unknown as ClipboardEvent);
        return true;
      },
    } as unknown as Document;
    copyIn(page, "");
    expect(setData).toHaveBeenCalledWith("text/plain", "");
    expect(preventDefault).toHaveBeenCalled();
  });
});
