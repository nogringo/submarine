import settings from "@material-design-icons/svg/outlined/settings.svg";
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
import { Icon } from "@/components/Icon";
import { SearchField } from "@/components/SearchField";
import { SyncButton } from "@/components/SyncButton";
import { SyncStatus } from "@/components/SyncStatus";
import { AllVaultsAvatar, OpenVaultMark, VaultAvatar } from "@/components/VaultAvatar";
import type { Vault } from "@/lib/core";
import { anySyncing } from "@/lib/sync-status";
import { useItems } from "@/lib/use-items";
import type { Sync } from "@/lib/use-sync";
import "./Home.css";
import { ItemDetail } from "./ItemDetail";
import { ItemList } from "./ItemList";
import { Settings } from "./Settings";
import { VaultSettings } from "./VaultSettings";

const allVaults = "all";

/** What shows over the list. */
type Opened =
  | { page: "item"; vault: Vault; id: string }
  | { page: "vaultSettings"; pubkey: string }
  | { page: "settings" };

/** The vaults of this device, one of them or all of them shown. */
export function Home({
  vaults,
  sync,
  onOpenVault,
  onVaultChanged,
  onVaultRemoved,
}: {
  vaults: Vault[];
  sync: Sync;
  onOpenVault: () => void;
  onVaultChanged: (vault: Vault) => void;
  onVaultRemoved: (pubkey: string) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [selected, setSelected] = useState(allVaults);
  // Kept from a vault to another, as in the app.
  const [query, setQuery] = useState("");
  const vault = vaults.find((vault) => vault.pubkey === selected);
  const pubkeys = vault ? [vault.pubkey] : vaults.map((vault) => vault.pubkey);
  const title = vault?.name ?? t({ id: "allVaults" });
  const items = useItems(vault?.pubkey, query, sync.revision);
  const [opened, setOpened] = useState<Opened>();
  const settingsVault =
    opened?.page === "vaultSettings"
      ? vaults.find((vault) => vault.pubkey === opened.pubkey)
      : undefined;
  // Gone with its vault, once removed.
  const paged = opened !== undefined && (opened.page !== "vaultSettings" || !!settingsVault);
  // What the page opened from, which gets the focus back.
  const openedFrom = useRef<HTMLElement>(null);
  const vaultsButton = useRef<HTMLButtonElement>(null);
  const back = useCallback(() => setOpened(undefined), []);
  useEffect(() => {
    if (!paged) openedFrom.current?.focus();
  }, [paged]);
  /** From the drawer, gone once the page shows: the focus comes back to its button. */
  const openFromDrawer = (page: Opened) => {
    openedFrom.current = vaultsButton.current;
    setOpened(page);
  };
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
        </header>
        <div className="home-search">
          {/* What the popup opens for: typing finds the item at once. */}
          <SearchField value={query} onChange={setQuery} autoFocus />
        </div>
        <ItemList
          items={items}
          vaults={vaults}
          // A badge tells the vaults apart, which a single vault does not need.
          showVault={!vault && vaults.length > 1}
          label={title}
          searched={query.trim() !== ""}
          neverSynced={pubkeys.some(
            (pubkey) => !sync.states.find((state) => state.pubkey === pubkey)?.lastSync,
          )}
          onOpen={(item) => {
            const itemVault = vaults.find((vault) => vault.pubkey === item.vault);
            if (!itemVault) return;
            openedFrom.current =
              document.activeElement instanceof HTMLElement ? document.activeElement : null;
            setOpened({ page: "item", vault: itemVault, id: item.id });
          }}
        />
      </div>
      {opened?.page === "item" && (
        <ItemDetail vault={opened.vault} id={opened.id} revision={sync.revision} onBack={back} />
      )}
      {settingsVault && (
        <VaultSettings
          vault={settingsVault}
          onChanged={onVaultChanged}
          onRemoved={onVaultRemoved}
          onBack={back}
        />
      )}
      {opened?.page === "settings" && <Settings onBack={back} />}
    </main>
  );
}
