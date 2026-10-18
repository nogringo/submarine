import { type FormEvent, useEffect, useRef, useState } from "react";
import { Dialog, Form, Heading, Modal, ModalOverlay, ProgressBar } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, OutlinedButton, TextButton } from "@/components/Button";
import { PageHeader } from "@/components/Page";
import { SelectField } from "@/components/SelectField";
import { SettingsSection, SettingsTile } from "@/components/SettingsSection";
import { TextField } from "@/components/TextField";
import { SwitchTile } from "@/components/ToggleTile";
import type { Cipher } from "@/lib/cipher";
import { CoreError, callCore, type Vault } from "@/lib/core";
import {
  exportFileName,
  type FileAction,
  importCiphers,
  inPopup,
  openInTab,
  saveFile,
} from "@/lib/import-export";
import "@/components/Dialog.css";
import "./ImportExport.css";

/**
 * Imports a Bitwarden JSON export into a vault, and exports a vault the same way, as the app does.
 * From the popup, in a tab, which the file dialogs do not close.
 */
export function ImportExportSection({ vaults }: { vaults: Vault[] }) {
  const { formatMessage: t } = useIntl();
  return (
    <SettingsSection title={t({ id: "importExport" })}>
      <ImportTile vaults={vaults} />
      <ExportTile vaults={vaults} />
    </SettingsSection>
  );
}

/** The import and the export alone, in the tab the popup opened for `action`, which starts at once. */
export function ImportExportPage({ vaults, action }: { vaults: Vault[]; action: FileAction }) {
  const { formatMessage: t } = useIntl();
  return (
    <main className="import-export-page">
      <div className="page-content">
        <PageHeader title={t({ id: "importExport" })}>
          <p className="import-export-muted">{t({ id: "importExportInTab" })}</p>
        </PageHeader>
        <SettingsSection>
          <ImportTile vaults={vaults} focused={action === "import"} />
          <ExportTile vaults={vaults} startOpen={action === "export"} />
        </SettingsSection>
      </div>
    </main>
  );
}

interface ExportFile {
  name: string;
  ciphers: Cipher[];
}

function ImportTile({ vaults, focused }: { vaults: Vault[]; focused?: boolean }) {
  const { formatMessage: t } = useIntl();
  const input = useRef<HTMLInputElement>(null);
  const button = useRef<HTMLButtonElement>(null);
  useEffect(() => {
    // After the page's title, which takes the focus as it shows, unlike autoFocus.
    if (focused) button.current?.focus();
  }, [focused]);
  const [error, setError] = useState<string>();
  const [locked, setLocked] = useState<{ name: string; source: string }>();
  const [found, setFound] = useState<ExportFile>();

  function choose() {
    if (inPopup()) return void openInTab("import");
    setError(undefined);
    input.current?.click();
  }

  function show(file: ExportFile) {
    if (file.ciphers.length === 0) setError(t({ id: "importEmpty" }));
    else setFound(file);
  }

  async function read(file: File) {
    let source: string;
    try {
      source = await file.text();
    } catch {
      return setError(t({ id: "importReadFailed" }));
    }
    try {
      show({ name: file.name, ciphers: await callCore("openExport", { source }) });
    } catch (error) {
      if (codeOf(error) === "passwordProtectedExport") setLocked({ name: file.name, source });
      else
        setError(
          t({ id: codeOf(error) === "encryptedExport" ? "importEncrypted" : "importNotBitwarden" }),
        );
    }
  }

  return (
    <SettingsTile
      title={t({ id: "importFromBitwarden" })}
      description={t({ id: "importFromBitwardenDescription" })}
      error={error}
    >
      <input
        ref={input}
        type="file"
        accept=".json,application/json"
        hidden
        onChange={(event) => {
          const file = event.currentTarget.files?.[0];
          // For the same file to be chosen again.
          event.currentTarget.value = "";
          if (file) void read(file);
        }}
      />
      <OutlinedButton ref={button} onPress={choose}>
        {t({ id: "importButton" })}
      </OutlinedButton>
      {locked && (
        <FilePasswordDialog
          source={locked.source}
          onOpened={(ciphers) => {
            setLocked(undefined);
            show({ name: locked.name, ciphers });
          }}
          onCancel={() => setLocked(undefined)}
        />
      )}
      {found && <ImportDialog vaults={vaults} file={found} onClose={() => setFound(undefined)} />}
    </SettingsTile>
  );
}

function codeOf(error: unknown): string | undefined {
  return error instanceof CoreError ? error.code : undefined;
}

/** Asks for the password of a password protected export, until it opens the export. */
function FilePasswordDialog({
  source,
  onOpened,
  onCancel,
}: {
  source: string;
  onOpened: (ciphers: Cipher[]) => void;
  onCancel: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [password, setPassword] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string>();

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy || !password) return;
    setBusy(true);
    setError(undefined);
    try {
      onOpened(await callCore("openExport", { source, password }));
    } catch (error) {
      setError(
        t({
          id: codeOf(error) === "wrongExportPassword" ? "wrongFilePassword" : "importNotBitwarden",
        }),
      );
      setBusy(false);
    }
  }

  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable={!busy}
      isKeyboardDismissDisabled={busy}
      isOpen
      onOpenChange={(isOpen) => isOpen || onCancel()}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Form onSubmit={(event) => void submit(event)} validationBehavior="aria">
            <Heading slot="title" className="dialog-title">
              {t({ id: "importFromBitwarden" })}
            </Heading>
            <p className="dialog-content">{t({ id: "importPasswordBody" })}</p>
            <div className="dialog-fields">
              <TextField
                name="password"
                label={t({ id: "filePassword" })}
                error={error}
                value={password}
                onChange={setPassword}
                secret
                autoFocus
              />
            </div>
            <div className="dialog-actions">
              <TextButton slot="close" isDisabled={busy}>
                {t({ id: "cancel" })}
              </TextButton>
              <FilledButton type="submit" isPending={busy} isDisabled={!password}>
                {t({ id: "open" })}
              </FilledButton>
            </div>
          </Form>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/** Asks for the vault, then imports into it, the progress in view. Stays open until it ends. */
function ImportDialog({
  vaults,
  file,
  onClose,
}: {
  vaults: Vault[];
  file: ExportFile;
  onClose: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [vault, setVault] = useState(vaults[0]);
  /** Undefined until the import starts. */
  const [saved, setSaved] = useState<number>();
  const [finished, setFinished] = useState(false);
  const [failed, setFailed] = useState(false);
  const importing = saved !== undefined && !finished;
  const total = file.ciphers.length;
  useEffect(() => {
    if (!importing) return;
    // Rather than the page going back, the tab closed with it.
    const hold = (event: KeyboardEvent) => {
      if (event.key === "Escape") event.preventDefault();
    };
    document.addEventListener("keydown", hold, true);
    return () => document.removeEventListener("keydown", hold, true);
  }, [importing]);
  if (!vault) return null;

  async function start(into: Vault) {
    setSaved(0);
    try {
      await importCiphers(into.pubkey, file.ciphers, setSaved);
    } catch {
      setFailed(true);
    }
    setFinished(true);
  }

  return (
    <ModalOverlay
      className="dialog-overlay"
      isKeyboardDismissDisabled={importing}
      isOpen
      onOpenChange={(isOpen) => isOpen || onClose()}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Heading slot="title" className="dialog-title">
            {t({ id: "importFromBitwarden" })}
          </Heading>
          {saved === undefined ? (
            <>
              <p className="dialog-content">
                {t({ id: "importFound" }, { count: total, file: file.name })}
              </p>
              {vaults.length > 1 && (
                <div className="dialog-fields">
                  <SelectField
                    label={t({ id: "vault" })}
                    value={vault.pubkey}
                    options={vaults.map(({ pubkey, name }) => ({ id: pubkey, label: name }))}
                    onChange={(pubkey) =>
                      setVault(vaults.find((each) => each.pubkey === pubkey) ?? vault)
                    }
                  />
                </div>
              )}
            </>
          ) : !finished ? (
            <ProgressBar
              className="import-progress"
              value={saved}
              maxValue={total}
              valueLabel={t({ id: "importProgress" }, { done: saved, total })}
              aria-label={t({ id: "importFromBitwarden" })}
            >
              {({ percentage, valueText }) => (
                <>
                  <div className="import-progress-track">
                    <div className="import-progress-fill" style={{ width: `${percentage}%` }} />
                  </div>
                  <span className="import-progress-text">{valueText}</span>
                </>
              )}
            </ProgressBar>
          ) : failed ? (
            <p className="dialog-content import-export-error" role="alert">
              {t({ id: "importFailed" }, { done: saved, total })}
            </p>
          ) : (
            <p className="dialog-content import-done">
              {t({ id: "importDone" }, { count: total, vault: vault.name })}
            </p>
          )}
          <div className="dialog-actions">
            {saved === undefined ? (
              <>
                <TextButton slot="close">{t({ id: "cancel" })}</TextButton>
                <FilledButton autoFocus onPress={() => void start(vault)}>
                  {t({ id: "importButton" })}
                </FilledButton>
              </>
            ) : (
              <FilledButton slot="close" isDisabled={!finished}>
                {t({ id: "done" })}
              </FilledButton>
            )}
          </div>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

function ExportTile({ vaults, startOpen = false }: { vaults: Vault[]; startOpen?: boolean }) {
  const { formatMessage: t } = useIntl();
  const [open, setOpen] = useState(startOpen);
  return (
    <SettingsTile
      title={t({ id: "exportVault" })}
      description={t({ id: "exportVaultDescription" })}
    >
      <OutlinedButton onPress={() => (inPopup() ? void openInTab("export") : setOpen(true))}>
        {t({ id: "exportButton" })}
      </OutlinedButton>
      {open && <ExportDialog vaults={vaults} onClose={() => setOpen(false)} />}
    </SettingsTile>
  );
}

interface ExportErrors {
  password?: string;
  confirmation?: string;
}

/** Asks for the vault and for a password to protect the file with, then downloads the file. */
function ExportDialog({ vaults, onClose }: { vaults: Vault[]; onClose: () => void }) {
  const { formatMessage: t } = useIntl();
  const [vault, setVault] = useState(vaults[0]);
  const [count, setCount] = useState<number>();
  const [isProtected, setProtected] = useState(true);
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [shown, setShown] = useState(false);
  const [errors, setErrors] = useState<ExportErrors>({});
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);
  const pubkey = vault?.pubkey;
  useEffect(() => {
    if (!pubkey) return;
    setCount(undefined);
    void callCore("items", { vault: pubkey }).then((items) => setCount(items.length));
  }, [pubkey]);
  if (!vault) return null;

  async function submit(event: FormEvent, from: Vault) {
    event.preventDefault();
    if (busy) return;
    const missing = isProtected && !password;
    const mismatch = isProtected && !missing && confirmation !== password;
    setErrors({
      password: missing ? t({ id: "filePasswordRequired" }) : undefined,
      confirmation: mismatch ? t({ id: "filePasswordMismatch" }) : undefined,
    });
    setError(undefined);
    if (missing || mismatch) return;
    setBusy(true);
    try {
      const content = await callCore("exportVault", {
        vault: from.pubkey,
        password: isProtected ? password : undefined,
      });
      saveFile(exportFileName(new Date(), isProtected), content);
      onClose();
    } catch {
      setError(t({ id: "exportFailed" }));
      setBusy(false);
    }
  }

  const secret = { secret: true, shown, onShownChange: setShown };
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable={!busy}
      isKeyboardDismissDisabled={busy}
      isOpen
      onOpenChange={(isOpen) => isOpen || onClose()}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <Form onSubmit={(event) => void submit(event, vault)} validationBehavior="aria">
            <Heading slot="title" className="dialog-title">
              {t({ id: "exportVault" })}
            </Heading>
            <div className="dialog-fields">
              {vaults.length > 1 && (
                <SelectField
                  label={t({ id: "vault" })}
                  value={vault.pubkey}
                  options={vaults.map(({ pubkey, name }) => ({ id: pubkey, label: name }))}
                  onChange={(pubkey) =>
                    setVault(vaults.find((each) => each.pubkey === pubkey) ?? vault)
                  }
                />
              )}
              {count !== undefined && (
                <p className="import-export-muted">{t({ id: "exportCount" }, { count })}</p>
              )}
              <SwitchTile
                label={t({ id: "exportProtect" })}
                isSelected={isProtected}
                onChange={setProtected}
              />
              {isProtected ? (
                <>
                  <TextField
                    name="password"
                    label={t({ id: "filePassword" })}
                    error={errors.password}
                    value={password}
                    onChange={setPassword}
                    {...secret}
                    autoFocus
                  />
                  <TextField
                    name="confirmation"
                    label={t({ id: "confirmFilePassword" })}
                    description={t({ id: "filePasswordHelper" })}
                    error={errors.confirmation}
                    value={confirmation}
                    onChange={setConfirmation}
                    {...secret}
                  />
                </>
              ) : (
                <p>{t({ id: "exportWarning" })}</p>
              )}
              {error && (
                <p className="import-export-error" role="alert">
                  {error}
                </p>
              )}
            </div>
            <div className="dialog-actions">
              <TextButton slot="close" isDisabled={busy}>
                {t({ id: "cancel" })}
              </TextButton>
              <FilledButton type="submit" isPending={busy} isDisabled={!count}>
                {t({ id: "exportButton" })}
              </FilledButton>
            </div>
          </Form>
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
