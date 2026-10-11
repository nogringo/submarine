import { createIntl } from "react-intl";
import { beforeAll, describe, expect, it } from "vitest";
import type { Cipher } from "./cipher";
import { loadMessages } from "./i18n";
import { customFields, typeFields, websiteUrl } from "./item-fields";

let intl: ReturnType<typeof createIntl>;

beforeAll(async () => {
  intl = createIntl({ locale: "en", messages: await loadMessages("en") });
});

function cipher(parts: Partial<Cipher>): Cipher {
  return {
    type: 1,
    name: "GitHub",
    notes: null,
    fields: [],
    login: null,
    creationDate: null,
    revisionDate: null,
    ...parts,
  };
}

describe("typeFields", () => {
  it("lists a login's fields as the app does, without the empty ones", () => {
    const login = cipher({
      login: {
        username: "alice",
        password: "hunter2",
        totp: null,
        uris: [{ uri: "github.com" }, { uri: " " }, { uri: "https://gist.github.com" }],
        fido2Credentials: [
          { rpId: "github.com", creationDate: "2026-10-01T12:00:00.000Z" },
          { rpId: "github.com" },
        ],
      },
    });
    expect(typeFields(login, intl)).toEqual([
      { label: "Username", value: "alice", kind: "text" },
      { label: "Password", value: "hunter2", kind: "password" },
      { label: "Website", value: "github.com", kind: "url" },
      { label: "Website", value: "https://gist.github.com", kind: "url" },
      { label: "Passkey", value: "Created on Oct 1, 2026", kind: "info" },
      { label: "Passkey", value: "github.com", kind: "info" },
    ]);
  });

  it("lists nothing for a login without a login part", () => {
    expect(typeFields(cipher({}), intl)).toEqual([]);
  });
});

describe("customFields", () => {
  it("shows each type of field as the app does", () => {
    const fields = customFields(
      cipher({
        fields: [
          { name: "PIN", value: "1234", type: 1, linkedId: null },
          { name: "Recovery", value: "true", type: 2, linkedId: null },
          { name: "Login", value: null, type: 3, linkedId: 100 },
          { name: "Unknown link", value: null, type: 3, linkedId: 999 },
          { name: "Plan", value: "Pro", type: 0, linkedId: null },
        ],
      }),
      intl,
    );
    expect(fields).toEqual([
      { label: "PIN", value: "1234", kind: "password" },
      { label: "Recovery", value: "Yes", kind: "info" },
      { label: "Login", value: "Linked to Username", kind: "info" },
      { label: "Unknown link", value: "Linked to ?", kind: "info" },
      { label: "Plan", value: "Pro", kind: "text" },
    ]);
  });
});

describe("websiteUrl", () => {
  it.each([
    ["github.com", "https://github.com/"],
    [" http://example.com/login ", "http://example.com/login"],
    ["androidapp://com.example", undefined],
    ["not a url", undefined],
  ])("opens %j as %j", (value, url) => {
    expect(websiteUrl(value)).toBe(url);
  });
});
