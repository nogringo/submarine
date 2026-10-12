import { describe, expect, it } from "vitest";
import type { Cipher } from "./cipher";
import {
  brandOptions,
  cipherOf,
  type EditedField,
  editedField,
  filterKeeps,
  formChanged,
  formOf,
  loginForPage,
  monthOptions,
} from "./item-form";

function login(parts: Partial<Cipher> = {}): Cipher & Record<string, unknown> {
  return {
    type: 1,
    name: "GitHub",
    notes: null,
    fields: [{ name: "PIN", value: "1234", type: 1, linkedId: null }],
    login: {
      username: "alice",
      password: "hunter2",
      totp: null,
      uris: [{ uri: "github.com", match: 3 } as { uri: string }],
      fido2Credentials: [],
    },
    secureNote: null,
    card: null,
    identity: null,
    sshKey: null,
    bankAccount: null,
    driversLicense: null,
    passport: null,
    passwordHistory: [],
    favorite: false,
    creationDate: "2026-10-01T09:30:00.000Z",
    revisionDate: "2026-10-01T09:30:00.000Z",
    deletedDate: null,
    reprompt: 0,
    attachments: [{ id: "file" }],
    ...parts,
  };
}

describe("cipherOf", () => {
  it("saves what the form edits, and keeps the rest of the item", () => {
    const form = formOf(login(), 1);
    form.name = "  GitHub work ";
    form.password = "hunter3";
    form.uris.push({ source: null, uri: " gist.github.com " }, { source: null, uri: "  " });
    form.fields = form.fields.map((field) => ({ ...field, value: "5678" }));

    const saved = cipherOf(form, login()) as Cipher & Record<string, unknown>;

    expect(saved.name).toBe("GitHub work");
    expect(saved.login).toMatchObject({ username: "alice", password: "hunter3" });
    expect(saved.login?.uris).toEqual([
      { uri: "github.com", match: 3 },
      { uri: "gist.github.com" },
    ]);
    expect(saved.fields).toEqual([{ name: "PIN", value: "5678", type: 1, linkedId: null }]);
    expect(saved.attachments).toEqual([{ id: "file" }]);
    expect(saved.reprompt).toBe(0);
    expect(saved.creationDate).toBe("2026-10-01T09:30:00.000Z");
  });

  it("saves an empty field as none, as the app does", () => {
    const form = formOf(login(), 1);
    form.username = "";
    form.notes = "";
    expect(cipherOf(form, login()).login?.username).toBeNull();
    expect(cipherOf(form, login()).notes).toBeNull();
  });

  it("builds a new login, a new card or a new secure note", () => {
    const newLogin = formOf(undefined, 1);
    newLogin.name = "GitHub";
    newLogin.username = "alice";
    expect(cipherOf(newLogin, undefined)).toMatchObject({
      type: 1,
      name: "GitHub",
      login: { username: "alice", password: null, uris: [] },
      card: null,
    });

    const card = formOf(undefined, 3);
    card.name = "Visa";
    card.brand = "Visa";
    card.expMonth = "3";
    expect(cipherOf(card, undefined).card).toMatchObject({
      brand: "Visa",
      expMonth: "3",
      number: null,
    });

    const note = formOf(undefined, 2);
    note.name = "Wifi";
    expect(cipherOf(note, undefined)).toMatchObject({ type: 2, secureNote: { type: 0 } });
  });

  it("writes a checkbox as true or false, and keeps the value of a linked field", () => {
    const form = formOf(
      login({
        fields: [
          { name: "Remember me", value: "false", type: 2, linkedId: null },
          { name: "login-email", value: null, type: 3, linkedId: 100 },
        ],
      }),
      1,
    );
    const [checkbox, linked] = form.fields;
    form.fields = [
      { ...(checkbox as EditedField), checked: true },
      { ...(linked as EditedField), linkedId: 101 },
    ];

    expect(cipherOf(form, undefined).fields).toEqual([
      { name: "Remember me", value: "true", type: 2, linkedId: null },
      { name: "login-email", value: null, type: 3, linkedId: 101 },
    ]);
  });
});

describe("formChanged", () => {
  it("tells a change, but not an empty website added", () => {
    const initial = formOf(login(), 1);
    const form = structuredClone(initial);
    form.uris.push({ source: null, uri: " " });
    expect(formChanged(form, initial)).toBe(false);
    form.favorite = true;
    expect(formChanged(form, initial)).toBe(true);
  });

  it("tells a custom field added, moved or renamed", () => {
    const initial = formOf(login(), 1);
    const added = {
      ...initial,
      fields: [
        ...initial.fields,
        editedField({ name: "Note", value: null, type: 0, linkedId: null }),
      ],
    };
    expect(formChanged(added, initial)).toBe(true);
    expect(formChanged({ ...added, fields: [...added.fields].reverse() }, added)).toBe(true);
    const renamed = {
      ...initial,
      fields: initial.fields.map((field) => ({ ...field, name: "Code" })),
    };
    expect(formChanged(renamed, initial)).toBe(true);
  });
});

describe("brandOptions", () => {
  it("keeps the brand of the item as it was written", () => {
    expect(brandOptions("visa")[0]).toEqual({ value: "visa", brand: "Visa" });
    expect(brandOptions("Elo").at(-1)).toEqual({ value: "Elo", brand: null });
    expect(brandOptions(null)).toHaveLength(10);
  });
});

describe("monthOptions", () => {
  it("keeps the month of the item as it was written", () => {
    expect(monthOptions("04")[3]).toEqual({ value: "04", month: 4 });
    expect(monthOptions("13").at(-1)).toEqual({ value: "13", month: null });
    expect(monthOptions(null)).toHaveLength(12);
  });
});

describe("filterKeeps", () => {
  it("keeps what the app's filters list", () => {
    const favorite = login({ favorite: true });
    const trashed = login({ deletedDate: "2026-10-02T00:00:00.000Z" });
    expect(filterKeeps("all", favorite)).toBe(true);
    expect(filterKeeps("favorites", login())).toBe(false);
    expect(filterKeeps(1, favorite)).toBe(true);
    expect(filterKeeps(3, favorite)).toBe(false);
    expect(filterKeeps("all", trashed)).toBe(false);
    expect(filterKeeps("trash", trashed)).toBe(true);
  });
});

describe("loginForPage", () => {
  it("names a login after the page's host, its website the page's origin", () => {
    expect(loginForPage("https://www.github.com/login?return_to=%2Fsettings")).toEqual({
      name: "github.com",
      uri: "https://www.github.com",
    });
    expect(loginForPage("http://localhost:8080/")).toEqual({
      name: "localhost",
      uri: "http://localhost:8080",
    });
  });

  it("gives nothing over a page that is not on the web", () => {
    expect(loginForPage("chrome-extension://abc/popup.html")).toBeUndefined();
    expect(loginForPage("about:blank")).toBeUndefined();
  });
});
