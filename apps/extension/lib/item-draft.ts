import type { Item } from "./core";
import type { ItemFormValues } from "./item-form";

/** An item form left unsaved, for the next popup to show it again as it was. */
export interface ItemDraft {
  /** The pubkey of the vault chosen. */
  vault: string;
  type: number;
  /** The item edited, as it was read, none for a new one. */
  item?: Item;
  /** What the form started from, which tells whether it changed. */
  initial: ItemFormValues;
  form: ItemFormValues;
}

/**
 * In `storage.session`, out of reach of content scripts and gone once the browser closes. The core
 * removes it as the vaults lock.
 */
const itemDraftKey = "itemDraft";

export async function readItemDraft(): Promise<ItemDraft | undefined> {
  return (await browser.storage.session.get(itemDraftKey))[itemDraftKey] as ItemDraft | undefined;
}

export async function saveItemDraft(draft: ItemDraft) {
  await browser.storage.session.set({ [itemDraftKey]: draft });
}

export async function forgetItemDraft() {
  await browser.storage.session.remove(itemDraftKey);
}

/** The form of `draft` as a new popup shows it: what was added there no longer takes the focus. */
export function restoredForm({ form }: ItemDraft): ItemFormValues {
  return {
    ...form,
    uris: form.uris.map(({ isNew: _, ...uri }) => uri),
    fields: form.fields.map(({ isNew: _, ...field }) => field),
  };
}
