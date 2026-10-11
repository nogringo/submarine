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
    const send = reply({ result: { items: 3 } });
    expect(await callCore("items", { vault: "a" })).toEqual({ items: 3 });
    expect(send).toHaveBeenCalledWith({ method: "items", args: { vault: "a" } });
  });

  it("throws the error of the core with its code", async () => {
    reply({ error: { code: "wrongPassword", message: null } });
    const error = await callCore("unlock").catch((error: unknown) => error);
    expect(error).toBeInstanceOf(CoreError);
    expect(error).toMatchObject({ code: "wrongPassword", message: "wrongPassword" });
  });
});
