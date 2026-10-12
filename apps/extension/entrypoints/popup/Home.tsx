import casino from "@material-design-icons/svg/outlined/casino.svg";
import lockIcon from "@material-design-icons/svg/outlined/lock.svg";
import settings from "@material-design-icons/svg/outlined/settings.svg";
import add from "@material-design-icons/svg/round/add.svg";
import tune from "@material-design-icons/svg/round/tune.svg";
import { useCallback, useEffect, useRef, useState } from "react";
import {
  Button,
  Dialog,
  DialogTrigger,
  GridList,
  GridListItem,
  Heading,
  Modal,
  ModalOverlay,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { IconButton } from "@/components/Button";
import { FilterChips } from "@/components/FilterChips";
import { Icon } from "@/components/Icon";
import { itemTypeIcon, itemTypeLabel } from "@/components/ItemIcon";
import { ActionMenu } from "@/components/MoreMenu";
import { SearchField } from "@/components/SearchField";
import { SyncButton } from "@/components/SyncButton";
import { SyncStatus } from "@/components/SyncStatus";
import { AllVaultsAvatar, OpenVaultMark, VaultAvatar } from "@/components/VaultAvatar";
import type { Cipher } from "@/lib/cipher";
import type { Item, ItemFilter, Vault } from "@/lib/core";
import { fillLogin } from "@/lib/fill";
import { type ItemDraft, readItemDraft } from "@/lib/item-draft";
import { filterOptions } from "@/lib/item-filters";
import { filterKeeps, formTypes } from "@/lib/item-form";
import { forgetOpenedItem, readOpenedItem, saveOpenedItem } from "@/lib/opened-item";
import { anySyncing } from "@/lib/sync-status";
import { useItems, useItemTypes, usePageItems } from "@/lib/use-items";
import { usePage } from "@/lib/use-page";
import type { Sync } from "@/lib/use-sync";
import { GeneratorPage } from "./Generator";
import "./Home.css";
import { ItemDetail } from "./ItemDetail";
import { ItemForm } from "./ItemForm";
import { ItemList } from "./ItemList";
import { ItemMenu, type ItemMenuRequest } from "./ItemMenu";
import { Settings } from "./Settings";
import { VaultSettings } from "./VaultSettings";

const allVaults = "all";

type MessageId = FormatjsIntl.Message["ids"];

/** What shows over the list. */
type Opened =
  | { page: "item"; vault: Vault; id: string }
  /**
   * A new item of `type`, in `vault` unless another is chosen, or `item` edited, as `draft` left it
   * if the last popup closed over the form.
   */
  | { page: "form"; vault: Vault; type: number; item?: Item; draft?: ItemDraft }
  | { page: "vaultSettings"; pubkey: string }
  | { page: "generator" }
  | { page: "settings" };

/** The vaults of this device, one of them or all of them shown. */
export function Home({
  vaults,
  sync,
  hasLockPassword,
  onLock,
  onOpenVault,
  onVaultChanged,
  onVaultRemoved,
}: {
  vaults: Vault[];
  sync: Sync;
  hasLockPassword: boolean;
  onLock: () => void;
  onOpenVault: () => void;
  onVaultChanged: (vault: Vault) => void;
  onVaultRemoved: (pubkey: string) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [selected, setSelected] = useState(allVaults);
  // Kept from a vault to another, as in the app.
  const [query, setQuery] = useState("");
  const [filter, setFilter] = useState<ItemFilter>("all");
  const vault = vaults.find((vault) => vault.pubkey === selected);
  const pubkeys = vault ? [vault.pubkey] : vaults.map((vault) => vault.pubkey);
  const title = vault?.name ?? t({ id: "allVaults" });
  const items = useItems(vault?.pubkey, query, filter, sync.revision);
  const types = useItemTypes(vault?.pubkey, sync.revision);
  const searched = query.trim() !== "";
  const page = usePage();
  // Shown above all the items, not above a filter.
  const pageUrl = page === null || filter !== "all" ? null : page?.url;
  const pageItems = usePageItems(vault?.pubkey, pageUrl, sync.revision);
  // A new one at each failure, for each to show its message for a while.
  const [alert, setAlert] = useState<{ message: MessageId }>();
  useEffect(() => {
    if (!alert) return;
    const hide = setTimeout(() => setAlert(undefined), 5000);
    return () => clearTimeout(hide);
  }, [alert]);
  const fill = async ({ vault, id }: { vault: string; id: string }) => {
    if (!page) return;
    // Done, as in Bitwarden: the page shows what was filled.
    if (await fillLogin(page.tabId, vault, id)) window.close();
    else setAlert({ message: "nothingToFill" });
  };
  const fillable = (vault: string, id: string) =>
    !!pageItems?.some((item) => item.vault === vault && item.id === id);
  const [opened, setOpened] = useState<Opened>();
  const [menu, setMenu] = useState<ItemMenuRequest & { row: HTMLElement }>();
  // The form or the item the last popup showed, shown again once read.
  const [restored, setRestored] = useState(false);
  // biome-ignore lint/correctness/useExhaustiveDependencies: read once, as the list shows.
  useEffect(() => {
    void Promise.all([readItemDraft(), readOpenedItem()]).then(([draft, item]) => {
      const draftVault = vaults.find((vault) => vault.pubkey === draft?.vault);
      const itemVault = vaults.find((vault) => vault.pubkey === item?.vault);
      if (draft && draftVault) {
        const { type, item } = draft;
        setOpened({ page: "form", vault: draftVault, type, item, draft });
      } else if (item && itemVault) {
        setOpened({ page: "item", vault: itemVault, id: item.id });
      }
      setRestored(true);
    });
  }, []);
  useEffect(() => {
    if (!restored) return;
    const item =
      opened?.page === "item"
        ? { vault: opened.vault.pubkey, id: opened.id }
        : opened?.page === "form" && opened.item
          ? { vault: opened.item.vault, id: opened.item.id }
          : undefined;
    if (item) void saveOpenedItem(item);
    else void forgetOpenedItem();
  }, [opened, restored]);
  const settingsVault =
    opened?.page === "vaultSettings"
      ? vaults.find((vault) => vault.pubkey === opened.pubkey)
      : undefined;
  // Gone with its vault, once removed.
  const paged = opened !== undefined && (opened.page !== "vaultSettings" || !!settingsVault);
  // What the page opened from, which gets the focus back.
  const openedFrom = useRef<HTMLElement>(null);
  const vaultsButton = useRef<HTMLButtonElement>(null);
  const search = useRef<HTMLInputElement>(null);
  const back = useCallback(() => setOpened(undefined), []);
  // For a screen reader alone: the copy shows nothing, as in the app.
  const [copied, setCopied] = useState(false);
  useEffect(() => {
    if (!copied) return;
    const reset = setTimeout(() => setCopied(false), 1500);
    return () => clearTimeout(reset);
  }, [copied]);
  const menuDone = useCallback(() => {
    // Gone from the list once in the trash, out of it or deleted.
    if (!menu?.row.isConnected) search.current?.focus();
    else if (!paged) menu.row.focus();
    setMenu(undefined);
  }, [menu, paged]);
  useEffect(() => {
    // An item shown again from the last popup opened from nothing here.
    if (!paged) (openedFrom.current ?? search.current)?.focus();
  }, [paged]);
  /** From the drawer, gone once the page shows: the focus comes back to its button. */
  const openFromDrawer = (page: Opened) => {
    openedFrom.current = vaultsButton.current;
    setOpened(page);
  };
  const newItemButton = useRef<HTMLButtonElement>(null);
  const newItem = (type: number) => {
    const target = vault ?? vaults[0];
    if (!target) return;
    openedFrom.current = newItemButton.current;
    setOpened({ page: "form", vault: target, type });
  };
  // As in the app: a filter of a type the form creates creates one of that type at once.
  const filteredType = typeof filter === "number" && formTypes.includes(filter) ? filter : null;
  const newItemTrigger = (
    <Button
      ref={newItemButton}
      className="button new-item-button"
      aria-label={t({ id: "newItem" })}
      onPress={filteredType === null ? undefined : () => newItem(filteredType)}
    >
      <Icon src={add} size={22} />
    </Button>
  );
  /** Shows the item saved, in the list of the vault it went to, under a filter that keeps it. */
  const showSaved = (savedVault: Vault, id: string, cipher: Cipher) => {
    if (!filterKeeps(filter, cipher)) setFilter("all");
    if (vault && vault.pubkey !== savedVault.pubkey) setSelected(savedVault.pubkey);
    setOpened({ page: "item", vault: savedVault, id });
  };
  if (!restored) return null;
  return (
    <main className="home">
      {/* Kept under the page, its search and scroll included, out of reach while the page shows. */}
      <div className="home-list" inert={paged}>
        <header className="home-header">
          <DialogTrigger>
            <Button
              ref={vaultsButton}
              className="home-vaults-button"
              aria-label={t({ id: "vaults" })}
            >
              {vault ? <VaultAvatar vault={vault} size={44} /> : <AllVaultsAvatar size={44} />}
            </Button>
            <ModalOverlay className="drawer-overlay" isDismissable>
              <Modal className="drawer">
                <Dialog className="drawer-dialog">
                  {({ close }) => (
                    <>
                      <Heading slot="title" className="drawer-title">
                        {t({ id: "vaults" })}
                      </Heading>
                      <GridList
                        aria-label={t({ id: "vaults" })}
                        selectionMode="single"
                        selectionBehavior="replace"
                        disallowEmptySelection
                        selectedKeys={[vault?.pubkey ?? allVaults]}
                        onSelectionChange={(keys) => {
                          if (keys !== "all") setSelected(String([...keys][0] ?? allVaults));
                          close();
                        }}
                        className="drawer-list"
                      >
                        <GridListItem
                          id={allVaults}
                          textValue={t({ id: "allVaults" })}
                          className="drawer-row"
                        >
                          <AllVaultsAvatar size={40} />
                          <span className="drawer-row-title">{t({ id: "allVaults" })}</span>
                        </GridListItem>
                        {vaults.map((vault) => (
                          <GridListItem
                            key={vault.pubkey}
                            id={vault.pubkey}
                            textValue={vault.name}
                            className="drawer-row"
                          >
                            <VaultAvatar vault={vault} size={40} />
                            <span className="drawer-row-title">{vault.name}</span>
                            <IconButton
                              icon={settings}
                              label={t({ id: "vaultSettings" })}
                              onPress={() => {
                                close();
                                openFromDrawer({ page: "vaultSettings", pubkey: vault.pubkey });
                              }}
                            />
                          </GridListItem>
                        ))}
                      </GridList>
                      <Button
                        className="drawer-row"
                        onPress={() => {
                          close();
                          onOpenVault();
                        }}
                      >
                        <OpenVaultMark size={40} />
                        <span className="drawer-row-title">{t({ id: "openVault" })}</span>
                      </Button>
                      <Button
                        className="drawer-row"
                        onPress={() => {
                          close();
                          openFromDrawer({ page: "generator" });
                        }}
                      >
                        <span className="drawer-row-mark">
                          <Icon src={casino} />
                        </span>
                        <span className="drawer-row-title">{t({ id: "generator" })}</span>
                      </Button>
                      <Button
                        className="drawer-row"
                        onPress={() => {
                          close();
                          openFromDrawer({ page: "settings" });
                        }}
                      >
                        <span className="drawer-row-mark">
                          <Icon src={tune} />
                        </span>
                        <span className="drawer-row-title">{t({ id: "settings" })}</span>
                      </Button>
                    </>
                  )}
                </Dialog>
              </Modal>
            </ModalOverlay>
          </DialogTrigger>
          <div className="home-heading">
            <h1 className="home-title">{title}</h1>
            <SyncStatus pubkeys={pubkeys} states={sync.states} />
          </div>
          <SyncButton vault={vault?.pubkey} syncing={anySyncing(pubkeys, sync.states)} />
          {hasLockPassword && (
            <IconButton icon={lockIcon} label={t({ id: "lock" })} onPress={onLock} />
          )}
          {filteredType === null ? (
            <ActionMenu
              trigger={newItemTrigger}
              actions={formTypes.map((type) => ({
                id: String(type),
                label: t({ id: itemTypeLabel(type) }),
                icon: itemTypeIcon(type),
              }))}
              onAction={(type) => newItem(Number(type))}
            />
          ) : (
            newItemTrigger
          )}
        </header>
        <div className="home-search">
          {/* What the popup opens for: typing finds the item at once. */}
          <SearchField value={query} onChange={setQuery} autoFocus inputRef={search} />
        </div>
        {types && (
          <FilterChips
            options={filterOptions(types, filter)}
            selected={filter}
            onChange={setFilter}
          />
        )}
        <ItemList
          items={items}
          // What was searched for shows alone.
          pageItems={searched ? [] : pageItems}
          onFill={fill}
          vaults={vaults}
          // A badge tells the vaults apart, which a single vault does not need.
          showVault={!vault && vaults.length > 1}
          label={title}
          searched={searched}
          filtered={filter !== "all"}
          neverSynced={pubkeys.some(
            (pubkey) => !sync.states.find((state) => state.pubkey === pubkey)?.lastSync,
          )}
          onMenu={(item, { x, y }, row) => setMenu({ vault: item.vault, id: item.id, x, y, row })}
          onOpen={(item) => {
            const itemVault = vaults.find((vault) => vault.pubkey === item.vault);
            if (!itemVault) return;
            openedFrom.current =
              document.activeElement instanceof HTMLElement ? document.activeElement : null;
            setOpened({ page: "item", vault: itemVault, id: item.id });
          }}
        />
      </div>
      {menu && (
        <ItemMenu
          request={menu}
          onEdit={(item) => {
            const itemVault = vaults.find((vault) => vault.pubkey === item.vault);
            if (!itemVault) return;
            openedFrom.current = menu.row;
            setOpened({ page: "form", vault: itemVault, type: item.cipher.type, item });
          }}
          onCopied={() => setCopied(true)}
          onFailed={() => setAlert({ message: "itemSaveFailed" })}
          onDone={menuDone}
        />
      )}
      {opened?.page === "item" && (
        <ItemDetail
          vault={opened.vault}
          id={opened.id}
          revision={sync.revision}
          onBack={back}
          onLeft={() => {
            // Its row is gone from the list.
            openedFrom.current = null;
            back();
          }}
          onEdit={(item) =>
            setOpened({ page: "form", vault: opened.vault, type: item.cipher.type, item })
          }
          onFailed={() => setAlert({ message: "itemSaveFailed" })}
          onFill={
            fillable(opened.vault.pubkey, opened.id)
              ? () => fill({ vault: opened.vault.pubkey, id: opened.id })
              : undefined
          }
        />
      )}
      {opened?.page === "form" && (
        <ItemForm
          vaults={vaults}
          vault={opened.vault}
          type={opened.type}
          item={opened.item}
          pageUrl={page?.url}
          draft={opened.draft}
          onSaved={showSaved}
          onClose={() =>
            setOpened(
              opened.item ? { page: "item", vault: opened.vault, id: opened.item.id } : undefined,
            )
          }
        />
      )}
      {settingsVault && (
        <VaultSettings
          vault={settingsVault}
          unsent={sync.states.find((state) => state.pubkey === settingsVault.pubkey)?.unsent ?? 0}
          onChanged={onVaultChanged}
          onRemoved={onVaultRemoved}
          onBack={back}
        />
      )}
      {opened?.page === "generator" && <GeneratorPage onBack={back} />}
      {opened?.page === "settings" && <Settings hasLockPassword={hasLockPassword} onBack={back} />}
      {/* Kept in the page, empty, for a screen reader to read what it says once it does. */}
      <p role="status" className="visually-hidden home-status">
        {copied ? t({ id: "copied" }) : ""}
      </p>
      <p role="alert" className="home-alert">
        {alert ? t({ id: alert.message }) : ""}
      </p>
    </main>
  );
}
