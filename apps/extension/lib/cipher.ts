/** Bitwarden's cipher JSON, as the vault keeps an item: what the extension shows of it. */
export interface Cipher {
  /** 1 for a login, 2 a secure note, and so on. */
  type: number;
  name: string;
  notes: string | null;
  fields: Field[];
  login: Login | null;
  card: Card | null;
  identity: Identity | null;
  sshKey: SshKey | null;
  bankAccount: BankAccount | null;
  driversLicense: DriversLicense | null;
  passport: Passport | null;
  passwordHistory: PasswordHistory[];
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

export interface Card {
  cardholderName: string | null;
  /** "Visa", "Amex", "Other", and so on. */
  brand: string | null;
  number: string | null;
  expMonth: string | null;
  expYear: string | null;
  code: string | null;
}

export interface Identity {
  title: string | null;
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
  address1: string | null;
  address2: string | null;
  address3: string | null;
  city: string | null;
  state: string | null;
  postalCode: string | null;
  country: string | null;
  company: string | null;
  email: string | null;
  phone: string | null;
  ssn: string | null;
  username: string | null;
  passportNumber: string | null;
  licenseNumber: string | null;
}

export interface SshKey {
  privateKey: string | null;
  publicKey: string | null;
  keyFingerprint: string | null;
}

export interface BankAccount {
  bankName: string | null;
  nameOnAccount: string | null;
  /** "checking", "savings", and so on. */
  accountType: string | null;
  accountNumber: string | null;
  routingNumber: string | null;
  branchNumber: string | null;
  pin: string | null;
  swiftCode: string | null;
  iban: string | null;
  bankContactPhone: string | null;
}

export interface DriversLicense {
  firstName: string | null;
  middleName: string | null;
  lastName: string | null;
  dateOfBirth: string | null;
  licenseNumber: string | null;
  issuingCountry: string | null;
  issuingState: string | null;
  issueDate: string | null;
  expirationDate: string | null;
  issuingAuthority: string | null;
  licenseClass: string | null;
}

export interface Passport {
  surname: string | null;
  givenName: string | null;
  dateOfBirth: string | null;
  sex: string | null;
  birthPlace: string | null;
  nationality: string | null;
  issuingCountry: string | null;
  passportNumber: string | null;
  passportType: string | null;
  nationalIdentificationNumber: string | null;
  issuingAuthority: string | null;
  issueDate: string | null;
  expirationDate: string | null;
}

export interface Field {
  name: string | null;
  value: string | null;
  /** 0 for text, 1 hidden, 2 boolean, 3 linked. */
  type: number;
  /** The field a linked one stands for, as Bitwarden numbers them. */
  linkedId: number | null;
}

export interface PasswordHistory {
  password: string;
  /** In ISO 8601. */
  lastUsedDate: string | null;
}
