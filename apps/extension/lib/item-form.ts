import type { Card, Cipher, Field, Login } from "./cipher";
import type { ItemFilter, MadeUpValue } from "./core";

/**
 * The types the form creates and edits, as the app's, by Bitwarden's cipher type, in the order of
 * its New item menu: logins, cards and secure notes.
 */
export const formTypes = [1, 3, 2];

/** A website of a login in the form, with the URI it edits, whose match setting is kept. */
export interface EditedUri {
  source: Login["uris"][number] | null;
  uri: string;
  /** Added from the form, which focuses it. */
  isNew?: boolean;
}

/** A custom field in the form, with the field it edits, whose other keys are kept. */
export interface EditedField {
  /** Tells it apart in the list while it moves. */
  key: string;
  source: Field;
  name: string;
  /** Of a field that is neither a checkbox nor linked. */
  value: string;
  /** Of a checkbox. */
  checked: boolean;
  linkedId: number | null;
  /** A value the form made up, which it makes up again on demand. */
  madeUp?: MadeUpValue;
  /** Added from the form, which focuses it. */
  isNew?: boolean;
}

/**
 * What the form edits of an item: its name, its notes, the favorite, the custom fields and the fields
 * of a login or a card, as the app's. The rest of the item is kept.
 */
export interface ItemFormValues {
  type: number;
  name: string;
  notes: string;
  favorite: boolean;
  username: string;
  password: string;
  totp: string;
  uris: EditedUri[];
  cardholderName: string;
  number: string;
  brand: string | null;
  expMonth: string | null;
  expYear: string;
  code: string;
  fields: EditedField[];
}

/** The form of `cipher`, or of a new item of `type`. */
export function formOf(cipher: Cipher | undefined, type: number): ItemFormValues {
  const login = cipher?.login;
  const card = cipher?.card;
  const uris = (login?.uris ?? []).map((source) => ({ source, uri: source.uri ?? "" }));
  return {
    type: cipher?.type ?? type,
    name: cipher?.name ?? "",
    notes: cipher?.notes ?? "",
    favorite: cipher?.favorite ?? false,
    username: login?.username ?? "",
    password: login?.password ?? "",
    totp: login?.totp ?? "",
    uris: uris.length > 0 ? uris : [{ source: null, uri: "" }],
    cardholderName: card?.cardholderName ?? "",
    number: card?.number ?? "",
    brand: card?.brand || null,
    expMonth: card?.expMonth || null,
    expYear: card?.expYear ?? "",
    code: card?.code ?? "",
    fields: (cipher?.fields ?? []).map((field) => editedField(field)),
  };
}

export function editedField(
  field: Field,
  options: { madeUp?: MadeUpValue; isNew?: boolean } = {},
): EditedField {
  const valued = field.type !== 2 && field.type !== 3;
  return {
    // Unique across popups too, which a draft carries fields between.
    key: crypto.randomUUID(),
    source: field,
    name: field.name ?? "",
    value: valued ? (field.value ?? "") : "",
    checked: field.value === "true",
    linkedId: field.linkedId,
    ...options,
  };
}

/** What saving would write, to tell whether the form changed: an empty website changes nothing. */
function savedValues(form: ItemFormValues): unknown[] {
  return [
    form.name.trim(),
    form.username,
    form.password,
    form.totp,
    form.notes,
    form.favorite,
    form.uris.map(({ uri }) => uri.trim()).filter((uri) => uri !== ""),
    form.cardholderName,
    form.number,
    form.brand,
    form.expMonth,
    form.expYear,
    form.code,
    form.fields.map(({ name, value, checked, linkedId }) => [name, value, checked, linkedId]),
  ];
}

export function formChanged(form: ItemFormValues, initial: ItemFormValues): boolean {
  return JSON.stringify(savedValues(form)) !== JSON.stringify(savedValues(initial));
}

const orNone = (text: string) => (text === "" ? null : text);

/** The cipher the form saves: `original`'s, or a new one, with what the form edits. */
export function cipherOf(form: ItemFormValues, original: Cipher | undefined): Cipher {
  const cipher: Cipher = structuredClone(original) ?? emptyCipher(form.type);
  cipher.name = form.name.trim();
  cipher.notes = orNone(form.notes);
  cipher.favorite = form.favorite;
  cipher.fields = form.fields.map(fieldOf);
  switch (form.type) {
    case 1:
      cipher.login = {
        ...(cipher.login ?? emptyLogin()),
        username: orNone(form.username),
        password: orNone(form.password),
        totp: orNone(form.totp),
        uris: form.uris.flatMap(({ source, uri }) => {
          const text = uri.trim();
          return text ? [{ ...source, uri: text }] : [];
        }),
      };
      break;
    case 3:
      cipher.card = {
        ...(cipher.card ?? emptyCard()),
        cardholderName: orNone(form.cardholderName),
        number: orNone(form.number),
        brand: form.brand,
        expMonth: form.expMonth,
        expYear: orNone(form.expYear),
        code: orNone(form.code),
      };
      break;
    case 2:
      cipher.secureNote ??= { type: 0 };
      break;
  }
  return cipher;
}

function fieldOf({ source, name, value, checked, linkedId }: EditedField): Field {
  return {
    ...source,
    name,
    value: source.type === 2 ? String(checked) : source.type === 3 ? source.value : orNone(value),
    linkedId: source.type === 3 ? linkedId : source.linkedId,
  };
}

function emptyCipher(type: number): Cipher {
  return {
    type,
    name: "",
    notes: null,
    fields: [],
    login: null,
    secureNote: null,
    card: null,
    identity: null,
    sshKey: null,
    bankAccount: null,
    driversLicense: null,
    passport: null,
    passwordHistory: [],
    favorite: false,
    creationDate: null,
    revisionDate: null,
    deletedDate: null,
  };
}

function emptyLogin(): Login {
  return { username: null, password: null, totp: null, uris: [], fido2Credentials: [] };
}

function emptyCard(): Card {
  return {
    cardholderName: null,
    brand: null,
    number: null,
    expMonth: null,
    expYear: null,
    code: null,
  };
}

/** Bitwarden's card brands, in the order of its form. */
const cardBrands = [
  "Visa",
  "Mastercard",
  "Amex",
  "Discover",
  "Diners Club",
  "JCB",
  "Maestro",
  "UnionPay",
  "RuPay",
  "Other",
];

/**
 * The brands to pick from, each the value saved with the brand it stands for, `stored` in place of
 * the one it matches, or else added alone, standing for none: a field left untouched then saves
 * what the item had, "visa" rather than "Visa" for instance.
 */
export function brandOptions(stored: string | null): { value: string; brand: string | null }[] {
  return keeping(
    cardBrands,
    stored,
    (brand, stored) => brand.toLowerCase() === stored.toLowerCase(),
  ).map(({ value, standsFor }) => ({ value, brand: standsFor }));
}

/** The months to pick from, as {@link brandOptions}: "04" rather than "4" when the item had it. */
export function monthOptions(stored: string | null): { value: string; month: number | null }[] {
  const months = Array.from({ length: 12 }, (_, index) => `${index + 1}`);
  return keeping(months, stored, (month, stored) => Number(stored) === Number(month)).map(
    ({ value, standsFor }) => ({ value, month: standsFor === null ? null : Number(standsFor) }),
  );
}

function keeping(
  values: string[],
  stored: string | null,
  matches: (value: string, stored: string) => boolean,
): { value: string; standsFor: string | null }[] {
  return [
    ...values.map((value) => ({
      value: stored !== null && matches(value, stored) ? stored : value,
      standsFor: value,
    })),
    ...(stored !== null && !values.some((value) => matches(value, stored))
      ? [{ value: stored, standsFor: null }]
      : []),
  ];
}

/** The fields of an item of `type` that a custom field can be linked to, in Bitwarden's order. */
export function linkedIds(type: number): number[] {
  if (type === 1) return [100, 101];
  if (type === 3) return [300, 305, 304, 301, 302, 303];
  return [];
}

/** Whether the list of `filter` shows `cipher`, as the app's filters do. */
export function filterKeeps(filter: ItemFilter, cipher: Cipher): boolean {
  if (filter === "trash") return !!cipher.deletedDate;
  if (cipher.deletedDate) return false;
  if (filter === "all") return true;
  if (filter === "favorites") return cipher.favorite;
  return cipher.type === filter;
}

/**
 * The name and the website a new login gets over the web page at `url`, as Bitwarden gives them: its
 * host, then its origin, which leaves out a path or a query that could hold a secret.
 */
export function loginForPage(url: string): { name: string; uri: string } | undefined {
  try {
    const { protocol, hostname, origin } = new URL(url);
    if (protocol !== "http:" && protocol !== "https:") return;
    return { name: hostname.replace(/^www\./, ""), uri: origin };
  } catch {
    return;
  }
}
