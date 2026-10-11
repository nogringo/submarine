/** The item a popup shows, for the next popup to show it again. */
export interface OpenedItem {
  vault: string;
  id: string;
}

/** In `storage.session`, gone once the browser closes. */
const openedItemKey = "openedItem";

export async function readOpenedItem(): Promise<OpenedItem | undefined> {
  return (await browser.storage.session.get(openedItemKey))[openedItemKey] as
    | OpenedItem
    | undefined;
}

export async function saveOpenedItem(item: OpenedItem) {
  await browser.storage.session.set({ [openedItemKey]: item });
}

export async function forgetOpenedItem() {
  await browser.storage.session.remove(openedItemKey);
}
