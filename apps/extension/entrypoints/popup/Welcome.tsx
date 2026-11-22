import add from "@material-design-icons/svg/round/add.svg";
import key from "@material-design-icons/svg/round/key.svg";
import { DialogTrigger } from "react-aria-components";
import { useIntl } from "react-intl";
import { FilledButton, OutlinedButton, TextButton } from "@/components/Button";
import { MessageDialog } from "@/components/Dialog";
import { Icon } from "@/components/Icon";
import { Sonar } from "@/components/Sonar";
import type { AddVaultChoice } from "./AddVault";
import "./Welcome.css";

/** Shown until a vault is created or opened. */
export function Welcome({ onAddVault }: { onAddVault: (choice: AddVaultChoice) => void }) {
  const { formatMessage: t } = useIntl();
  return (
    <main className="welcome">
      <Sonar size={180} />
      <h1 className="wordmark">Submarine</h1>
      <p className="tagline">{t({ id: "welcomeTagline" })}</p>
      <FilledButton icon={add} onPress={() => onAddVault("create")}>
        {t({ id: "createVault" })}
      </FilledButton>
      <OutlinedButton onPress={() => onAddVault("open")}>
        <Icon src={key} size={20} />
        {t({ id: "openVault" })}
      </OutlinedButton>
      <DialogTrigger>
        <TextButton muted>{t({ id: "builtOnNostr" })}</TextButton>
        <MessageDialog title={t({ id: "builtOnNostr" })} close={t({ id: "close" })}>
          {t({ id: "builtOnNostrBody" })}
        </MessageDialog>
      </DialogTrigger>
    </main>
  );
}
