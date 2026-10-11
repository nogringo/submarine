import { describe, expect, it } from "vitest";
import { nostrCrypto } from "./nostr-crypto";

// BIP-340 test vector 0.
const vector = {
  privateKey: "0000000000000000000000000000000000000000000000000000000000000003",
  publicKey: "f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9",
  message: "0000000000000000000000000000000000000000000000000000000000000000",
  sig:
    "e907831f80848d1069a5371b402410364bdf1c5f8307b0084c55f1ce2dca8215" +
    "25f66a4a85ea8b71e482a74f382d2ce5ebeee8fdb2172f477df4900d310536c0",
};

describe("nostrCrypto", () => {
  it("derives the public key", () => {
    expect(nostrCrypto.publicKey(vector.privateKey)).toBe(vector.publicKey);
  });

  it("verifies a signature", () => {
    expect(nostrCrypto.verify(vector.message, vector.publicKey, vector.sig)).toBe(true);
    const otherMessage = `${vector.message.slice(0, -1)}1`;
    expect(nostrCrypto.verify(otherMessage, vector.publicKey, vector.sig)).toBe(false);
  });

  it("signs what it verifies", () => {
    const privateKey = nostrCrypto.generatePrivateKey();
    const sig = nostrCrypto.sign(vector.message, privateKey);
    expect(nostrCrypto.verify(vector.message, nostrCrypto.publicKey(privateKey), sig)).toBe(true);
  });

  it("encrypts with NIP-44 for each recipient", () => {
    const [alice, bob, carol] = [1, 2, 3].map(() => {
      const privateKey = nostrCrypto.generatePrivateKey();
      return { privateKey, publicKey: nostrCrypto.publicKey(privateKey) };
    }) as [Key, Key, Key];
    const toBob = nostrCrypto.nip44Encrypt("for bob", alice.privateKey, bob.publicKey);
    const toCarol = nostrCrypto.nip44Encrypt("for carol", alice.privateKey, carol.publicKey);
    expect(nostrCrypto.nip44Decrypt(toBob, bob.privateKey, alice.publicKey)).toBe("for bob");
    expect(nostrCrypto.nip44Decrypt(toCarol, carol.privateKey, alice.publicKey)).toBe("for carol");
    expect(() => nostrCrypto.nip44Decrypt(toBob, carol.privateKey, alice.publicKey)).toThrow();
  });
});

interface Key {
  privateKey: string;
  publicKey: string;
}
