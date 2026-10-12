import { useEffect, useState } from "react";
import { callCore, type Item } from "./core";

/**
 * The item `id` of the vault `vault`, in the trash or not, read again at each `revision`. Undefined
 * until read, null once gone.
 */
export function useItem(vault: string, id: string, revision: number): Item | null | undefined {
  const [item, setItem] = useState<Item | null>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    let current = true;
    callCore("item", { vault, id }).then((item) => {
      if (current) setItem(item);
    });
    return () => {
      current = false;
    };
  }, [vault, id, revision]);
  return item;
}
