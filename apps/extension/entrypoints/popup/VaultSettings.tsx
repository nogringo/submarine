import lock from "@material-design-icons/svg/outlined/lock.svg";
import { npubEncode } from "nostr-tools/nip19";
import { useEffect, useRef, useState } from "react";
import { DialogTrigger } from "react-aria-components";
import { useIntl } from "react-intl";
import { OutlinedButton } from "@/components/Button";
import { ColorPicker } from "@/components/ColorPicker";
import { CopyButton } from "@/components/CopyButton";
import { ConfirmDialog } from "@/components/Dialog";
import { EncryptVaultKeyDialog } from "@/components/EncryptVaultKeyDialog";
import { Icon } from "@/components/Icon";
import { Page, PageHeader } from "@/components/Page";
import { SettingsLinkTile, SettingsSection, SettingsTile } from "@/components/SettingsSection";
import { SyncArrows, SyncButton } from "@/components/SyncButton";
import { useSyncStatus } from "@/components/SyncStatus";
import { TextField } from "@/components/TextField";
import { VaultAvatar } from "@/components/VaultAvatar";
import { VaultKeyBox } from "@/components/VaultKeyBox";
import { callCore, type SyncState, type Vault, type VaultListName } from "@/lib/core";
import type { Sync } from "@/lib/use-sync";
import { useVaultLists } from "@/lib/use-vault-lists";
import "./VaultSettings.css";

/**
 * The settings of `vault` on this device, each change saved as it is made, its key and its sync, as
 * in the app. Removing it warns of its changes not sent, which go with it. Stays under the list it
 * opens, `covered`, and gives the focus back to the row of that list once back.
 */
export function VaultSettings({
  vault,
  sync,
  covered,
  onChanged,
  onRemoved,
  onOpenList,
  onBack,
}: {
  vault: Vault;
  sync: Sync;
  covered: boolean;
  onChanged: (vault: Vault) => void;
  onRemoved: (pubkey: string) => void;
  onOpenList: (list: VaultListName) => void;
  onBack: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const state = sync.states.find((state) => state.pubkey === vault.pubkey);
  const unsent = state?.unsent ?? 0;
  const lists = useVaultLists(vault.pubkey, sync.revision);
  const relaysRow = useRef<HTMLButtonElement>(null);
  const serversRow = useRef<HTMLButtonElement>(null);
  const openedList = useRef<VaultListName>(undefined);
  useEffect(() => {
    if (covered || !openedList.current) return;
    (openedList.current === "relays" ? relaysRow : serversRow).current?.focus();
  }, [covered]);
  const openList = (list: VaultListName) => {
    openedList.current = list;
    onOpenList(list);
  };
  const [name, setName] = useState(vault.name);
  const [nameError, setNameError] = useState<string>();
  const [saveError, setSaveError] = useState<string>();
  const [removing, setRemoving] = useState(false);
  const [removeError, setRemoveError] = useState<string>();
  const npub = npubEncode(vault.pubkey);

  async function edit(changes: { name?: string; color?: number }) {
    setSaveError(undefined);
    try {
      onChanged(await callCore("editVault", { vault: vault.pubkey, ...changes }));
    } catch {
      setSaveError(t({ id: "vaultSaveFailed" }));
    }
  }

  async function remove() {
    setRemoving(true);
    setRemoveError(undefined);
    try {
      await callCore("removeVault", { vault: vault.pubkey });
      onRemoved(vault.pubkey);
    } catch {
      setRemoveError(t({ id: "removeVaultFailed" }));
      setRemoving(false);
    }
  }

  function rename(text: string) {
    setName(text);
    const trimmed = text.trim();
    setNameError(trimmed ? undefined : t({ id: "vaultNameRequired" }));
    if (trimmed) void edit({ name: trimmed });
  }

  return (
    <Page className="vault-settings" covered={covered} onBack={onBack}>
      <div className="page-content">
        <PageHeader mark={<VaultAvatar vault={vault} size={56} />} title={vault.name}>
          <p className="vault-settings-subtitle">{t({ id: "vaultSettings" })}</p>
        </PageHeader>
        <SettingsSection
          title={t({ id: "vaultNameAndColor" })}
          description={t({ id: "vaultNameHelper" })}
        >
          <div className="settings-fields">
            <TextField
              name="name"
              label={t({ id: "vaultName" })}
              error={nameError}
              value={name}
              onChange={rename}
            />
            <ColorPicker
              label={t({ id: "vaultColor" })}
              value={vault.color}
              onChange={(color) => void edit({ color })}
            />
            {saveError && (
              <p className="vault-settings-error" role="alert">
                {saveError}
              </p>
            )}
          </div>
        </SettingsSection>
        <SettingsSection title={t({ id: "vaultKey" })}>
          <SettingsTile
            title={t({ id: "vaultPublicKey" })}
            below={<span className="vault-settings-npub">{npub}</span>}
          >
            <CopyButton value={npub} sensitive={false} />
          </SettingsTile>
          <SettingsTile
            title={t({ id: "vaultKey" })}
            description={t({ id: "vaultKeyDescription" })}
            below={<VaultKeyBox vault={vault.pubkey} />}
          />
          <SettingsTile
            title={t({ id: "encryptedVaultKey" })}
            description={t({ id: "encryptedVaultKeyDescription" })}
          >
            <DialogTrigger>
              <OutlinedButton>
                <Icon src={lock} size={18} />
                {t({ id: "exportButton" })}
              </OutlinedButton>
              <EncryptVaultKeyDialog vault={vault.pubkey} />
            </DialogTrigger>
          </SettingsTile>
        </SettingsSection>
        <SettingsSection title={t({ id: "sync" })}>
          <SyncTile vault={vault.pubkey} states={sync.states} />
          <FullSyncTile vault={vault.pubkey} state={state} />
          <SettingsLinkTile
            ref={relaysRow}
            title={t({ id: "relays" })}
            description={
              lists &&
              t(
                { id: "relaysConnected" },
                {
                  connected: lists.relays.filter((relay) => relay.connected).length,
                  count: lists.relays.length,
                },
              )
            }
            onPress={() => openList("relays")}
          />
          <SettingsLinkTile
            ref={serversRow}
            title={t({ id: "fileServers" })}
            description={lists && t({ id: "fileServerCount" }, { count: lists.servers.length })}
            onPress={() => openList("servers")}
          />
        </SettingsSection>
        <SettingsSection>
          <SettingsTile
            title={t({ id: "removeVault" })}
            description={t({ id: "removeVaultDescription" })}
            error={removeError}
          >
            <DialogTrigger>
              <OutlinedButton danger isPending={removing}>
                {t({ id: "removeVaultConfirm" })}
              </OutlinedButton>
              <ConfirmDialog
                title={t({ id: "removeVaultTitle" }, { name: vault.name })}
                cancel={t({ id: "cancel" })}
                confirm={t({ id: "removeVaultConfirm" })}
                onConfirm={() => void remove()}
              >
                <p>{t({ id: "removeVaultBody" })}</p>
                <p>{t({ id: "removeVaultKeyWarning" })}</p>
                {unsent > 0 && (
                  <p className="vault-settings-error">
                    {t({ id: "removeVaultUnsent" }, { count: unsent })}
                  </p>
                )}
              </ConfirmDialog>
            </DialogTrigger>
          </SettingsTile>
        </SettingsSection>
      </div>
    </Page>
  );
}

/** Where the sync of `vault` stands, and its button syncing it at once. */
function SyncTile({ vault, states }: { vault: string; states: SyncState[] }) {
  const { formatMessage: t } = useIntl();
  const { text } = useSyncStatus([vault], states);
  const state = states.find((state) => state.pubkey === vault);
  const allSent = !!state?.lastSync && state.unsent === 0 && state.phase !== "failed";
  return (
    <SettingsTile title={text} description={allSent ? t({ id: "syncAllSent" }) : undefined}>
      <SyncButton vault={vault} syncing={state?.phase === "syncing"} labelled />
    </SettingsTile>
  );
}

/** Its result shows here, and the reason of each relay left out in its row of the relays. */
function FullSyncTile({ vault, state }: { vault: string; state: SyncState | undefined }) {
  const { formatMessage: t } = useIntl();
  const [failed, setFailed] = useState(false);
  const reconciling = !!state?.reconciling;
  const leftOut = state?.leftOut;
  const leftOutCount = leftOut ? Object.keys(leftOut).length : 0;
  const result = reconciling
    ? undefined
    : failed
      ? { text: t({ id: "fullSyncFailed" }), wrong: true }
      : !leftOut
        ? undefined
        : leftOutCount === 0
          ? { text: t({ id: "fullSyncDone" }), wrong: false }
          : { text: t({ id: "fullSyncLeftOut" }, { count: leftOutCount }), wrong: true };
  async function reconcile() {
    setFailed(false);
    try {
      await callCore("reconcileVault", { vault });
    } catch {
      setFailed(true);
    }
  }
  return (
    <SettingsTile
      title={t({ id: "fullSync" })}
      description={t({ id: "fullSyncDescription" })}
      below={
        result && (
          <span
            className={
              result.wrong ? "settings-tile-description error" : "settings-tile-description"
            }
            role={result.wrong ? "alert" : "status"}
          >
            {result.text}
          </span>
        )
      }
    >
      <OutlinedButton isPending={reconciling} onPress={() => void reconcile()}>
        <SyncArrows turning={reconciling} size={18} />
        {t({ id: "fullSyncStart" })}
      </OutlinedButton>
    </SettingsTile>
  );
}
