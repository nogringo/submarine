import { bytesToHex } from "@noble/hashes/utils.js";
import { finalizeEvent, getPublicKey, SimplePool } from "nostr-tools";
import { createWrap } from "nostr-tools/nip59";

/** Default relays of a vault that serve its gift wraps without NIP-42. */
const relays = ["wss://relay.primal.net", "wss://relay.nos.social", "wss://relay.coinos.io"];

/**
 * Publishes `ciphers`, Bitwarden's cipher JSON, as new items of the vault of `secretKey`, as another
 * device of the vault would. Each one lands on every relay that takes it, one at least.
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
        return landed(pool.publish(relays, createWrap(version, pubkey)));
      }),
    );
  } finally {
    pool.close(relays);
  }
}

/** Waits for every relay, as closing the pool at the first one could keep the others from storing. */
async function landed(publishes: Promise<string>[]) {
  const results = await Promise.allSettled(publishes);
  if (!results.some((result) => result.status === "fulfilled")) {
    throw new Error("No relay took the item");
  }
}

function randomId() {
  return bytesToHex(crypto.getRandomValues(new Uint8Array(16)));
}
