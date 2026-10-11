import { useState } from "react";
import { useIntl } from "react-intl";
import { ColorPicker } from "@/components/ColorPicker";
import { Page, PageHeader } from "@/components/Page";
import { SettingsSection } from "@/components/SettingsSection";
import { TextField } from "@/components/TextField";
import { VaultAvatar } from "@/components/VaultAvatar";
import { callCore, type Vault } from "@/lib/core";
import "./VaultSettings.css";

/** The settings of `vault` on this device, each change saved as it is made, as in the app. */
export function VaultSettings({
  vault,
  onChanged,
  onBack,
}: {
  vault: Vault;
  onChanged: (vault: Vault) => void;
  onBack: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [name, setName] = useState(vault.name);
  const [nameError, setNameError] = useState<string>();
  const [saveError, setSaveError] = useState<string>();

  async function edit(changes: { name?: string; color?: number }) {
    setSaveError(undefined);
    try {
      onChanged(await callCore("editVault", { vault: vault.pubkey, ...changes }));
    } catch {
      setSaveError(t({ id: "vaultSaveFailed" }));
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
        </SettingsSection>
      </div>
    </Page>
  );
}
