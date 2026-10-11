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
import { AllVaultsAvatar, OpenVaultMark, VaultAvatar } from "@/components/VaultAvatar";
import type { Vault } from "@/lib/core";
import "./Home.css";

const allVaults = "all";

/** The vaults of this device, one of them or all of them shown. */
export function Home({ vaults, onOpenVault }: { vaults: Vault[]; onOpenVault: () => void }) {
  const { formatMessage: t } = useIntl();
  const [selected, setSelected] = useState(allVaults);
  const vault = vaults.find((vault) => vault.pubkey === selected);
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
        <h1 className="home-title">{vault?.name ?? t({ id: "allVaults" })}</h1>
      </header>
    </main>
  );
}
