import casino from "@material-design-icons/svg/outlined/casino.svg";
import { type FormEvent, useState } from "react";
import { Dialog, Form, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { FilledButton, TextButton } from "./Button";
import { Icon } from "./Icon";
import { TextField } from "./TextField";
import "./Dialog.css";

/** As Bitwarden asks of a master password, and the app of its lock password. */
const minLockPasswordLength = 12;

/** Sets the lock password, as the app's dialog does, opened by a DialogTrigger. */
export function SetLockPasswordDialog() {
  const { formatMessage: t } = useIntl();
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [shown, setShown] = useState(false);
  const [errors, setErrors] = useState<{ password?: string; confirmation?: string }>({});
  const [busy, setBusy] = useState(false);

  async function generate() {
    const passphrase = await callCore("generatePassphrase", {});
    setPassword(passphrase);
    setConfirmation(passphrase);
    setShown(true);
    setErrors({});
  }

  async function submit(event: FormEvent, close: () => void) {
    event.preventDefault();
    if (busy) return;
    const tooShort = password.length < minLockPasswordLength;
    const mismatch = !tooShort && confirmation !== password;
    setErrors({
      password: tooShort
        ? t({ id: "passwordMinLength" }, { count: minLockPasswordLength })
        : undefined,
      confirmation: mismatch ? t({ id: "passwordMismatch" }) : undefined,
    });
    if (tooShort || mismatch) return;
    setBusy(true);
    try {
      await callCore("setLockPassword", { password });
      close();
    } finally {
      setBusy(false);
    }
  }

  return (
    <ModalOverlay className="dialog-overlay" isDismissable={!busy}>
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          {({ close }) => (
            <Form onSubmit={(event) => void submit(event, close)} validationBehavior="aria">
              <Heading slot="title" className="dialog-title">
                {t({ id: "setLockPasswordTitle" })}
              </Heading>
              <div className="dialog-fields">
                <TextField
                  name="password"
                  label={t({ id: "lockPassword" })}
                  error={errors.password}
                  value={password}
                  onChange={setPassword}
                  secret
                  shown={shown}
                  onShownChange={setShown}
                  autoFocus
                />
                <TextField
                  name="confirmation"
                  label={t({ id: "confirmPassword" })}
                  description={t({ id: "lockPasswordHelper" }, { count: minLockPasswordLength })}
                  error={errors.confirmation}
                  value={confirmation}
                  onChange={setConfirmation}
                  secret
                  shown={shown}
                  onShownChange={setShown}
                />
                <TextButton isDisabled={busy} onPress={() => void generate()}>
                  <Icon src={casino} size={20} />
                  {t({ id: "generatePassphrase" })}
                </TextButton>
              </div>
              <div className="dialog-actions">
                <TextButton slot="close" isDisabled={busy}>
                  {t({ id: "cancel" })}
                </TextButton>
                <FilledButton type="submit" isPending={busy}>
                  {t({ id: "save" })}
                </FilledButton>
              </div>
            </Form>
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}
