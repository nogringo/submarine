import lockOpen from "@material-design-icons/svg/round/lock_open.svg";
import { type FormEvent, useState } from "react";
import { Form } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton } from "@/components/Button";
import { Sonar } from "@/components/Sonar";
import { TextField } from "@/components/TextField";
import { CoreError, callCore } from "@/lib/core";
import "./Welcome.css";
import "./LockScreen.css";

/** Shown while the vaults are locked, until the lock password opens them. */
export function LockScreen({ onUnlocked }: { onUnlocked: () => void }) {
  const { formatMessage: t } = useIntl();
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy || !password) return;
    setBusy(true);
    setError(undefined);
    try {
      await callCore("unlock", { password });
      onUnlocked();
    } catch (error) {
      const wrong = error instanceof CoreError && error.code === "wrongLockPassword";
      setError(t({ id: wrong ? "wrongLockPassword" : "storageReadFailed" }));
      setBusy(false);
    }
  }

  return (
    <main className="welcome">
      <Sonar size={180} />
      <h1 className="wordmark">Submarine</h1>
      <p className="tagline">{t({ id: "vaultsLocked" })}</p>
      <Form className="lock-screen-form" onSubmit={submit} validationBehavior="aria">
        <TextField
          name="password"
          label={t({ id: "lockPassword" })}
          error={error}
          value={password}
          onChange={setPassword}
          secret
          autoFocus
        />
        <FilledButton type="submit" icon={lockOpen} isPending={busy}>
          {t({ id: "unlock" })}
        </FilledButton>
      </Form>
    </main>
  );
}
