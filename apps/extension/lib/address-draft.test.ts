import { describe, expect, it } from "vitest";
import {
  addToDraft,
  draftChanged,
  draftLists,
  draftRows,
  moveInDraft,
  noChanges,
  resetDraft,
} from "./address-draft";

const listed = { public: ["wss://a", "wss://b"], private: ["wss://p"] };

describe("draftLists", () => {
  it("leaves out the removed addresses and puts the added ones after their group", () => {
    const draft = {
      removed: ["wss://a"],
      added: [
        { url: "wss://c", private: false },
        { url: "wss://q", private: true },
      ],
    };
    expect(draftLists(listed, draft)).toEqual({
      public: ["wss://b", "wss://c"],
      private: ["wss://p", "wss://q"],
    });
    expect(draftChanged(listed, draft)).toBe(true);
  });

  it("is the list as listed without changes", () => {
    expect(draftLists(listed, noChanges)).toEqual(listed);
    expect(draftChanged(listed, noChanges)).toBe(false);
  });
});

describe("moveInDraft", () => {
  it("moves an address among its group, which a move alone changes", () => {
    const draft = moveInDraft(listed, noChanges, "wss://b", 0);
    expect(draftLists(listed, draft).public).toEqual(["wss://b", "wss://a"]);
    expect(draftChanged(listed, draft)).toBe(true);
  });

  it("keeps a private address after the public ones", () => {
    expect(moveInDraft(listed, noChanges, "wss://p", 0)).toBe(noChanges);
    const draft = moveInDraft(listed, noChanges, "wss://a", 2);
    expect(draftLists(listed, draft)).toEqual({
      public: ["wss://b", "wss://a"],
      private: ["wss://p"],
    });
  });

  it("keeps a removed address in its row, and an added one once moved", () => {
    let draft = { removed: ["wss://a"], added: [{ url: "wss://c", private: false }] };
    draft = moveInDraft(listed, draft, "wss://c", 0);
    expect(draftRows(listed, draft).public).toEqual(["wss://c", "wss://a", "wss://b"]);
    expect(draftLists(listed, draft).public).toEqual(["wss://c", "wss://b"]);
  });
});

describe("addToDraft", () => {
  it("keeps an address removed from the same group rather than adding it twice", () => {
    const draft = addToDraft(
      listed,
      { removed: ["wss://a"], added: [] },
      {
        url: "wss://a",
        private: false,
      },
    );
    expect(draft).toEqual({ removed: [], added: [] });
  });

  it("moves an address removed from the other group", () => {
    const draft = addToDraft(
      listed,
      { removed: ["wss://a"], added: [] },
      {
        url: "wss://a",
        private: true,
      },
    );
    expect(draftLists(listed, draft)).toEqual({
      public: ["wss://b"],
      private: ["wss://p", "wss://a"],
    });
  });
});

describe("resetDraft", () => {
  it("puts back the defaults in their order", () => {
    const mail = { public: ["wss://x", "wss://b", "wss://a"], private: [] };
    const draft = resetDraft(mail, ["wss://a", "wss://b", "wss://c"]);
    expect(draftLists(mail, draft).public).toEqual(["wss://a", "wss://b", "wss://c"]);
  });
});
