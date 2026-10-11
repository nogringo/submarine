import { useEffect, useRef } from "react";
import { useIntl } from "react-intl";
import { FieldCard } from "@/components/FieldCard";
import { Icon } from "@/components/Icon";
import { ItemIcon, itemTypeIcon, itemTypeLabel } from "@/components/ItemIcon";
import { Page, PageHeader } from "@/components/Page";
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
    if (item === null) back.current?.focus();
  }, [item]);
  return (
    <Page className="item-detail" onBack={onBack} backRef={back}>
      {item === null ? (
        <p className="item-detail-missing">{t({ id: "itemNotFound" })}</p>
      ) : (
        item && <Content cipher={item.cipher} vault={vault} />
      )}
    </Page>
  );
}

function Content({ cipher, vault }: { cipher: Cipher; vault: Vault }) {
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
