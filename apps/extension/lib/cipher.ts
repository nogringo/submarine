/** Bitwarden's cipher JSON, as the vault keeps an item: what the extension shows of it. */
export interface Cipher {
  /** 1 for a login, 2 a secure note, and so on. */
  type: number;
  name: string;
  notes: string | null;
  fields: Field[];
  login: Login | null;
  /** In ISO 8601. */
  creationDate: string | null;
  revisionDate: string | null;
}

export interface Login {
  username: string | null;
  password: string | null;
  totp: string | null;
  uris: { uri: string | null }[];
  /** Every value as a string, as Bitwarden exports them. */
  fido2Credentials: { rpId?: string; creationDate?: string }[];
}

export interface Field {
  name: string | null;
  value: string | null;
  /** 0 for text, 1 hidden, 2 boolean, 3 linked. */
  type: number;
  /** The field a linked one stands for, as Bitwarden numbers them. */
  linkedId: number | null;
}
