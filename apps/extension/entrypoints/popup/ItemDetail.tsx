import arrowBack from "@material-design-icons/svg/round/arrow_back.svg";
import { useEffect, useRef } from "react";
import { useIntl } from "react-intl";
import { IconButton } from "@/components/Button";
import { FieldCard } from "@/components/FieldCard";
import { Icon } from "@/components/Icon";
import { ItemIcon, itemTypeIcon, itemTypeLabel } from "@/components/ItemIcon";
import { PasswordHistoryCard } from "@/components/PasswordHistoryCard";
import { VaultBadge } from "@/components/VaultAvatar";
import type { Cipher } from "@/lib/cipher";
import type { Vault } from "@/lib/core";
import { dayFormat } from "@/lib/i18n";
import { customFields, historyRows, typeFields } from "@/lib/item-fields";
import { useItem } from "@/lib/use-item";
import "./ItemDetail.css";

/** An item over the list, read again at each `revision`, until `onBack` or Escape. */
export function ItemDetail({
  vault,
  id,
  revision,
  onBack,
}: {
  vault: Vault;
  id: string;
  revision: number;
  onBack: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const item = useItem(vault.pubkey, id, revision);
  const back = useRef<HTMLButtonElement>(null);
  useEffect(() => {
    const goBack = (event: KeyboardEvent) => {
      if (event.key !== "Escape" || event.defaultPrevented) return;
      // Rather than the browser closing the popup.
      event.preventDefault();
      onBack();
    };
    document.addEventListener("keydown", goBack);
    return () => document.removeEventListener("keydown", goBack);
  }, [onBack]);
  useEffect(() => {
    if (item === null) back.current?.focus();
  }, [item]);
  return (
    <section className="item-detail">
      <div className="item-detail-bar">
        <IconButton ref={back} icon={arrowBack} label={t({ id: "back" })} onPress={onBack} />
      </div>
      {item === null ? (
        <p className="item-detail-missing">{t({ id: "itemNotFound" })}</p>
      ) : (
        item && <Content cipher={item.cipher} vault={vault} />
      )}
    </section>
  );
}

function Content({ cipher, vault }: { cipher: Cipher; vault: Vault }) {
  const intl = useIntl();
  const { formatMessage: t, formatDate } = intl;
  const heading = useRef<HTMLHeadingElement>(null);
  useEffect(() => {
    // A screen reader reads the item's name, the first thing the item shows.
    heading.current?.focus();
  }, []);
  const fields = typeFields(cipher, intl);
  const custom = customFields(cipher, intl);
  const history = historyRows(cipher, intl);
  const notes = cipher.notes?.trim() ? cipher.notes : undefined;
  const { creationDate, revisionDate } = cipher;
  return (
    <div className="item-detail-content">
      <header className="item-detail-header">
        <ItemIcon item={cipher} size={56} />
        <div className="item-detail-heading">
          <h1 ref={heading} tabIndex={-1} className="item-detail-name">
            {cipher.name}
          </h1>
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
        </div>
      </header>
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
