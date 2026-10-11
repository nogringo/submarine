import { DialogTrigger } from "react-aria-components";
import { useIntl } from "react-intl";
import { TextButton } from "@/components/Button";
import { MessageDialog } from "@/components/Dialog";
import { Sonar } from "@/components/Sonar";
import "./Welcome.css";

/** Shown until a vault is opened. */
export function Welcome() {
  const { formatMessage: t } = useIntl();
  return (
    <main className="welcome">
      <Sonar size={220} />
      <h1 className="wordmark">Submarine</h1>
      <p className="tagline">{t({ id: "welcomeTagline" })}</p>
      <DialogTrigger>
        <TextButton muted>{t({ id: "builtOnNostr" })}</TextButton>
        <MessageDialog title={t({ id: "builtOnNostr" })} close={t({ id: "close" })}>
          {t({ id: "builtOnNostrBody" })}
        </MessageDialog>
      </DialogTrigger>
    </main>
  );
}
