import { useEffect, useState } from "react";
import { callCore, type ItemSummary } from "./core";

/**
 * The items of the vault `vault`, or of all vaults without one, that `query` finds, read again at
 * each `revision`. Undefined until read.
 */
export function useItems(
  vault: string | undefined,
  query: string,
  revision: number,
): ItemSummary[] | undefined {
  const [items, setItems] = useState<ItemSummary[]>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    let current = true;
    callCore("items", vault ? { vault, query } : { query }).then((items) => {
      if (current) setItems(items);
    });
    return () => {
      current = false;
    };
  }, [vault, query, revision]);
  return items;
}
