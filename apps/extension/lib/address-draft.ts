import type { VaultAddress } from "./core";

/** The addresses of a list, public then private. */
export interface Listed {
  public: string[];
  private: string[];
}

/** The changes made to a list until Save, as the app keeps them. */
export interface AddressDraft {
  removed: string[];
  added: VaultAddress[];
  /** The rows once one moved, in their new order. */
  order?: string[];
}

export const noChanges: AddressDraft = { removed: [], added: [] };

export const sameUrls = (a: string[], b: string[]) =>
  a.length === b.length && a.every((url, i) => url === b[i]);

/** The rows of each group in the order of the draft, the removed ones still among them. */
export function draftRows(listed: Listed, draft: AddressDraft): Listed {
  const group = (isPrivate: boolean) => {
    const rows = [
      ...(isPrivate ? listed.private : listed.public),
      ...draft.added.filter((address) => address.private === isPrivate).map(({ url }) => url),
    ];
    const { order } = draft;
    if (!order) return rows;
    return [
      ...order.filter((url) => rows.includes(url)),
      ...rows.filter((url) => !order.includes(url)),
    ];
  };
  return { public: group(false), private: group(true) };
}

/** What Save publishes. */
export function draftLists(listed: Listed, draft: AddressDraft): Listed {
  const rows = draftRows(listed, draft);
  const kept = (urls: string[], listedUrls: string[]) =>
    urls.filter((url) => !(draft.removed.includes(url) && listedUrls.includes(url)));
  return {
    public: kept(rows.public, listed.public),
    private: kept(rows.private, listed.private),
  };
}

export function draftChanged(listed: Listed, draft: AddressDraft): boolean {
  const lists = draftLists(listed, draft);
  return !sameUrls(lists.public, listed.public) || !sameUrls(lists.private, listed.private);
}

/** Adds `address`, or keeps it if the draft removed it from the same group. */
export function addToDraft(listed: Listed, draft: AddressDraft, address: VaultAddress) {
  const group = address.private ? listed.private : listed.public;
  if (group.includes(address.url)) {
    return { ...draft, removed: draft.removed.filter((url) => url !== address.url) };
  }
  return { ...draft, added: [...draft.added, address] };
}

/** Puts back `defaults`, public and in their order. */
export function resetDraft(listed: Listed, defaults: string[]): AddressDraft {
  const all = [...listed.public, ...listed.private];
  return {
    removed: all.filter((url) => !defaults.includes(url)),
    added: defaults.filter((url) => !all.includes(url)).map((url) => ({ url, private: false })),
    order: [...defaults],
  };
}

/**
 * Moves `url` to the row `to` of all the rows, kept among those of its group: the private addresses
 * stay after the public ones, as published.
 */
export function moveInDraft(
  listed: Listed,
  draft: AddressDraft,
  url: string,
  to: number,
): AddressDraft {
  const rows = draftRows(listed, draft);
  const isPublic = rows.public.includes(url);
  const group = isPublic ? rows.public : rows.private;
  const from = group.indexOf(url);
  const offset = isPublic ? 0 : rows.public.length;
  const target = Math.min(Math.max(to - offset, 0), group.length - 1);
  if (from < 0 || target === from) return draft;
  const moved = group.filter((each) => each !== url);
  moved.splice(target, 0, url);
  return { ...draft, order: isPublic ? [...moved, ...rows.private] : [...rows.public, ...moved] };
}
