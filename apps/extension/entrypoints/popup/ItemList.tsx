import { GridList, GridListItem, ListLayout, Virtualizer } from "react-aria-components";
import { useIntl } from "react-intl";
import { CopyButton } from "@/components/CopyButton";
import { ItemIcon } from "@/components/ItemIcon";
import { callCore, type ItemSummary, type Vault } from "@/lib/core";
import "./ItemList.css";

/**
 * The items, a row each with their vault's badge when `showVault`, or why there are none: what was
 * `searched` matches none, or the vaults have none. Nothing until read. A row opens its item, and
 * copies the password of a login or the number of a card.
 */
export function ItemList({
  items,
  vaults,
  showVault,
  label,
  searched,
  neverSynced,
  onOpen,
}: {
  items: ItemSummary[] | undefined;
  vaults: Vault[];
  showVault: boolean;
  label: string;
  searched: boolean;
  neverSynced: boolean;
  onOpen: (item: ItemSummary) => void;
}) {
  const { formatMessage: t } = useIntl();
  if (!items) return null;
  if (items.length === 0) {
    const why = searched ? "noSearchResults" : neverSynced ? "lookingForItems" : "noItems";
    return <p className="item-list-empty">{t({ id: why })}</p>;
  }
  return (
    // Bitwarden imports bring thousands of items: only the rows in sight are rendered.
    <Virtualizer layout={ListLayout} layoutOptions={{ rowSize: 64, gap: 2, padding: 8 }}>
      <GridList
        aria-label={label}
        items={items}
        onAction={(key) => {
          const item = items.find((item) => keyOf(item) === key);
          if (item) onOpen(item);
        }}
        className="item-list"
      >
        {(item) => (
          <GridListItem id={keyOf(item)} textValue={item.name} className="item-row">
            <ItemIcon
              item={item}
              vault={showVault ? vaults.find((vault) => vault.pubkey === item.vault) : undefined}
            />
            <span className="item-row-text">
              <span className="item-row-name">{item.name}</span>
              {item.subtitle && <span className="item-row-subtitle">{item.subtitle}</span>}
            </span>
            {item.copies && (
              <CopyButton
                // Read when pressed: the list holds no secret.
                value={() => copiedFrom(item)}
                sensitive
                label={t({ id: item.copies === "password" ? "copyPassword" : "copyNumber" })}
              />
            )}
          </GridListItem>
        )}
      </GridList>
    </Virtualizer>
  );
}

/** Unique across the vaults. */
function keyOf(item: ItemSummary): string {
  return `${item.vault}:${item.id}`;
}

async function copiedFrom(item: ItemSummary): Promise<string | undefined> {
  const cipher = (await callCore("item", { vault: item.vault, id: item.id }))?.cipher;
  return (item.copies === "password" ? cipher?.login?.password : cipher?.card?.number) ?? undefined;
}
