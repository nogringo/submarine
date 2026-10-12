import deleteForever from "@material-design-icons/svg/outlined/delete_forever.svg";
import deleteOutline from "@material-design-icons/svg/round/delete_outline.svg";
import restoreFromTrash from "@material-design-icons/svg/round/restore_from_trash.svg";
import star from "@material-design-icons/svg/round/star.svg";
import starOutline from "@material-design-icons/svg/round/star_outline.svg";
import { useEffect, useRef, useState } from "react";
import { useIntl } from "react-intl";
import { FilledButton, IconButton, OutlinedButton } from "@/components/Button";
import { ConfirmDialog } from "@/components/Dialog";
import { FieldCard } from "@/components/FieldCard";
import { Icon } from "@/components/Icon";
import { ItemIcon, itemTypeIcon, itemTypeLabel } from "@/components/ItemIcon";
import { MoreMenu } from "@/components/MoreMenu";
import { Page, PageHeader } from "@/components/Page";
import { PasswordHistoryCard } from "@/components/PasswordHistoryCard";
import { VaultBadge } from "@/components/VaultAvatar";
import type { Cipher } from "@/lib/cipher";
import { callCore, type Item, type Vault } from "@/lib/core";
import { dayFormat } from "@/lib/i18n";
import { customFields, historyRows, typeFields } from "@/lib/item-fields";
import { useItem } from "@/lib/use-item";
import "./ItemDetail.css";

/**
 * An item over the list, read again at each `revision`, until `onBack` or Escape, or `onLeft` once
 * moved to the trash, out of it, or deleted. With `onFill`, a login for the page the popup opened
 * over, which it fills. `onFailed` tells that a change could not be saved.
 */
export function ItemDetail({
  vault,
  id,
  revision,
  onBack,
  onLeft,
  onFailed,
  onFill,
}: {
  vault: Vault;
  id: string;
  revision: number;
  onBack: () => void;
  onLeft: () => void;
  onFailed: () => void;
  onFill?: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const item = useItem(vault.pubkey, id, revision);
  const back = useRef<HTMLButtonElement>(null);
  useEffect(() => {
    if (item === null) back.current?.focus();
  }, [item]);
  return (
    <Page
      className="item-detail"
      onBack={onBack}
      backRef={back}
      actions={item && <Actions item={item} onLeft={onLeft} onFailed={onFailed} />}
    >
      {item === null ? (
        <p className="item-detail-missing">{t({ id: "itemNotFound" })}</p>
      ) : (
        item && <Content cipher={item.cipher} vault={vault} onFill={onFill} />
      )}
    </Page>
  );
}

/**
 * As in the app: the favorite, and a menu that moves the item to the trash. In the trash: Restore,
 * and a menu that deletes the item for good, once confirmed.
 */
function Actions({
  item: { vault, id, cipher },
  onLeft,
  onFailed,
}: {
  item: Item;
  onLeft: () => void;
  onFailed: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [saving, setSaving] = useState(false);
  const [confirmingDelete, setConfirmingDelete] = useState(false);
  const save = async (change: () => Promise<null>, leaves: boolean) => {
    setSaving(true);
    try {
      await change();
      if (leaves) onLeft();
    } catch {
      onFailed();
    } finally {
      setSaving(false);
    }
  };
  if (cipher.deletedDate) {
    return (
      <>
        <MoreMenu
          label={t({ id: "moreActions" })}
          isDisabled={saving}
          actions={[
            {
              id: "delete",
              label: t({ id: "deletePermanently" }),
              icon: deleteForever,
              danger: true,
            },
          ]}
          onAction={() => setConfirmingDelete(true)}
        />
        <ConfirmDialog
          title={t({ id: "deleteItemTitle" })}
          cancel={t({ id: "cancel" })}
          confirm={t({ id: "delete" })}
          onConfirm={() => void save(() => callCore("deleteItem", { vault, id }), true)}
          isOpen={confirmingDelete}
          onOpenChange={setConfirmingDelete}
        >
          <p>{t({ id: "deleteItemBody" })}</p>
        </ConfirmDialog>
        <OutlinedButton
          isDisabled={saving}
          onPress={() => void save(() => callCore("restoreItem", { vault, id }), true)}
        >
          <Icon src={restoreFromTrash} size={18} />
          {t({ id: "restore" })}
        </OutlinedButton>
      </>
    );
  }
  return (
    <>
      <IconButton
        icon={cipher.favorite ? star : starOutline}
        className={cipher.favorite ? "item-detail-favorite" : undefined}
        label={t({ id: cipher.favorite ? "removeFromFavorites" : "addToFavorites" })}
        isDisabled={saving}
        onPress={() =>
          void save(() => callCore("setFavorite", { vault, id, favorite: !cipher.favorite }), false)
        }
      />
      <MoreMenu
        label={t({ id: "moreActions" })}
        isDisabled={saving}
        actions={[{ id: "trash", label: t({ id: "moveToTrash" }), icon: deleteOutline }]}
        onAction={() => void save(() => callCore("trashItem", { vault, id }), true)}
      />
    </>
  );
}

function Content({ cipher, vault, onFill }: { cipher: Cipher; vault: Vault; onFill?: () => void }) {
  const intl = useIntl();
  const { formatMessage: t, formatDate } = intl;
  const fields = typeFields(cipher, intl);
  const custom = customFields(cipher, intl);
  const history = historyRows(cipher, intl);
  const notes = cipher.notes?.trim() ? cipher.notes : undefined;
  const { creationDate, revisionDate } = cipher;
  return (
    <div className="page-content">
      <PageHeader mark={<ItemIcon item={cipher} size={56} />} title={cipher.name}>
        <div className="item-detail-meta">
          <span className="item-detail-meta-part">
            <Icon src={itemTypeIcon(cipher.type)} size={16} />
            {t({ id: itemTypeLabel(cipher.type) })}
          </span>
          <span className="item-detail-meta-part">
            <VaultBadge vault={vault} />
            {vault.name}
          </span>
        </div>
      </PageHeader>
      {onFill && <FilledButton onPress={onFill}>{t({ id: "fill" })}</FilledButton>}
      {fields.length > 0 && <FieldCard rows={fields} />}
      {notes && <FieldCard rows={[{ label: t({ id: "notes" }), value: notes, kind: "text" }]} />}
      {custom.length > 0 && (
        <section className="item-detail-section">
          <h2 className="item-detail-section-title">{t({ id: "customFields" })}</h2>
          <FieldCard rows={custom} />
        </section>
      )}
      {history.length > 0 && <PasswordHistoryCard rows={history} />}
      {creationDate && revisionDate && (
        <p className="item-detail-dates">
          {t(
            { id: "itemDates" },
            {
              updated: formatDate(revisionDate, dayFormat),
              created: formatDate(creationDate, dayFormat),
            },
          )}
        </p>
      )}
    </div>
  );
}
