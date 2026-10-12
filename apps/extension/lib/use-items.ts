import { useEffect, useState } from "react";
import { type CoreMethods, callCore, type ItemFilter, type ItemSummary } from "./core";

/**
 * The items of the vault `vault`, or of all vaults without one, that `filter` keeps and `query`
 * finds, read again at each `revision`. Undefined until read.
 */
export function useItems(
  vault: string | undefined,
  query: string,
  filter: ItemFilter,
  revision: number,
): ItemSummary[] | undefined {
  const [items, setItems] = useState<ItemSummary[]>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(
    () => read(vault ? { vault, query, filter } : { query, filter }, setItems),
    [vault, query, filter, revision],
  );
  return items;
}

/**
 * The types of the items of the vault `vault`, or of all vaults without one, trash left out, read
 * again at each `revision`. Undefined until read.
 */
export function useItemTypes(vault: string | undefined, revision: number): number[] | undefined {
  const [types, setTypes] = useState<number[]>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    let current = true;
    void callCore("itemTypes", vault ? { vault } : {}).then((types) => {
      if (current) setTypes(types);
    });
    return () => {
      current = false;
    };
  }, [vault, revision]);
  return types;
}

/**
 * The logins of the vault `vault`, or of all vaults without one, for the page at `url`, read again
 * at each `revision`. Undefined until read, none without a page.
 */
export function usePageItems(
  vault: string | undefined,
  url: string | null | undefined,
  revision: number,
): ItemSummary[] | undefined {
  const [items, setItems] = useState<ItemSummary[]>();
  // biome-ignore lint/correctness/useExhaustiveDependencies: revision tells when to read again.
  useEffect(() => {
    if (url === null) setItems([]);
    if (!url) return;
    return read(vault ? { vault, url } : { url }, setItems);
  }, [vault, url, revision]);
  return items;
}

/** Until the returned function is called. */
function read(args: CoreMethods["items"]["args"], then: (items: ItemSummary[]) => void) {
  let current = true;
  void callCore("items", args).then((items) => {
    if (current) then(items);
  });
  return () => {
    current = false;
  };
}
