import type { ItemFilter } from "./core";

type MessageId = FormatjsIntl.Message["ids"];

/** In the order of the app's, by Bitwarden's cipher type. */
const typeFilters: [type: number, label: MessageId][] = [
  [1, "filterLogins"],
  [3, "filterCards"],
  [4, "filterIdentities"],
  [2, "filterSecureNotes"],
  [5, "filterSshKeys"],
  [6, "filterBankAccounts"],
  [7, "filterDriversLicenses"],
  [8, "filterPassports"],
];

export interface FilterOption {
  filter: ItemFilter;
  label: MessageId;
}

/**
 * The filters worth offering, as the app's chips: all, the favorites, the types of the items there
 * are, and `selected` even if emptied, then the trash.
 */
export function filterOptions(types: readonly number[], selected: ItemFilter): FilterOption[] {
  return [
    { filter: "all", label: "filterAllShort" },
    { filter: "favorites", label: "filterFavorites" },
    ...typeFilters
      .filter(([type]) => type === selected || types.includes(type))
      .map(([type, label]) => ({ filter: type, label })),
    { filter: "trash", label: "filterTrash" },
  ];
}
