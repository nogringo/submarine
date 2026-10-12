/** The generator's last options, which it opens with next time, as the app saves them. */
export interface GeneratorSettings {
  type: "password" | "passphrase";
  password: PasswordOptions;
  passphrase: PassphraseOptions;
  username: UsernameOptions;
}

/** In the names of Bitwarden's SDK, as in `nostr_passwords`. */
export interface PasswordOptions {
  length: number;
  uppercase: boolean;
  lowercase: boolean;
  numbers: boolean;
  /** `!@#$%^&*` */
  special: boolean;
  minNumber: number;
  minSpecial: number;
  /** Leaves out I, O, l, 0 and 1. */
  avoidAmbiguous: boolean;
}

export interface PassphraseOptions {
  numWords: number;
  wordSeparator: string;
  capitalize: boolean;
  includeNumber: boolean;
}

export interface UsernameOptions {
  capitalize: boolean;
  /** 4 digits at the end. */
  includeNumber: boolean;
}

/** The bounds of `nostr_passwords`' options. */
export const passwordLengths = { min: 5, max: 128 };
export const maxMinCount = 9;
export const wordCounts = { min: 3, max: 20 };

/** The app's key, in `storage.local`. */
const generatorKey = "generator";

/** As saved, for the core to complete: empty until the generator is first used. */
export async function readGeneratorSettings(): Promise<object> {
  const saved = (await browser.storage.local.get(generatorKey))[generatorKey];
  return typeof saved === "object" && saved !== null ? saved : {};
}

export async function saveGeneratorSettings(settings: GeneratorSettings) {
  await browser.storage.local.set({ [generatorKey]: settings });
}
