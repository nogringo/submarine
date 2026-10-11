import { type FormEvent, useState } from "react";
import { Form, Heading } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, TextButton } from "@/components/Button";
import { ColorPicker } from "@/components/ColorPicker";
import { TextField } from "@/components/TextField";
import { CoreError, callCore, type Vault } from "@/lib/core";
import { defaultVaultColor } from "@/lib/vault-colors";
import "./OpenVault.css";

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

/** Opens a vault from its key, an nsec or an ncryptsec with its password. */
export function OpenVault({
  vaultCount,
  onOpened,
  onCancel,
}: {
  vaultCount: number;
  onOpened: (vault: Vault) => void;
  onCancel: () => void;
}) {
  const { formatMessage: t } = useIntl();
  const [key, setKey] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [color, setColor] = useState(defaultVaultColor(vaultCount));
  const [errors, setErrors] = useState<Errors>({});
  const [busy, setBusy] = useState(false);
  const encrypted = ncryptsec.test(key.trim().toLowerCase());

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
      const args = { key, name, color, ...(encrypted && { password }) };
      onOpened(await callCore("addVault", args));
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
    <main className="open-vault">
      <Heading level={1} className="screen-title">
        {t({ id: "openVaultTitle" })}
      </Heading>
      <Form className="open-vault-form" onSubmit={submit} validationBehavior="aria">
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
        />
        <ColorPicker label={t({ id: "vaultColor" })} value={color} onChange={setColor} />
        {errors.save && <p className="open-vault-error">{errors.save}</p>}
        {busy && encrypted && (
          <p className="open-vault-status" role="status">
            {t({ id: "vaultKeyDecrypting" })}
          </p>
        )}
        <div className="open-vault-actions">
          <TextButton onPress={onCancel}>{t({ id: "cancel" })}</TextButton>
          <FilledButton type="submit" isDisabled={busy}>
            {t({ id: "open" })}
          </FilledButton>
        </div>
      </Form>
    </main>
  );
}
