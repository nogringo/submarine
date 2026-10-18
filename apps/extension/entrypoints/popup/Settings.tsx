import { npubEncode } from "nostr-tools/nip19";
import { useEffect, useRef, useState } from "react";
import { Button, DialogTrigger } from "react-aria-components";
import { type IntlShape, useIntl } from "react-intl";
import { TextButton } from "@/components/Button";
import { type LockPasswordChange, LockPasswordDialog } from "@/components/LockPasswordDialog";
import { Page, PageHeader } from "@/components/Page";
import { SelectTile } from "@/components/SelectTile";
import { SettingsLinkTile, SettingsSection, SettingsTile } from "@/components/SettingsSection";
import { AddVaultMark, VaultAvatar } from "@/components/VaultAvatar";
import {
  type ClipboardTimeout,
  clipboardTimeouts,
  readClipboardTimeout,
  saveClipboardTimeout,
} from "@/lib/clipboard";
import { callCore, type LockTimeout, lockTimeouts, type Vault } from "@/lib/core";
import { languageNames } from "@/lib/i18n";
import { useChosenLocale } from "@/lib/use-locale";
import { ImportExportSection } from "./ImportExport";
import "./Settings.css";

/**
 * The settings of the extension on this device, as in the app. Stays under the settings of a vault
 * it opens, `covered`, and gives the focus back to that vault's row once back.
 */
export function Settings({
  hasLockPassword,
  vaults,
  covered,
  onOpenVault,
  onAddVault,
  onBack,
}: {
  hasLockPassword: boolean;
  vaults: Vault[];
  covered: boolean;
  onOpenVault: (pubkey: string) => void;
  onAddVault: () => void;
  onBack: () => void;
}) {
  const intl = useIntl();
  const { formatMessage: t } = intl;
  const vaultRows = useRef(new Map<string, HTMLButtonElement>());
  const addVaultRow = useRef<HTMLButtonElement>(null);
  const openedVault = useRef<string>(undefined);
  useEffect(() => {
    if (covered || !openedVault.current) return;
    // Gone once removed: the row in its place gets the focus.
    (vaultRows.current.get(openedVault.current) ?? addVaultRow.current)?.focus();
  }, [covered]);
  const [clipboardTimeout, setClipboardTimeout] = useState<ClipboardTimeout>();
  const [lockTimeout, setLockTimeout] = useState<LockTimeout>();
  useEffect(() => {
    void readClipboardTimeout().then(setClipboardTimeout);
    void callCore("lockTimeout", {}).then(setLockTimeout);
  }, []);
  const lockPasswordActions = useRef<HTMLDivElement>(null);
  const hadLockPassword = useRef(hasLockPassword);
  useEffect(() => {
    // The button pressed went with the password set or removed: the one in its place gets the focus.
    if (hadLockPassword.current !== hasLockPassword) {
      lockPasswordActions.current?.querySelector("button")?.focus();
    }
    hadLockPassword.current = hasLockPassword;
  }, [hasLockPassword]);
  const lockPasswordButton = (change: LockPasswordChange, label: string) => (
    <DialogTrigger>
      <TextButton>{label}</TextButton>
      <LockPasswordDialog change={change} />
    </DialogTrigger>
  );
  return (
    <Page className="settings" covered={covered} onBack={onBack}>
      <div className="page-content">
        <PageHeader title={t({ id: "settings" })} />
        <SettingsSection title={t({ id: "vaults" })}>
          {vaults.map((vault) => (
            <SettingsLinkTile
              key={vault.pubkey}
              ref={(row) => {
                if (row) vaultRows.current.set(vault.pubkey, row);
                return () => {
                  vaultRows.current.delete(vault.pubkey);
                };
              }}
              className="settings-vault"
              leading={<VaultAvatar vault={vault} size={36} />}
              title={vault.name}
              description={npubEncode(vault.pubkey)}
              onPress={() => {
                openedVault.current = vault.pubkey;
                onOpenVault(vault.pubkey);
              }}
            />
          ))}
          <Button
            ref={addVaultRow}
            className="settings-tile settings-link-tile"
            onPress={onAddVault}
          >
            <AddVaultMark size={36} />
            <span className="settings-tile-text">
              <span className="settings-tile-title">{t({ id: "addVault" })}</span>
            </span>
          </Button>
        </SettingsSection>
        <SettingsSection title={t({ id: "security" })}>
          <SettingsTile
            title={t({ id: "lockPassword" })}
            description={t({ id: "lockPasswordDescription" })}
          >
            <div ref={lockPasswordActions} className="settings-lock-password-actions">
              {hasLockPassword ? (
                <>
                  {lockPasswordButton("change", t({ id: "changeLockPassword" }))}
                  {lockPasswordButton("remove", t({ id: "removeLockPassword" }))}
                </>
              ) : (
                lockPasswordButton("set", t({ id: "setLockPassword" }))
              )}
            </div>
          </SettingsTile>
          {hasLockPassword && lockTimeout && (
            <SelectTile
              title={t({ id: "lockAfter" })}
              value={lockTimeout}
              options={lockTimeouts.map((id) => ({ id, label: lockTimeoutLabel(id, intl) }))}
              onChange={(timeout) => {
                setLockTimeout(timeout);
                void callCore("setLockTimeout", { timeout });
              }}
            />
          )}
          {clipboardTimeout && (
            <SelectTile
              title={t({ id: "clearClipboardAfter" })}
              value={clipboardTimeout}
              options={Object.keys(clipboardTimeouts).map((id) => ({
                id: id as ClipboardTimeout,
                label: clipboardTimeoutLabel(id as ClipboardTimeout, intl),
              }))}
              onChange={(timeout) => {
                setClipboardTimeout(timeout);
                void saveClipboardTimeout(timeout);
              }}
            />
          )}
        </SettingsSection>
        <SettingsSection title={t({ id: "appearance" })}>
          <LanguageTile />
        </SettingsSection>
        <ImportExportSection vaults={vaults} />
      </div>
    </Page>
  );
}

/** Stands for the browser's language, as an option's id cannot be undefined. */
const browserLanguage = "system";

/** The languages by their own names, the browser's first, as the app sorts them. */
function LanguageTile() {
  const { formatMessage: t } = useIntl();
  const { chosen, choose } = useChosenLocale();
  const [names, setNames] = useState<Map<string, string>>();
  useEffect(() => {
    void languageNames().then(setNames);
  }, []);
  if (!names) return null;
  return (
    <SelectTile
      title={t({ id: "language" })}
      value={chosen ?? browserLanguage}
      options={[
        { id: browserLanguage, label: t({ id: "languageSystem" }) },
        ...[...names]
          .map(([id, label]) => ({ id, label }))
          .toSorted((a, b) => (a.label < b.label ? -1 : 1)),
      ]}
      onChange={(locale) => choose(locale === browserLanguage ? undefined : locale)}
    />
  );
}

function lockTimeoutLabel(timeout: LockTimeout, { formatMessage: t }: IntlShape) {
  switch (timeout) {
    case "immediately":
      return t({ id: "lockImmediately" });
    case "oneMinute":
      return t({ id: "minutes" }, { count: 1 });
    case "fiveMinutes":
      return t({ id: "minutes" }, { count: 5 });
    case "fifteenMinutes":
      return t({ id: "minutes" }, { count: 15 });
    case "thirtyMinutes":
      return t({ id: "minutes" }, { count: 30 });
    case "oneHour":
      return t({ id: "hours" }, { count: 1 });
    case "fourHours":
      return t({ id: "hours" }, { count: 4 });
    case "onRestart":
      return t({ id: "lockOnBrowserRestart" });
  }
}

function clipboardTimeoutLabel(timeout: ClipboardTimeout, { formatMessage: t }: IntlShape) {
  const delay = clipboardTimeouts[timeout];
  if (delay === null) return t({ id: "never" });
  if (delay >= 60_000) return t({ id: "minutes" }, { count: delay / 60_000 });
  return t({ id: "seconds" }, { count: delay / 1000 });
}
