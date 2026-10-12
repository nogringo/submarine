import type { IntlShape } from "react-intl";
import type { Cipher } from "./cipher";
import { dayFormat, dayTimeFormat } from "./i18n";

type MessageId = FormatjsIntl.Message["ids"];

export type FieldKind =
  | "text"
  /** Hidden until shown. */
  | "secret"
  /** A secret whose digits and special characters stand out once shown. */
  | "password"
  /** A verification key, shown as its current code. */
  | "totp"
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
      add("verificationCode", login?.totp, "totp");
      for (const { uri } of login?.uris ?? []) add("website", uri, "url");
      for (const { rpId, creationDate } of login?.fido2Credentials ?? []) {
        const created = creationDate && formatDate(creationDate, dayFormat);
        add("passkey", created ? t({ id: "passkeyCreated" }, { date: created }) : rpId, "info");
      }
      break;
    }
    case 3: {
      const card = cipher.card;
      add("cardholderName", card?.cardholderName);
      add("cardBrand", card?.brand && cardBrandLabel(card.brand, t({ id: "cardBrandOther" })));
      add("cardNumber", card?.number, "secret");
      add("cardExpiration", join([card?.expMonth?.padStart(2, "0"), card?.expYear], " / "));
      add("cardCode", card?.code, "secret");
      break;
    }
    case 4: {
      const identity = cipher.identity;
      add(
        "fullName",
        join([identity?.title, identity?.firstName, identity?.middleName, identity?.lastName], " "),
      );
      add("username", identity?.username);
      add("company", identity?.company);
      add("email", identity?.email);
      add("phone", identity?.phone);
      add("ssn", identity?.ssn, "secret");
      add("passportNumber", identity?.passportNumber);
      add("licenseNumber", identity?.licenseNumber);
      add(
        "address",
        join(
          [
            identity?.address1,
            identity?.address2,
            identity?.address3,
            join([identity?.city, identity?.state, identity?.postalCode], ", "),
            identity?.country,
          ],
          "\n",
        ),
      );
      break;
    }
    case 5: {
      const sshKey = cipher.sshKey;
      add("privateKey", sshKey?.privateKey, "secret");
      add("publicKey", sshKey?.publicKey, "mono");
      add("fingerprint", sshKey?.keyFingerprint, "mono");
      break;
    }
    case 6: {
      const account = cipher.bankAccount;
      add("bankName", account?.bankName);
      add("accountHolder", account?.nameOnAccount);
      if (account?.accountType != null) {
        add(
          "accountType",
          t({ id: accountTypes[account.accountType] ?? "accountTypeOther" }),
          "info",
        );
      }
      add("accountNumber", account?.accountNumber, "secret");
      add("routingNumber", account?.routingNumber);
      add("branchNumber", account?.branchNumber);
      add("pin", account?.pin, "secret");
      add("swiftCode", account?.swiftCode);
      add("iban", account?.iban);
      add("bankPhone", account?.bankContactPhone);
      break;
    }
    case 7: {
      const license = cipher.driversLicense;
      add("fullName", join([license?.firstName, license?.middleName, license?.lastName], " "));
      add("dateOfBirth", license?.dateOfBirth);
      add("licenseNumber", license?.licenseNumber);
      add("issuingCountry", license?.issuingCountry);
      add("issuingState", license?.issuingState);
      add("issueDate", license?.issueDate);
      add("expirationDate", license?.expirationDate);
      add("issuingAuthority", license?.issuingAuthority);
      add("licenseClass", license?.licenseClass);
      break;
    }
    case 8: {
      const passport = cipher.passport;
      add("surname", passport?.surname);
      add("givenName", passport?.givenName);
      add("dateOfBirth", passport?.dateOfBirth);
      add("sex", passport?.sex);
      add("birthPlace", passport?.birthPlace);
      add("nationality", passport?.nationality);
      add("issuingCountry", passport?.issuingCountry);
      add("passportNumber", passport?.passportNumber);
      add("passportType", passport?.passportType);
      add("nationalId", passport?.nationalIdentificationNumber);
      add("issuingAuthority", passport?.issuingAuthority);
      add("issueDate", passport?.issueDate);
      add("expirationDate", passport?.expirationDate);
      break;
    }
  }
  return rows;
}

/** How Bitwarden's card brand shows. */
export function cardBrandLabel(brand: string, other: string): string {
  if (brand === "Amex") return "American Express";
  if (brand === "Other") return other;
  return brand;
}

/** The parts with a value, trimmed, joined by `separator`, or undefined without any. */
function join(parts: (string | null | undefined)[], separator: string): string | undefined {
  const present = parts.map((part) => part?.trim()).filter((part) => !!part);
  return present.length > 0 ? present.join(separator) : undefined;
}

/** By Bitwarden's bank account type. */
const accountTypes: Record<string, MessageId> = {
  checking: "accountTypeChecking",
  savings: "accountTypeSavings",
  certificateOfDeposit: "accountTypeCertificateOfDeposit",
  lineOfCredit: "accountTypeLineOfCredit",
  investmentBrokerage: "accountTypeInvestmentBrokerage",
  moneyMarket: "accountTypeMoneyMarket",
};

export function customFields(cipher: Cipher, { formatMessage: t }: IntlShape): FieldRow[] {
  return cipher.fields.map(({ name, value, type, linkedId }) => {
    const label = name ?? "";
    switch (type) {
      case 1:
        return { label, value: value ?? "", kind: "password" };
      case 2:
        return { label, value: t({ id: value === "true" ? "yes" : "no" }), kind: "info" };
      case 3: {
        const field = linkedId === null ? "?" : linkedFieldLabel(linkedId, t);
        return { label, value: t({ id: "linkedTo" }, { field }), kind: "info" };
      }
      default:
        return { label, value: value ?? "", kind: "text" };
    }
  });
}

/** The passwords the item used before, each under the date it was replaced. */
export function historyRows(cipher: Cipher, { formatDate }: IntlShape): FieldRow[] {
  return cipher.passwordHistory.map(({ password, lastUsedDate }) => ({
    label: lastUsedDate ? formatDate(lastUsedDate, dayTimeFormat) : "",
    value: password,
    kind: "password",
  }));
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

/** What a linked field stands for, by Bitwarden's LinkedIdType, "?" for one unknown. */
export function linkedFieldLabel(linkedId: number, t: IntlShape["formatMessage"]): string {
  const label = linkedLabels[linkedId];
  return label ? t({ id: label }) : "?";
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
