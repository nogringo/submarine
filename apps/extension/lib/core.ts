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

/** Calls a method of the Dart core, which runs in the background. */
export async function callCore(method: string, args: unknown = {}): Promise<unknown> {
  const request: CoreRequest = { method, args };
  const reply: CoreReply = JSON.parse(await browser.runtime.sendMessage(request));
  if ("error" in reply) throw new CoreError(reply.error.code, reply.error.message);
  return reply.result;
}
