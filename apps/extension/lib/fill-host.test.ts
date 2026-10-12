import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import type { SubmarineCore } from "./core-host";
import { fillFromShortcut, fillLogin, followFillRequests } from "./fill-host";
import { fillPage } from "./fill-page";

const github = { vault: "v1", id: "github", type: 1, name: "GitHub", subtitle: "alice" };

/**
 * A core holding the login `github`, for https://github.com, with the verification key `totp`, and
 * locked when `locked`.
 */
function fakeCore({ locked = false, totp = null as string | null } = {}) {
  const replies: Record<string, (args: { url?: string }) => unknown> = {
    lockState: () => ({ hasPassword: true, locked }),
    items: ({ url }) => (url?.startsWith("https://github.com/") ? [github] : []),
    item: () => ({
      vault: "v1",
      id: "github",
      cipher: { type: 1, login: { username: "alice", password: "hunter2", totp } },
    }),
    totp: () => ({ code: "123456", period: 30 }),
    used: () => null,
  };
  return {
    call: vi.fn<SubmarineCore["call"]>(async (method, args) =>
      JSON.stringify({ result: replies[method]?.(JSON.parse(args)) }),
    ),
  };
}

function onTab(url: string) {
  vi.spyOn(browser.tabs, "get").mockResolvedValue({ id: 7, url } as never);
}

function injecting(result: unknown) {
  return vi
    .spyOn(browser.scripting, "executeScript")
    .mockResolvedValue([{ frameId: 0, documentId: "d", result }] as never);
}

describe("fillLogin", () => {
  beforeEach(() => {
    fakeBrowser.reset();
    vi.spyOn(console, "warn").mockImplementation(() => {});
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fills the login into the top frame, for the page's origin alone", async () => {
    onTab("https://github.com/login");
    const executeScript = injecting(true);
    expect(await fillLogin(fakeCore(), { tabId: 7, vault: "v1", id: "github" })).toBe(true);
    expect(executeScript).toHaveBeenCalledWith({
      target: { tabId: 7 },
      func: fillPage,
      args: ["https://github.com", "alice", "hunter2"],
    });
  });

  it("copies the login's verification code once filled, as the site asks for it next", async () => {
    onTab("https://github.com/login");
    injecting(true);
    const copy = vi.fn(async (_secret: string) => {});
    const core = fakeCore({ totp: "JBSWY3DPEHPK3PXP" });
    expect(await fillLogin(core, { tabId: 7, vault: "v1", id: "github" }, copy)).toBe(true);
    expect(copy).toHaveBeenCalledWith("123456");
  });

  it("copies no code when nothing was filled, and fills even when the copy fails", async () => {
    onTab("https://github.com/");
    injecting(false);
    const copy = vi.fn(async (_secret: string) => {});
    const core = fakeCore({ totp: "JBSWY3DPEHPK3PXP" });
    expect(await fillLogin(core, { tabId: 7, vault: "v1", id: "github" }, copy)).toBe(false);
    expect(copy).not.toHaveBeenCalled();
    injecting(true);
    copy.mockRejectedValue(new Error("No clipboard"));
    expect(await fillLogin(core, { tabId: 7, vault: "v1", id: "github" }, copy)).toBe(true);
  });

  it("refuses a login for another site, which the tab may have moved to", async () => {
    onTab("https://github.evil.example/login");
    const executeScript = injecting(true);
    expect(await fillLogin(fakeCore(), { tabId: 7, vault: "v1", id: "github" })).toBe(false);
    expect(executeScript).not.toHaveBeenCalled();
  });

  it("tells when the page had nothing to fill, or kept the extension out", async () => {
    onTab("https://github.com/");
    injecting(false);
    expect(await fillLogin(fakeCore(), { tabId: 7, vault: "v1", id: "github" })).toBe(false);
    vi.spyOn(browser.scripting, "executeScript").mockRejectedValue(new Error("Cannot access"));
    expect(await fillLogin(fakeCore(), { tabId: 7, vault: "v1", id: "github" })).toBe(false);
  });
});

describe("fillFromShortcut", () => {
  beforeEach(() => {
    fakeBrowser.reset();
    vi.spyOn(console, "warn").mockImplementation(() => {});
    vi.spyOn(browser.action, "openPopup").mockResolvedValue(undefined as never);
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fills the first login for the tab, a use that pushes the lock back", async () => {
    onTab("https://github.com/login");
    const executeScript = injecting(true);
    const core = fakeCore();
    await fillFromShortcut(core, { id: 7 } as never);
    expect(executeScript).toHaveBeenCalledOnce();
    expect(core.call).toHaveBeenCalledWith("used", "{}");
    expect(browser.action.openPopup).not.toHaveBeenCalled();
  });

  it("opens the popup while the vaults are locked", async () => {
    onTab("https://github.com/login");
    const executeScript = injecting(true);
    await fillFromShortcut(fakeCore({ locked: true }), { id: 7 } as never);
    expect(executeScript).not.toHaveBeenCalled();
    expect(browser.action.openPopup).toHaveBeenCalledOnce();
  });

  it("opens the popup without a login for the page", async () => {
    onTab("https://example.com/");
    const executeScript = injecting(true);
    await fillFromShortcut(fakeCore(), { id: 7 } as never);
    expect(executeScript).not.toHaveBeenCalled();
    expect(browser.action.openPopup).toHaveBeenCalledOnce();
  });
});

describe("followFillRequests", () => {
  beforeEach(() => {
    fakeBrowser.reset();
    vi.spyOn(browser.commands.onCommand, "addListener").mockImplementation(() => {});
  });

  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("fills for an extension page only, never for a content script", async () => {
    onTab("https://github.com/login");
    const executeScript = injecting(true);
    followFillRequests(fakeCore());
    const request = { fill: { tabId: 7, vault: "v1", id: "github" } };
    const fromPage = { id: browser.runtime.id, url: "https://github.com/login" };
    await fakeBrowser.runtime.onMessage.trigger(request, fromPage, () => {});
    expect(executeScript).not.toHaveBeenCalled();
    const fromPopup = { id: browser.runtime.id, url: browser.runtime.getURL("/popup.html") };
    await fakeBrowser.runtime.onMessage.trigger(request, fromPopup, () => {});
    await vi.waitFor(() => expect(executeScript).toHaveBeenCalledOnce());
  });
});
