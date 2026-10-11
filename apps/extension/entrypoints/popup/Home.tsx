import { useState } from "react";
import {
  Button,
  Dialog,
  DialogTrigger,
  Heading,
  ListBox,
  ListBoxItem,
  Modal,
  ModalOverlay,
} from "react-aria-components";
import { useIntl } from "react-intl";
import { SearchField } from "@/components/SearchField";
import { SyncStatus } from "@/components/SyncStatus";
import { AllVaultsAvatar, OpenVaultMark, VaultAvatar } from "@/components/VaultAvatar";
import type { Vault } from "@/lib/core";
import { useItems } from "@/lib/use-items";
import type { Sync } from "@/lib/use-sync";
import "./Home.css";
import { ItemList } from "./ItemList";

const allVaults = "all";

/** The vaults of this device, one of them or all of them shown. */
export function Home({
  vaults,
  sync,
  onOpenVault,
}: {
  vaults: Vault[];
  sync: Sync;
  onOpenVault: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [selected, setSelected] = useState(allVaults);
  // Kept from a vault to another, as in the app.
  const [query, setQuery] = useState("");
  const vault = vaults.find((vault) => vault.pubkey === selected);
  const pubkeys = vault ? [vault.pubkey] : vaults.map((vault) => vault.pubkey);
  const title = vault?.name ?? t({ id: "allVaults" });
  const items = useItems(vault?.pubkey, query, sync.revision);
  return (
    <main className="home">
      <header className="home-header">
        <DialogTrigger>
          <Button className="home-vaults-button" aria-label={t({ id: "vaults" })}>
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
                    <ListBox
                      aria-label={t({ id: "vaults" })}
                      selectionMode="single"
                      disallowEmptySelection
                      selectedKeys={[selected]}
                      onSelectionChange={(keys) => {
                        if (keys !== "all") setSelected(String([...keys][0] ?? allVaults));
                        close();
                      }}
                      className="drawer-list"
                    >
                      <ListBoxItem
                        id={allVaults}
                        textValue={t({ id: "allVaults" })}
                        className="drawer-row"
                      >
                        <AllVaultsAvatar size={40} />
                        <span className="drawer-row-title">{t({ id: "allVaults" })}</span>
                      </ListBoxItem>
                      {vaults.map((vault) => (
                        <ListBoxItem
                          key={vault.pubkey}
                          id={vault.pubkey}
                          textValue={vault.name}
                          className="drawer-row"
                        >
                          <VaultAvatar vault={vault} size={40} />
                          <span className="drawer-row-title">{vault.name}</span>
                        </ListBoxItem>
                      ))}
                    </ListBox>
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
      />
    </main>
  );
}
