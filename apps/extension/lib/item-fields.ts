import type { IntlShape } from "react-intl";
import type { Cipher } from "./cipher";
import { dayFormat } from "./i18n";

type MessageId = FormatjsIntl.Message["ids"];

export type FieldKind =
  | "text"
  /** Hidden until shown. */
  | "secret"
  /** A secret whose digits and special characters stand out once shown. */
  | "password"
  | "url"
  | "mono"
  /** Shown as is. */
  | "info";

export interface FieldRow {
  label: string;
  value: string;
  kind: FieldKind;
}

/**
 * The fields of the cipher's type, without the empty ones, as the app lists them. Notes and custom
 * fields are apart.
 */
export function typeFields(
  cipher: Cipher,
  { formatMessage: t, formatDate }: IntlShape,
): FieldRow[] {
  const rows: FieldRow[] = [];
  const add = (label: MessageId, value: string | null | undefined, kind: FieldKind = "text") => {
    if (value?.trim()) rows.push({ label: t({ id: label }), value, kind });
  };
  switch (cipher.type) {
    case 1: {
      const login = cipher.login;
      add("username", login?.username);
      add("password", login?.password, "password");
      for (const { uri } of login?.uris ?? []) add("website", uri, "url");
      for (const { rpId, creationDate } of login?.fido2Credentials ?? []) {
        const created = creationDate && formatDate(creationDate, dayFormat);
        add("passkey", created ? t({ id: "passkeyCreated" }, { date: created }) : rpId, "info");
      }
      break;
    }
  }
  return rows;
}

export function customFields(cipher: Cipher, { formatMessage: t }: IntlShape): FieldRow[] {
  return cipher.fields.map(({ name, value, type, linkedId }) => {
    const label = name ?? "";
    switch (type) {
      case 1:
        return { label, value: value ?? "", kind: "password" };
      case 2:
        return { label, value: t({ id: value === "true" ? "yes" : "no" }), kind: "info" };
      case 3: {
        const linked = linkedId === null ? undefined : linkedLabels[linkedId];
        const field = linked ? t({ id: linked }) : "?";
        return { label, value: t({ id: "linkedTo" }, { field }), kind: "info" };
      }
      default:
        return { label, value: value ?? "", kind: "text" };
    }
  });
}

/** The page to open for a login URI, none for what is not a web address. */
export function websiteUrl(value: string): string | undefined {
  const text = value.trim();
  try {
    const url = new URL(text.includes("://") ? text : `https://${text}`);
    if (!url.hostname || (url.protocol !== "http:" && url.protocol !== "https:")) return;
    return url.href;
  } catch {
    return;
  }
}

/** By Bitwarden's LinkedIdType. */
const linkedLabels: Record<number, MessageId> = {
  100: "username",
  101: "password",
  300: "cardholderName",
  301: "cardExpMonth",
  302: "cardExpYear",
  303: "cardCode",
  304: "cardBrand",
  305: "cardNumber",
  400: "identityTitle",
  401: "middleName",
  402: "address",
  403: "address",
  404: "address",
  405: "city",
  406: "state",
  407: "postalCode",
  408: "country",
  409: "company",
  410: "email",
  411: "phone",
  412: "ssn",
  413: "username",
  414: "passportNumber",
  415: "licenseNumber",
  416: "firstName",
  417: "lastName",
  418: "fullName",
};
