import { afterEach, describe, expect, it, vi } from "vitest";
import { CoreError, callCore } from "./core";

// The overload with a callback, last, sets the spy's type.
const reply = (value: unknown) =>
  vi.spyOn(browser.runtime, "sendMessage").mockResolvedValue(JSON.stringify(value) as never);

describe("callCore", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("sends the method and its arguments, and returns the result", async () => {
    const vault = { pubkey: "a", name: "Home", color: 1 };
    const send = reply({ result: [vault] });
    expect(await callCore("vaults", {})).toEqual([vault]);
    expect(send).toHaveBeenCalledWith({ method: "vaults", args: {} });
  });

  it("throws the error of the core with its code", async () => {
    reply({ error: { code: "vaultAlreadyOpen", message: "Home" } });
    const args = { key: "nsec1", name: "Work", color: 1 };
    const error = await callCore("addVault", args).catch((error: unknown) => error);
    expect(error).toBeInstanceOf(CoreError);
    expect(error).toMatchObject({ code: "vaultAlreadyOpen", message: "Home" });
  });
});
