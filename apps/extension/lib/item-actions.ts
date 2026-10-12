import type { Cipher } from "./cipher";
import { formTypes } from "./item-form";

/** What the menu of an item's row does to it, as the app's. */
export type ItemAction =
  | "copyUsername"
  | "copyPassword"
  | "copyTotp"
  | "copyNumber"
  | "favorite"
  | "edit"
  | "trash"
  | "restore"
  | "delete";

const copies = ["copyUsername", "copyPassword", "copyTotp", "copyNumber"] as const;

export type CopyAction = (typeof copies)[number];

export function isCopy(action: ItemAction): action is CopyAction {
  return (copies as readonly ItemAction[]).includes(action);
}

/**
 * The copies of what `cipher` holds, its verification code once `totpValid`, then the changes. In
 * the trash: restore the item, or delete it for good. Only the form's types have Edit.
 */
export function availableActions(cipher: Cipher, totpValid: boolean): ItemAction[] {
  return [
    ...copies.filter((copy) =>
      copy === "copyTotp" ? totpValid : copiedFrom(cipher, copy) !== undefined,
    ),
    ...(cipher.deletedDate
      ? (["restore", "delete"] as const)
      : ([
          "favorite",
          ...(formTypes.includes(cipher.type) ? ["edit" as const] : []),
          "trash",
        ] as const)),
  ];
}

/** What `copy` copies from `cipher`, but its verification code, which the core computes. */
export function copiedFrom(
  cipher: Cipher,
  copy: Exclude<CopyAction, "copyTotp">,
): string | undefined {
  const value = {
    copyUsername: cipher.login?.username,
    copyPassword: cipher.login?.password,
    copyNumber: cipher.card?.number,
  }[copy];
  return value?.trim() ? value : undefined;
}
