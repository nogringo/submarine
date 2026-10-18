import add from "@material-design-icons/svg/round/add.svg";
import key from "@material-design-icons/svg/round/key.svg";
import { type FormEvent, useState } from "react";
import { Button, Dialog, Form, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, TextButton } from "@/components/Button";
import { ColorPicker } from "@/components/ColorPicker";
import { EncryptVaultKeyDialog } from "@/components/EncryptVaultKeyDialog";
import { Icon } from "@/components/Icon";
import { TextField } from "@/components/TextField";
import { CoreError, callCore, type Vault } from "@/lib/core";
import { defaultVaultColor } from "@/lib/vault-colors";
import "@/components/Dialog.css";
import "./AddVault.css";

export type AddVaultChoice = "create" | "open";

/**
 * A whole ncryptsec (NIP-49), its 91 bytes in bech32: the password field shows once the key is
 * complete, and takes the focus without cutting the key short.
 */
const ncryptsec = /^ncryptsec1[02-9ac-hj-np-z]{152}$/;

interface Errors {
  key?: string;
  password?: string;
  name?: string;
  save?: string;
}

/** Asks whether to create a vault or to open one, as the app does. */
export function AddVaultDialog({
  isOpen,
  onOpenChange,
  onChoose,
}: {
  isOpen: boolean;
  onOpenChange: (isOpen: boolean) => void;
  onChoose: (choice: AddVaultChoice) => void;
}) {
  const { formatMessage: t } = useIntl();
  const choices = [
    { choice: "create", icon: add, title: "createVault", description: "createVaultDescription" },
    { choice: "open", icon: key, title: "openVault", description: "openVaultDescription" },
  ] as const;
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable
      isOpen={isOpen}
      onOpenChange={onOpenChange}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog add-vault-choices">
          <Heading slot="title" className="dialog-title">
            {t({ id: "addVault" })}
          </Heading>
          {choices.map(({ choice, icon, title, description }) => (
            <Button key={choice} className="add-vault-choice" onPress={() => onChoose(choice)}>
              <Icon src={icon} />
              <span className="add-vault-choice-text">
                <span className="add-vault-choice-title">{t({ id: title })}</span>
                <span className="add-vault-choice-description">{t({ id: description })}</span>
              </span>
            </Button>
          ))}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/**
 * Creates a vault, then asks to save its key, or opens one from its key, an nsec or an ncryptsec
 * with its password.
 */
export function AddVault({
  choice,
  vaultCount,
  onAdded,
  onCancel,
}: {
  choice: AddVaultChoice;
  vaultCount: number;
  onAdded: (vault: Vault) => void;
  onCancel: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const opening = choice === "open";
  const [key, setKey] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [color, setColor] = useState(defaultVaultColor(vaultCount));
  const [errors, setErrors] = useState<Errors>({});
  const [busy, setBusy] = useState(false);
  const [created, setCreated] = useState<Vault>();
  const encrypted = opening && ncryptsec.test(key.trim().toLowerCase());

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy) return;
    if (!name.trim()) {
      setErrors({ name: t({ id: "vaultNameRequired" }) });
      return;
    }
    setErrors({});
    setBusy(true);
    try {
      if (opening) {
        const args = { key, name, color, ...(encrypted && { password }) };
        onAdded(await callCore("addVault", args));
      } else {
        setCreated(await callCore("createVault", { name, color }));
      }
    } catch (error) {
      setErrors(errorsOf(error));
      setBusy(false);
    }
  }

  function errorsOf(error: unknown): Errors {
    if (!(error instanceof CoreError)) return { save: t({ id: "vaultSaveFailed" }) };
    switch (error.code) {
      case "vaultKeyInvalid":
        return { key: t({ id: "vaultKeyInvalid" }) };
      case "vaultAlreadyOpen":
        return { key: t({ id: "vaultAlreadyOpen" }, { name: error.message }) };
      case "vaultKeyPasswordWrong":
        return { password: t({ id: "vaultKeyPasswordWrong" }) };
      case "vaultNameRequired":
        return { name: t({ id: "vaultNameRequired" }) };
      default:
        return { save: t({ id: "vaultSaveFailed" }) };
    }
  }

  return (
    <main className="add-vault">
      <Heading level={1} className="screen-title">
        {t({ id: opening ? "openVaultTitle" : "createVault" })}
      </Heading>
      <Form className="add-vault-form" onSubmit={submit} validationBehavior="aria">
        {opening && (
          <TextField
            name="key"
            label={t({ id: "vaultKey" })}
            description={t({ id: "vaultKeyHelper" })}
            placeholder="ncryptsec1..."
            error={errors.key}
            value={key}
            onChange={setKey}
            secret
            mono
            autoFocus
          />
        )}
        {encrypted && (
          <TextField
            name="password"
            label={t({ id: "vaultKeyPassword" })}
            error={errors.password}
            value={password}
            onChange={setPassword}
            secret
            autoFocus
          />
        )}
        <TextField
          name="name"
          label={t({ id: "vaultName" })}
          description={t({ id: "vaultNameHelper" })}
          error={errors.name}
          value={name}
          onChange={setName}
          autoFocus={!opening}
        />
        <ColorPicker label={t({ id: "vaultColor" })} value={color} onChange={setColor} />
        {errors.save && <p className="add-vault-error">{errors.save}</p>}
        {busy && encrypted && (
          <p className="add-vault-status" role="status">
            {t({ id: "vaultKeyDecrypting" })}
          </p>
        )}
        <div className="add-vault-actions">
          <TextButton onPress={onCancel}>{t({ id: "cancel" })}</TextButton>
          <FilledButton type="submit" isDisabled={busy}>
            {t({ id: opening ? "open" : "create" })}
          </FilledButton>
        </div>
      </Form>
      {created && (
        <EncryptVaultKeyDialog
          vault={created.pubkey}
          title={t({ id: "saveVaultKeyTitle" })}
          dismissLabel={t({ id: "later" })}
          isOpen
          onOpenChange={(isOpen) => {
            if (!isOpen) onAdded(created);
          }}
        />
      )}
    </main>
  );
}
