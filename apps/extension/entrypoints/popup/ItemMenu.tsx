import deleteForever from "@material-design-icons/svg/outlined/delete_forever.svg";
import timer from "@material-design-icons/svg/outlined/timer.svg";
import creditCard from "@material-design-icons/svg/round/credit_card.svg";
import deleteOutline from "@material-design-icons/svg/round/delete_outline.svg";
import editIcon from "@material-design-icons/svg/round/edit.svg";
import password from "@material-design-icons/svg/round/password.svg";
import personOutline from "@material-design-icons/svg/round/person_outline.svg";
import restoreFromTrash from "@material-design-icons/svg/round/restore_from_trash.svg";
import star from "@material-design-icons/svg/round/star.svg";
import starOutline from "@material-design-icons/svg/round/star_outline.svg";
import { useEffect, useState } from "react";
import { useIntl } from "react-intl";
import { ConfirmDialog } from "@/components/Dialog";
import { ContextMenu, type MenuAction } from "@/components/MoreMenu";
import { copyToClipboard } from "@/lib/clipboard";
import { callCore, type Item } from "@/lib/core";
import { availableActions, copiedFrom, type ItemAction, isCopy } from "@/lib/item-actions";

/** The item of a row whose menu opens at `x` and `y` in the window. */
export interface ItemMenuRequest {
  vault: string;
  id: string;
  x: number;
  y: number;
}

/**
 * The menu of an item's row, as the app's: copies what the item holds, then changes it. Reads the
 * item first, as the list holds no secret. `onEdit` opens its form, `onCopied` and `onFailed` tell
 * how an action went, `onDone` once the menu and its dialog closed.
 */
export function ItemMenu({
  request,
  onEdit,
  onCopied,
  onFailed,
  onDone,
}: {
  request: ItemMenuRequest;
  onEdit: (item: Item) => void;
  onCopied: () => void;
  onFailed: () => void;
  onDone: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [read, setRead] = useState<{ item: Item; actions: ItemAction[] }>();
  const [menuOpen, setMenuOpen] = useState(true);
  const [confirmingDelete, setConfirmingDelete] = useState(false);
  useEffect(() => {
    let current = true;
    void (async () => {
      const item = await callCore("item", { vault: request.vault, id: request.id });
      if (!current) return;
      if (!item) {
        setMenuOpen(false);
        return;
      }
      const totpValid = (await totpCode(item.cipher.login?.totp)) !== undefined;
      if (current) setRead({ item, actions: availableActions(item.cipher, totpValid) });
    })();
    return () => {
      current = false;
    };
  }, [request]);
  useEffect(() => {
    if (!menuOpen && !confirmingDelete) onDone();
  }, [menuOpen, confirmingDelete, onDone]);

  if (!read) return null;
  const { item } = read;
  const { vault, id, cipher } = item;
  const change = (call: () => Promise<null>) => call().catch(onFailed);
  const run = async (action: ItemAction) => {
    if (isCopy(action)) {
      const value =
        action === "copyTotp" ? await totpCode(cipher.login?.totp) : copiedFrom(cipher, action);
      if (value === undefined) return;
      await copyToClipboard(value, { sensitive: action !== "copyUsername" });
      onCopied();
      return;
    }
    switch (action) {
      case "favorite":
        return change(() => callCore("setFavorite", { vault, id, favorite: !cipher.favorite }));
      case "edit":
        return onEdit(item);
      case "trash":
        return change(() => callCore("trashItem", { vault, id }));
      case "restore":
        return change(() => callCore("restoreItem", { vault, id }));
      case "delete":
        return setConfirmingDelete(true);
    }
  };
  const menuAction = (action: ItemAction, index: number): MenuAction<ItemAction> => {
    const previous = read.actions[index - 1];
    return {
      id: action,
      ...actionLook(action, cipher.favorite),
      label: t({ id: actionLabel(action, cipher.favorite) }),
      // The copies apart from the changes, as in the app.
      separated: previous !== undefined && isCopy(previous) !== isCopy(action),
    };
  };
  return (
    <>
      {menuOpen && (
        <ContextMenu
          x={request.x}
          y={request.y}
          label={cipher.name}
          actions={read.actions.map(menuAction)}
          onAction={(action) => void run(action)}
          onClose={() => setMenuOpen(false)}
        />
      )}
      <ConfirmDialog
        title={t({ id: "deleteItemTitle" })}
        cancel={t({ id: "cancel" })}
        confirm={t({ id: "delete" })}
        onConfirm={() => void change(() => callCore("deleteItem", { vault, id }))}
        isOpen={confirmingDelete}
        onOpenChange={setConfirmingDelete}
      >
        <p>{t({ id: "deleteItemBody" })}</p>
      </ConfirmDialog>
    </>
  );
}

/** The current code of a verification key, none for a key that is not one. */
async function totpCode(key: string | null | undefined): Promise<string | undefined> {
  if (!key?.trim()) return;
  try {
    return (await callCore("totp", { key, at: Date.now() })).code;
  } catch {
    return;
  }
}

type MessageId = FormatjsIntl.Message["ids"];

function actionLabel(action: ItemAction, favorite: boolean): MessageId {
  switch (action) {
    case "favorite":
      return favorite ? "removeFromFavorites" : "addToFavorites";
    case "trash":
      return "moveToTrash";
    case "delete":
      return "deletePermanently";
    default:
      return action;
  }
}

function actionLook(action: ItemAction, favorite: boolean): { icon: string; danger?: boolean } {
  switch (action) {
    case "copyUsername":
      return { icon: personOutline };
    case "copyPassword":
      return { icon: password };
    case "copyTotp":
      return { icon: timer };
    case "copyNumber":
      return { icon: creditCard };
    case "favorite":
      return { icon: favorite ? star : starOutline };
    case "edit":
      return { icon: editIcon };
    case "trash":
      return { icon: deleteOutline };
    case "restore":
      return { icon: restoreFromTrash };
    case "delete":
      return { icon: deleteForever, danger: true };
  }
}
