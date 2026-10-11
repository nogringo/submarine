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

/** The core's methods: their arguments and their result. */
export interface CoreMethods {
  vaults: { args: Record<string, never>; result: Vault[] };
  /** Opens the vault of an nsec, a key in hex or an ncryptsec that the password decrypts. */
  addVault: {
    args: { key: string; password?: string; name: string; color: number };
    result: Vault;
  };
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
