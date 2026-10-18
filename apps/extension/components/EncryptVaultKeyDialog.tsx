import casino from "@material-design-icons/svg/outlined/casino.svg";
import { type FormEvent, useState } from "react";
import { Dialog, Form, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { FilledButton, TextButton } from "./Button";
import { CopyButton } from "./CopyButton";
import { Icon } from "./Icon";
import { TextField } from "./TextField";
import "./Dialog.css";
import "./VaultKeyBox.css";

/** As the app asks of it: whoever holds the ncryptsec can guess at the password offline. */
const minVaultKeyPasswordLength = 12;

interface Errors {
  password?: string;
  confirmation?: string;
}

/**
 * Encrypts the key of `vault` with a password the user picks, then shows the ncryptsec, which can be
 * kept anywhere since only that password opens it, as the app's dialog does. Opened by a
 * DialogTrigger, or by `isOpen` once a vault is created: then only its buttons close it, the
 * dismiss one named `dismissLabel`.
 */
export function EncryptVaultKeyDialog({
  vault,
  title,
  dismissLabel,
  isOpen,
  onOpenChange,
}: {
  vault: string;
  title?: string;
  dismissLabel?: string;
  isOpen?: boolean;
  onOpenChange?: (isOpen: boolean) => void;
}) {
  const [busy, setBusy] = useState(false);
  const dismissable = !busy && isOpen === undefined;
  return (
    <ModalOverlay
      className="dialog-overlay"
      isDismissable={dismissable}
      isKeyboardDismissDisabled={!dismissable}
      isOpen={isOpen}
      onOpenChange={onOpenChange}
    >
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          <EncryptVaultKeyForm
            vault={vault}
            title={title}
            dismissLabel={dismissLabel}
            busy={busy}
            onBusy={setBusy}
          />
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/** Mounted while the dialog is open: the password and the ncryptsec go once it closes. */
function EncryptVaultKeyForm({
  vault,
  title: titleText,
  dismissLabel,
  busy,
  onBusy: setBusy,
}: {
  vault: string;
  title?: string;
  dismissLabel?: string;
  busy: boolean;
  onBusy: (busy: boolean) => void;
}) {
  const { formatMessage: t } = useIntl();
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [shown, setShown] = useState(false);
  const [errors, setErrors] = useState<Errors>({});
  const [ncryptsec, setNcryptsec] = useState<string>();

  async function generate() {
    const passphrase = await callCore("generatePassphrase", {});
    setPassword(passphrase);
    setConfirmation(passphrase);
    setShown(true);
    setErrors({});
  }

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy) return;
    const tooShort = password.length < minVaultKeyPasswordLength;
    const mismatch = !tooShort && confirmation !== password;
    setErrors({
      password: tooShort
        ? t({ id: "passwordMinLength" }, { count: minVaultKeyPasswordLength })
        : undefined,
      confirmation: mismatch ? t({ id: "passwordMismatch" }) : undefined,
    });
    if (tooShort || mismatch) return;
    setBusy(true);
    try {
      setNcryptsec(await callCore("encryptVaultKey", { vault, password }));
    } finally {
      setBusy(false);
    }
  }

  const title = (
    <Heading slot="title" className="dialog-title">
      {titleText ?? t({ id: "exportEncryptedVaultKey" })}
    </Heading>
  );
  if (ncryptsec) {
    return (
      <>
        {title}
        <p className="dialog-content">{t({ id: "encryptedVaultKeyBody" })}</p>
        <div className="key-box">
          <span className="key-box-value">{ncryptsec}</span>
          {/* Meant to be pasted anywhere, so not dropped from the clipboard. */}
          <CopyButton value={ncryptsec} sensitive={false} />
        </div>
        <div className="dialog-actions">
          <FilledButton slot="close" autoFocus>
            {t({ id: "done" })}
          </FilledButton>
        </div>
      </>
    );
  }
  const secret = { secret: true, shown, onShownChange: setShown };
  return (
    <Form onSubmit={(event) => void submit(event)} validationBehavior="aria">
      {title}
      <p className="dialog-content">{t({ id: "encryptVaultKeyBody" })}</p>
      <div className="dialog-fields">
        <TextField
          name="password"
          label={t({ id: "vaultKeyPassword" })}
          error={errors.password}
          value={password}
          onChange={setPassword}
          {...secret}
          autoFocus
        />
        <TextField
          name="confirmation"
          label={t({ id: "confirmPassword" })}
          description={t({ id: "passwordMinLength" }, { count: minVaultKeyPasswordLength })}
          error={errors.confirmation}
          value={confirmation}
          onChange={setConfirmation}
          {...secret}
        />
        <TextButton isDisabled={busy} onPress={() => void generate()}>
          <Icon src={casino} size={20} />
          {t({ id: "generatePassphrase" })}
        </TextButton>
      </div>
      <div className="dialog-actions">
        <TextButton slot="close" isDisabled={busy}>
          {dismissLabel ?? t({ id: "cancel" })}
        </TextButton>
        <FilledButton type="submit" isPending={busy}>
          {t({ id: "encryptKey" })}
        </FilledButton>
      </div>
    </Form>
  );
}
