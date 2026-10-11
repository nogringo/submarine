import { schnorr } from "@noble/curves/secp256k1.js";
import { bytesToHex, hexToBytes } from "@noble/hashes/utils.js";
import { decrypt, encrypt, getConversationKey } from "nostr-tools/nip44";

const conversationKeys = new Map<string, Uint8Array>();

function conversationKey(privateKey: string, publicKey: string): Uint8Array {
  const id = privateKey + publicKey;
  let key = conversationKeys.get(id);
  if (!key) {
    key = getConversationKey(hexToBytes(privateKey), publicKey);
    // Each gift wrap brings a new key: keep the map small.
    if (conversationKeys.size > 64) conversationKeys.clear();
    conversationKeys.set(id, key);
  }
  return key;
}

/** The Nostr cryptography the Dart core runs through, keys and signatures in hex. */
export const nostrCrypto = {
  sign: (id: string, privateKey: string) =>
    bytesToHex(schnorr.sign(hexToBytes(id), hexToBytes(privateKey))),
  verify: (id: string, publicKey: string, sig: string) =>
    schnorr.verify(hexToBytes(sig), hexToBytes(id), hexToBytes(publicKey)),
  publicKey: (privateKey: string) => bytesToHex(schnorr.getPublicKey(hexToBytes(privateKey))),
  generatePrivateKey: () => bytesToHex(schnorr.utils.randomSecretKey()),
  nip44Encrypt: (plaintext: string, privateKey: string, publicKey: string) =>
    encrypt(plaintext, conversationKey(privateKey, publicKey)),
  nip44Decrypt: (payload: string, privateKey: string, publicKey: string) =>
    decrypt(payload, conversationKey(privateKey, publicKey)),
};
