import settings from "@material-design-icons/svg/outlined/settings.svg";
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
import { VaultSettings } from "./VaultSettings";

const allVaults = "all";

/** The vaults of this device, one of them or all of them shown. */
export function Home({
  vaults,
  sync,
  onOpenVault,
  onVaultChanged,
}: {
  vaults: Vault[];
  sync: Sync;
  onOpenVault: () => void;
  onVaultChanged: (vault: Vault) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [selected, setSelected] = useState(allVaults);
  // Kept from a vault to another, as in the app.
  const [query, setQuery] = useState("");
  const vault = vaults.find((vault) => vault.pubkey === selected);
  const pubkeys = vault ? [vault.pubkey] : vaults.map((vault) => vault.pubkey);
  const title = vault?.name ?? t({ id: "allVaults" });
  const items = useItems(vault?.pubkey, query, sync.revision);
  const [opened, setOpened] = useState<{ vault: Vault; id: string }>();
  const [settingsOf, setSettingsOf] = useState<string>();
  const settingsVault = vaults.find((vault) => vault.pubkey === settingsOf);
  const paged = opened !== undefined || settingsVault !== undefined;
  // What the page opened from, which gets the focus back.
  const openedFrom = useRef<HTMLElement>(null);
  const vaultsButton = useRef<HTMLButtonElement>(null);
  const back = useCallback(() => {
    setOpened(undefined);
    setSettingsOf(undefined);
  }, []);
  useEffect(() => {
    if (!paged) openedFrom.current?.focus();
  }, [paged]);
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
                        selectedKeys={[selected]}
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
                                openedFrom.current = vaultsButton.current;
                                setSettingsOf(vault.pubkey);
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
            setOpened({ vault: itemVault, id: item.id });
          }}
        />
      </div>
      {opened && (
        <ItemDetail vault={opened.vault} id={opened.id} revision={sync.revision} onBack={back} />
      )}
      {settingsVault && (
        <VaultSettings vault={settingsVault} onChanged={onVaultChanged} onBack={back} />
      )}
    </main>
  );
}
