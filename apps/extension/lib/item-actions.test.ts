import { describe, expect, it } from "vitest";
import { availableActions, copiedFrom } from "./item-actions";
import { cipherOf, formOf } from "./item-form";

const login = cipherOf(
  { ...formOf(undefined, 1), name: "GitHub", username: "alice", password: "hunter2" },
  undefined,
);
const card = cipherOf({ ...formOf(undefined, 3), name: "Visa", number: "4111" }, undefined);

describe("availableActions", () => {
  it("copies what the item holds, then changes it, as the app's menu", () => {
    expect(availableActions(login, true)).toEqual([
      "copyUsername",
      "copyPassword",
      "copyTotp",
      "favorite",
      "edit",
      "trash",
    ]);
    expect(availableActions(card, false)).toEqual(["copyNumber", "favorite", "edit", "trash"]);
  });

  it("leaves out a blank value, and Edit for a type the form does not edit", () => {
    const form = { ...formOf(undefined, 1), name: "Me", username: "alice", password: " " };
    const identity = { ...cipherOf(form, undefined), type: 4 };
    expect(availableActions(identity, false)).toEqual(["copyUsername", "favorite", "trash"]);
  });

  it("restores or deletes an item in the trash", () => {
    const trashed = { ...card, deletedDate: "2026-10-01T00:00:00.000Z" };
    expect(availableActions(trashed, false)).toEqual(["copyNumber", "restore", "delete"]);
  });
});

describe("copiedFrom", () => {
  it("reads the value an action copies", () => {
    expect(copiedFrom(login, "copyPassword")).toBe("hunter2");
    expect(copiedFrom(card, "copyNumber")).toBe("4111");
    expect(copiedFrom(card, "copyUsername")).toBeUndefined();
  });
});
