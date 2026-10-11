import type { Cipher } from "./cipher";

export interface CoreRequest {
  method: string;
  args?: unknown;
}

export type CoreReply = { result: unknown } | { error: { code: string; message: string | null } };

/** An error of the core, which the user can be told about by its code. */
export class CoreError extends Error {
  constructor(
    readonly code: string,
    message: string | null,
  ) {
    super(message ?? code);
    this.name = "CoreError";
  }
}

/** A vault opened on this device, as the popup sees it: without its key. */
export interface Vault {
  pubkey: string;
  name: string;
  /** In ARGB, as the app saves it. */
  color: number;
}

/** An item as a list shows it. */
export interface ItemSummary {
  /** The pubkey of its vault. */
  vault: string;
  id: string;
  /** Bitwarden's cipher type: 1 for a login, 2 a secure note, and so on. */
  type: number;
  name: string;
  /** A login's username, a card's brand and last digits, and so on. */
  subtitle: string | null;
  /** What the copy button of its row copies, as in the app. */
  copies: "password" | "number" | null;
}

/** An item in full. */
export interface Item {
  /** The pubkey of its vault. */
  vault: string;
  id: string;
  cipher: Cipher;
}

/** Where the sync of a vault stands. */
export interface SyncState {
  pubkey: string;
  /** Failed once every relay did. */
  phase: "idle" | "syncing" | "synced" | "failed";
  /** In ISO 8601, null until the vault reached a relay once. */
  lastSync: string | null;
}

/** The port a popup holds open for the vaults to sync, where the core tells what changed. */
export const syncPort = "sync";

/**
 * What the core tells the popups through {@link syncPort}: the sync or the items of a vault moved,
 * or the vaults locked or unlocked.
 */
export type CoreEvent = "vaultsChanged";

/** Whether a lock password protects the vaults, and whether it must unlock them now. */
export interface LockState {
  hasPassword: boolean;
  locked: boolean;
}

/** When the vaults lock themselves once a lock password protects them, as the app offers it. */
export const lockTimeouts = [
  "immediately",
  "oneMinute",
  "fiveMinutes",
  "fifteenMinutes",
  "thirtyMinutes",
  "oneHour",
  "fourHours",
  "onRestart",
] as const;

export type LockTimeout = (typeof lockTimeouts)[number];

/** The core's methods: their arguments and their result. */
export interface CoreMethods {
  lockState: { args: Record<string, never>; result: LockState };
  /** Of 12 characters at least. Leaves the vaults unlocked. */
  setLockPassword: { args: { password: string }; result: null };
  /** Stops the sync, and lets go of the vaults' keys and items until unlocked. */
  lock: { args: Record<string, never>; result: null };
  /** Fails with `wrongLockPassword`. */
  unlock: { args: { password: string }; result: null };
  generatePassphrase: { args: Record<string, never>; result: string };
  /** A use of the popup, which pushes the lock back. */
  used: { args: Record<string, never>; result: null };
  lockTimeout: { args: Record<string, never>; result: LockTimeout };
  setLockTimeout: { args: { timeout: LockTimeout }; result: null };
  vaults: { args: Record<string, never>; result: Vault[] };
  /** Opens the vault of an nsec, a key in hex or an ncryptsec that the password decrypts. */
  addVault: {
    args: { key: string; password?: string; name: string; color: number };
    result: Vault;
  };
  /** Renames a vault or changes its color, on this device. */
  editVault: { args: { vault: string; name?: string; color?: number }; result: Vault };
  /** Removes a vault from this device, its cache included, while its relays keep it. */
  removeVault: { args: { vault: string }; result: null };
  /** Of one vault, or of all without one, at once rather than at the next pass. */
  syncNow: { args: { vault?: string }; result: null };
  /** Of the vaults syncing, while a popup holds {@link syncPort} open. */
  syncStates: { args: Record<string, never>; result: SyncState[] };
  /** Of one vault, or of all without one, trash left out, by name, as the app's search finds them. */
  items: { args: { vault?: string; query?: string }; result: ItemSummary[] };
  /** Null once in the trash or gone. */
  item: { args: { vault: string; id: string }; result: Item | null };
  /** The code of a verification key at `at`, in milliseconds, and how long a code lasts, in seconds. */
  totp: { args: { key: string; at: number }; result: { code: string; period: number } };
}

/** Calls a method of the Dart core, which runs in the background. */
export async function callCore<M extends keyof CoreMethods>(
  method: M,
  args: CoreMethods[M]["args"],
): Promise<CoreMethods[M]["result"]> {
  const request: CoreRequest = { method, args };
  const reply: CoreReply = JSON.parse(await browser.runtime.sendMessage(request));
  if ("error" in reply) throw new CoreError(reply.error.code, reply.error.message);
  return reply.result as CoreMethods[M]["result"];
}
