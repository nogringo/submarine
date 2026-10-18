import visibility from "@material-design-icons/svg/outlined/visibility.svg";
import visibilityOff from "@material-design-icons/svg/outlined/visibility_off.svg";
import { useState } from "react";
import { useIntl } from "react-intl";
import { callCore } from "@/lib/core";
import { IconButton } from "./Button";
import { CopyButton } from "./CopyButton";
import "./VaultKeyBox.css";

/**
 * The key of `vault`, as an nsec, hidden until asked and copyable either way, as in the app. The
 * popup reads it from the core only then.
 */
export function VaultKeyBox({ vault }: { vault: string }) {
  const { formatMessage: t } = useIntl();
  const [nsec, setNsec] = useState<string>();
  const read = () => callCore("vaultKey", { vault });
  return (
    <div className="key-box">
      {nsec ? (
        <span className="key-box-value">{nsec}</span>
      ) : (
        // In the font of the key it hides, so that showing it moves nothing.
        <span className="key-box-value" role="img" aria-label={t({ id: "hiddenValue" })}>
          ••••••••••••
        </span>
      )}
      <IconButton
        icon={nsec ? visibilityOff : visibility}
        label={t({ id: nsec ? "hide" : "show" })}
        onPress={async () => setNsec(nsec ? undefined : await read())}
      />
      <CopyButton value={nsec ?? read} sensitive />
    </div>
  );
}
