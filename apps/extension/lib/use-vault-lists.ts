import { useEffect, useState } from "react";
import { callCore, type VaultLists } from "./core";

/** The relays and the servers of the vault `vault`, read again at each `revision`. Undefined until read. */
export function useVaultLists(vault: string, revision: number): VaultLists | undefined {
  const [lists, setLists] = useState<VaultLists>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    let current = true;
    void callCore("vaultLists", { vault }).then((lists) => {
      if (current) setLists(lists);
    });
    return () => {
      current = false;
    };
  }, [vault, revision]);
  return lists;
}
