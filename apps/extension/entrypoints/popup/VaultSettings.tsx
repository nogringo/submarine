import lock from "@material-design-icons/svg/outlined/lock.svg";
import { npubEncode } from "nostr-tools/nip19";
import { useState } from "react";
import { DialogTrigger } from "react-aria-components";
import { useIntl } from "react-intl";
import { OutlinedButton } from "@/components/Button";
import { ColorPicker } from "@/components/ColorPicker";
import { CopyButton } from "@/components/CopyButton";
import { ConfirmDialog } from "@/components/Dialog";
import { EncryptVaultKeyDialog } from "@/components/EncryptVaultKeyDialog";
import { Icon } from "@/components/Icon";
import { Page, PageHeader } from "@/components/Page";
import { SettingsSection, SettingsTile } from "@/components/SettingsSection";
import { TextField } from "@/components/TextField";
import { VaultAvatar } from "@/components/VaultAvatar";
import { VaultKeyBox } from "@/components/VaultKeyBox";
import { callCore, type Vault } from "@/lib/core";
import "./VaultSettings.css";

/**
 * The settings of `vault` on this device, each change saved as it is made, and its key, as in the
 * app. Removing it warns of its `unsent` changes, which go with it.
 */
export function VaultSettings({
  vault,
  unsent,
  onChanged,
  onRemoved,
  onBack,
}: {
  vault: Vault;
  unsent: number;
  onChanged: (vault: Vault) => void;
  onRemoved: (pubkey: string) => void;
  onBack: () => void;
}) {
  const { formatMessage: t } = useIntl();
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
    <Page className="vault-settings" onBack={onBack}>
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
