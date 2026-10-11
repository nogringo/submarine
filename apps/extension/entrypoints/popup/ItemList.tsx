import { GridList, GridListItem, ListLayout, Virtualizer } from "react-aria-components";
import { useIntl } from "react-intl";
import { ItemIcon } from "@/components/ItemIcon";
import type { ItemSummary, Vault } from "@/lib/core";
import "./ItemList.css";

/**
 * The items, a row each with their vault's badge when `showVault`, or why there are none: what was
 * `searched` matches none, or the vaults have none. Nothing until read.
 */
export function ItemList({
  items,
  vaults,
  showVault,
  label,
  searched,
  neverSynced,
}: {
  items: ItemSummary[] | undefined;
  vaults: Vault[];
  showVault: boolean;
  label: string;
  searched: boolean;
  neverSynced: boolean;
}) {
  const { formatMessage: t } = useIntl();
  if (!items) return null;
  if (items.length === 0) {
    const why = searched ? "noSearchResults" : neverSynced ? "lookingForItems" : "noItems";
    return <p className="item-list-empty">{t({ id: why })}</p>;
  }
  return (
    // Bitwarden imports bring thousands of items: only the rows in sight are rendered.
    <Virtualizer layout={ListLayout} layoutOptions={{ rowSize: 56, gap: 2, padding: 8 }}>
      <GridList aria-label={label} items={items} className="item-list">
        {(item) => (
          <GridListItem id={`${item.vault}:${item.id}`} textValue={item.name} className="item-row">
            <ItemIcon
              item={item}
              vault={showVault ? vaults.find((vault) => vault.pubkey === item.vault) : undefined}
            />
            <span className="item-row-text">
              <span className="item-row-name">{item.name}</span>
              {item.subtitle && <span className="item-row-subtitle">{item.subtitle}</span>}
            </span>
          </GridListItem>
        )}
      </GridList>
    </Virtualizer>
  );
}
