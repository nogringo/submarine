import casino from "@material-design-icons/svg/outlined/casino.svg";
import { type FormEvent, useState } from "react";
import { Dialog, Form, Heading, Modal, ModalOverlay } from "react-aria-components";
import { useIntl } from "react-intl";
import { CoreError, callCore } from "@/lib/core";
import { FilledButton, TextButton } from "./Button";
import { Icon } from "./Icon";
import { TextField } from "./TextField";
import "./Dialog.css";

/** As Bitwarden asks of a master password, and the app of its lock password. */
const minLockPasswordLength = 12;

export type LockPasswordChange = "set" | "change" | "remove";

interface Errors {
  current?: string;
  password?: string;
  confirmation?: string;
}

/**
 * Sets, changes or removes the lock password, asking for the current one before changing or
 * removing it, as the app's dialog does. Opened by a DialogTrigger.
 */
export function LockPasswordDialog({ change }: { change: LockPasswordChange }) {
  const [busy, setBusy] = useState(false);
  return (
    <ModalOverlay className="dialog-overlay" isDismissable={!busy}>
      <Modal className="dialog-modal">
        <Dialog className="dialog">
          {({ close }) => (
            <LockPasswordForm change={change} busy={busy} onBusy={setBusy} onDone={close} />
          )}
        </Dialog>
      </Modal>
    </ModalOverlay>
  );
}

/** Mounted while the dialog is open: the passwords typed go once it closes. */
function LockPasswordForm({
  change,
  busy,
  onBusy: setBusy,
  onDone,
}: {
  change: LockPasswordChange;
  busy: boolean;
  onBusy: (busy: boolean) => void;
  onDone: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [current, setCurrent] = useState("");
  const [password, setPassword] = useState("");
  const [confirmation, setConfirmation] = useState("");
  const [shown, setShown] = useState(false);
  const [errors, setErrors] = useState<Errors>({});
  const asksCurrent = change !== "set";
  const asksNew = change !== "remove";

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
    const tooShort = asksNew && password.length < minLockPasswordLength;
    const mismatch = asksNew && !tooShort && confirmation !== password;
    setErrors({
      password: tooShort
        ? t({ id: "passwordMinLength" }, { count: minLockPasswordLength })
        : undefined,
      confirmation: mismatch ? t({ id: "passwordMismatch" }) : undefined,
    });
    if (tooShort || mismatch) return;
    setBusy(true);
    try {
      if (change === "set") await callCore("setLockPassword", { password });
      if (change === "change") await callCore("changeLockPassword", { current, password });
      if (change === "remove") await callCore("removeLockPassword", { current });
      onDone();
    } catch (error) {
      if (!(error instanceof CoreError && error.code === "wrongLockPassword")) throw error;
      setErrors({ current: t({ id: "wrongLockPassword" }) });
    } finally {
      setBusy(false);
    }
  }

  const secret = { secret: true, shown, onShownChange: setShown };
  return (
    <Form onSubmit={(event) => void submit(event)} validationBehavior="aria">
      <Heading slot="title" className="dialog-title">
        {t({ id: titles[change] })}
      </Heading>
      {change === "remove" && (
        <p className="dialog-content">{t({ id: "removeLockPasswordBodyBrowser" })}</p>
      )}
      <div className="dialog-fields">
        {asksCurrent && (
          <TextField
            name="current"
            label={t({ id: "currentLockPassword" })}
            error={errors.current}
            value={current}
            onChange={setCurrent}
            {...secret}
            autoFocus
          />
        )}
        {asksNew && (
          <>
            <TextField
              name="password"
              label={t({ id: asksCurrent ? "newLockPassword" : "lockPassword" })}
              error={errors.password}
              value={password}
              onChange={setPassword}
              {...secret}
              autoFocus={!asksCurrent}
            />
            <TextField
              name="confirmation"
              label={t({ id: "confirmPassword" })}
              description={t({ id: "lockPasswordHelper" }, { count: minLockPasswordLength })}
              error={errors.confirmation}
              value={confirmation}
              onChange={setConfirmation}
              {...secret}
            />
            <TextButton isDisabled={busy} onPress={() => void generate()}>
              <Icon src={casino} size={20} />
              {t({ id: "generatePassphrase" })}
            </TextButton>
          </>
        )}
      </div>
      <div className="dialog-actions">
        <TextButton slot="close" isDisabled={busy}>
          {t({ id: "cancel" })}
        </TextButton>
        <FilledButton type="submit" danger={change === "remove"} isPending={busy}>
          {t({ id: change === "remove" ? "removeLockPassword" : "save" })}
        </FilledButton>
      </div>
    </Form>
  );
}

const titles = {
  set: "setLockPasswordTitle",
  change: "changeLockPasswordTitle",
  remove: "removeLockPasswordTitle",
} as const;
