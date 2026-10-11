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
    card: null,
    identity: null,
    sshKey: null,
    bankAccount: null,
    driversLicense: null,
    passport: null,
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
        totp: "JBSWY3DPEHPK3PXP",
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
      { label: "Verification code", value: "JBSWY3DPEHPK3PXP", kind: "totp" },
      { label: "Website", value: "github.com", kind: "url" },
      { label: "Website", value: "https://gist.github.com", kind: "url" },
      { label: "Passkey", value: "Created on Oct 1, 2026", kind: "info" },
      { label: "Passkey", value: "github.com", kind: "info" },
    ]);
  });

  it("lists nothing for a login without a login part, nor for a secure note", () => {
    expect(typeFields(cipher({}), intl)).toEqual([]);
    expect(typeFields(cipher({ type: 2, notes: "Wifi: hunter2" }), intl)).toEqual([]);
  });

  it("lists a card's fields, its brand and expiration as the app shows them", () => {
    const card = cipher({
      type: 3,
      card: {
        cardholderName: "Alice Martin",
        brand: "Amex",
        number: "378282246310005",
        expMonth: "3",
        expYear: "2029",
        code: "1234",
      },
    });
    expect(typeFields(card, intl)).toEqual([
      { label: "Cardholder name", value: "Alice Martin", kind: "text" },
      { label: "Brand", value: "American Express", kind: "text" },
      { label: "Number", value: "378282246310005", kind: "secret" },
      { label: "Expiration", value: "03 / 2029", kind: "text" },
      { label: "Security code", value: "1234", kind: "secret" },
    ]);
  });

  it("lists an identity's fields, its name and address joined", () => {
    const identity = cipher({
      type: 4,
      identity: {
        title: "Ms",
        firstName: "Alice",
        middleName: null,
        lastName: "Martin",
        address1: "1 rue de la Paix",
        address2: " ",
        address3: null,
        city: "Paris",
        state: null,
        postalCode: "75002",
        country: "France",
        company: null,
        email: "alice@example.com",
        phone: null,
        ssn: "1 85 05 78 006 084 36",
        username: null,
        passportNumber: null,
        licenseNumber: null,
      },
    });
    expect(typeFields(identity, intl)).toEqual([
      { label: "Name", value: "Ms Alice Martin", kind: "text" },
      { label: "Email", value: "alice@example.com", kind: "text" },
      { label: "Social security number", value: "1 85 05 78 006 084 36", kind: "secret" },
      { label: "Address", value: "1 rue de la Paix\nParis, 75002\nFrance", kind: "text" },
    ]);
  });

  it("lists an SSH key's fields, its private key hidden", () => {
    const sshKey = cipher({
      type: 5,
      sshKey: {
        privateKey: "-----BEGIN-----",
        publicKey: "ssh-ed25519 AAAA",
        keyFingerprint: "SHA256:x",
      },
    });
    expect(typeFields(sshKey, intl).map(({ kind }) => kind)).toEqual(["secret", "mono", "mono"]);
  });

  it("lists a bank account's fields, its type in words", () => {
    const account = (accountType: string) =>
      cipher({
        type: 6,
        bankAccount: {
          bankName: "BNP",
          nameOnAccount: null,
          accountType,
          accountNumber: "123",
          routingNumber: null,
          branchNumber: null,
          pin: "0000",
          swiftCode: null,
          iban: "FR76",
          bankContactPhone: null,
        },
      });
    expect(typeFields(account("savings"), intl)).toEqual([
      { label: "Bank", value: "BNP", kind: "text" },
      { label: "Account type", value: "Savings", kind: "info" },
      { label: "Account number", value: "123", kind: "secret" },
      { label: "PIN", value: "0000", kind: "secret" },
      { label: "IBAN", value: "FR76", kind: "text" },
    ]);
    expect(typeFields(account("unknown"), intl)[1]).toEqual({
      label: "Account type",
      value: "Other",
      kind: "info",
    });
  });

  it("lists a driver's license and a passport", () => {
    const license = cipher({
      type: 7,
      driversLicense: {
        firstName: "Alice",
        middleName: null,
        lastName: "Martin",
        dateOfBirth: "1985-05-01",
        licenseNumber: "12AB",
        issuingCountry: "FR",
        issuingState: null,
        issueDate: null,
        expirationDate: null,
        issuingAuthority: null,
        licenseClass: "B",
      },
    });
    expect(typeFields(license, intl).map(({ value }) => value)).toEqual([
      "Alice Martin",
      "1985-05-01",
      "12AB",
      "FR",
      "B",
    ]);
    const passport = cipher({
      type: 8,
      passport: {
        surname: "Martin",
        givenName: "Alice",
        dateOfBirth: null,
        sex: "F",
        birthPlace: null,
        nationality: "French",
        issuingCountry: null,
        passportNumber: "19AB12345",
        passportType: null,
        nationalIdentificationNumber: null,
        issuingAuthority: null,
        issueDate: null,
        expirationDate: "2034-01-01",
      },
    });
    expect(typeFields(passport, intl).map(({ value }) => value)).toEqual([
      "Martin",
      "Alice",
      "F",
      "French",
      "19AB12345",
      "2034-01-01",
    ]);
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
