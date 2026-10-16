import { bytesToHex } from "@noble/hashes/utils.js";
import { finalizeEvent, getPublicKey, SimplePool } from "nostr-tools";
import { createWrap } from "nostr-tools/nip59";
import { relayUrl } from "./relay.ts";

/**
 * Publishes `ciphers`, Bitwarden's cipher JSON, as new items of the vault of `secretKey` on the
 * local relay, as another device of the vault would.
 */
export async function publishItems(secretKey: Uint8Array, ciphers: object[]) {
  const pubkey = getPublicKey(secretKey);
  const pool = new SimplePool();
  try {
    await Promise.all(
      ciphers.map((data) => {
        const now = Date.now();
        const envelope = {
          v: 1,
          id: randomId(),
          type: "item",
          rev: randomId(),
          parents: [],
          modified_at: now,
          data,
        };
        const version = finalizeEvent(
          {
            kind: 21270,
            tags: [["-"]],
            content: JSON.stringify(envelope),
            created_at: Math.floor(now / 1000),
          },
          secretKey,
        );
        return Promise.all(pool.publish([relayUrl], createWrap(version, pubkey)));
      }),
    );
  } finally {
    pool.close([relayUrl]);
  }
}

function randomId() {
  return bytesToHex(crypto.getRandomValues(new Uint8Array(16)));
}
