import { afterEach, describe, expect, it, vi } from "vitest";
import type { Cipher } from "./cipher";
import type { CoreRequest } from "./core";
import { exportFileName, importBatch, importCiphers, tabAction } from "./import-export";

describe("exportFileName", () => {
  it("names an export as the app does, by the local time", () => {
    const now = new Date(2026, 9, 8, 7, 6, 5);
    expect(exportFileName(now, true)).toBe("submarine_encrypted_export_20261008070605.json");
    expect(exportFileName(now, false)).toBe("submarine_export_20261008070605.json");
  });
});

describe("tabAction", () => {
  it("reads what the tab was opened for", () => {
    expect(tabAction("#import")).toBe("import");
    expect(tabAction("#export")).toBe("export");
    expect(tabAction("")).toBeUndefined();
    expect(tabAction("#other")).toBeUndefined();
  });
});

describe("importCiphers", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("saves the items a batch at a time, in order, and tells how many are saved", async () => {
    const sent: CoreRequest[] = [];
    vi.spyOn(browser.runtime, "sendMessage").mockImplementation((async (request: CoreRequest) => {
      sent.push(request);
      return JSON.stringify({ result: null });
    }) as never);
    const ciphers = Array.from(
      { length: importBatch + 1 },
      (_, index) => ({ type: 2, name: `Note ${index}` }) as Cipher,
    );
    const saved: number[] = [];

    await importCiphers("pubkey", ciphers, (count) => saved.push(count));

    expect(sent).toEqual([
      { method: "importItems", args: { vault: "pubkey", ciphers: ciphers.slice(0, importBatch) } },
      { method: "importItems", args: { vault: "pubkey", ciphers: ciphers.slice(importBatch) } },
    ]);
    expect(saved).toEqual([importBatch, importBatch + 1]);
  });

  it("stops at the batch that fails, what was saved kept", async () => {
    vi.spyOn(browser.runtime, "sendMessage")
      .mockResolvedValueOnce(JSON.stringify({ result: null }) as never)
      .mockResolvedValueOnce(
        JSON.stringify({ error: { code: "internal", message: null } }) as never,
      );
    const ciphers = Array.from({ length: importBatch * 3 }, () => ({ type: 2 }) as Cipher);
    const saved: number[] = [];

    await expect(importCiphers("pubkey", ciphers, (count) => saved.push(count))).rejects.toThrow();

    expect(saved).toEqual([importBatch]);
  });
});
