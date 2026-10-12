import {
  Collection,
  GridList,
  GridListHeader,
  GridListItem,
  GridListSection,
  ListLayout,
  Virtualizer,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { TextButton } from "@/components/Button";
import { CopyButton } from "@/components/CopyButton";
import { ItemIcon } from "@/components/ItemIcon";
import { callCore, type ItemSummary, type Vault } from "@/lib/core";
import "./ItemList.css";

/**
 * The items, a row each with their vault's badge when `showVault`, or why there are none: what was
 * `searched` matches none, or the vaults have none. The `pageItems`, the logins for the page the
 * popup opened over, come first in a section of their own, where a row fills its login. Nothing
 * until both are read. A row opens its item, and copies the password of a login or the number of a
 * card.
 */
export function ItemList({
  items,
  pageItems,
  vaults,
  showVault,
  label,
  searched,
  neverSynced,
  onOpen,
  onFill,
}: {
  items: ItemSummary[] | undefined;
  pageItems: ItemSummary[] | undefined;
  vaults: Vault[];
  showVault: boolean;
  label: string;
  searched: boolean;
  neverSynced: boolean;
  onOpen: (item: ItemSummary) => void;
  onFill: (item: ItemSummary) => void;
}) {
  const { formatMessage: t } = useIntl();
  if (!items || !pageItems) return null;
  if (items.length === 0) {
    const why = searched ? "noSearchResults" : neverSynced ? "lookingForItems" : "noItems";
    return <p className="item-list-empty">{t({ id: why })}</p>;
  }
  // A login for the page shows in both sections.
  const byKey = new Map([
    ...items.map((item) => [keyOf(item), item] as const),
    ...pageItems.map((item) => [pageKeyOf(item), item] as const),
  ]);
  const row = (item: ItemSummary, key: string, fills = false) => (
    <GridListItem id={key} textValue={item.name} className="item-row">
      <ItemIcon
        item={item}
        vault={showVault ? vaults.find((vault) => vault.pubkey === item.vault) : undefined}
      />
      <span className="item-row-text">
        <span className="item-row-name">{item.name}</span>
        {item.subtitle && <span className="item-row-subtitle">{item.subtitle}</span>}
      </span>
      {fills && <TextButton onPress={() => onFill(item)}>{t({ id: "fill" })}</TextButton>}
      {item.copies && (
        <CopyButton
          // Read when pressed: the list holds no secret.
          value={() => copiedFrom(item)}
          sensitive
          label={t({ id: item.copies === "password" ? "copyPassword" : "copyNumber" })}
        />
      )}
    </GridListItem>
  );
  const all = <Collection items={items}>{(item) => row(item, keyOf(item))}</Collection>;
  return (
    // Bitwarden imports bring thousands of items: only the rows in sight are rendered.
    <Virtualizer
      layout={ListLayout}
      layoutOptions={{ rowSize: 64, headingSize: 36, gap: 2, padding: 8 }}
    >
      <GridList
        aria-label={label}
        onAction={(key) => {
          const item = byKey.get(String(key));
          if (item) onOpen(item);
        }}
        className="item-list"
      >
        {pageItems.length === 0 ? (
          all
        ) : (
          <>
            <GridListSection>
              <GridListHeader className="item-list-header">
                {t({ id: "forThisSite" })}
              </GridListHeader>
              <Collection items={pageItems}>
                {(item) => row(item, pageKeyOf(item), true)}
              </Collection>
            </GridListSection>
            <GridListSection>
              <GridListHeader className="item-list-header">{t({ id: "allItems" })}</GridListHeader>
              {all}
            </GridListSection>
          </>
        )}
      </GridList>
    </Virtualizer>
  );
}

/** Unique across the vaults. */
function keyOf(item: ItemSummary): string {
  return `${item.vault}:${item.id}`;
}

function pageKeyOf(item: ItemSummary): string {
  return `page:${keyOf(item)}`;
}

async function copiedFrom(item: ItemSummary): Promise<string | undefined> {
  const cipher = (await callCore("item", { vault: item.vault, id: item.id }))?.cipher;
  return (item.copies === "password" ? cipher?.login?.password : cipher?.card?.number) ?? undefined;
}
