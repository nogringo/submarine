import { beforeEach, describe, expect, it } from "vitest";
import { fakeBrowser } from "wxt/testing/fake-browser";
import {
  forgetItemDraft,
  type ItemDraft,
  readItemDraft,
  restoredForm,
  saveItemDraft,
} from "./item-draft";
import { editedField, formOf } from "./item-form";

function draft(): ItemDraft {
  const initial = formOf(undefined, 1);
  return {
    vault: "a",
    type: 1,
    initial,
    form: {
      ...initial,
      name: "GitHub",
      uris: [{ source: null, uri: "https://github.com", isNew: true }],
      fields: [
        editedField({ name: "PIN", value: "1234", type: 1, linkedId: null }, { isNew: true }),
      ],
    },
  };
}

describe("item draft", () => {
  beforeEach(() => {
    fakeBrowser.reset();
  });

  it("is kept in the session's storage until forgotten", async () => {
    expect(await readItemDraft()).toBeUndefined();
    await saveItemDraft(draft());
    expect(await readItemDraft()).toMatchObject({ vault: "a", form: { name: "GitHub" } });
    await forgetItemDraft();
    expect(await readItemDraft()).toBeUndefined();
    expect(await browser.storage.local.get()).toEqual({});
  });

  it("shows its form again, what was added no longer taking the focus", () => {
    const form = restoredForm(draft());
    expect(form.name).toBe("GitHub");
    expect(form.uris).toEqual([{ source: null, uri: "https://github.com" }]);
    expect(form.fields).toEqual([expect.not.objectContaining({ isNew: true })]);
    expect(form.fields[0]?.value).toBe("1234");
  });
});
