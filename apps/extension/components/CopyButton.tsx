import check from "@material-design-icons/svg/round/check.svg";
import contentCopy from "@material-design-icons/svg/round/content_copy.svg";
import { useEffect, useRef, useState } from "react";
import { useIntl } from "react-intl";
import { copyToClipboard } from "@/lib/clipboard";
import { IconButton } from "./Button";
import "./CopyButton.css";

/**
 * Copies the value, read when pressed where it is not at hand, then shows a check for a moment and
 * tells screen readers, rather than a toast.
 */
export function CopyButton({
  value,
  sensitive,
  label,
}: {
  value: string | (() => Promise<string | undefined>);
  /** Whether the value is a secret, which leaves the clipboard after the delay. */
  sensitive: boolean;
  /** Says what the button copies, where the field it sits in does not. */
  label?: string;
}) {
  const { formatMessage: t } = useIntl();
  const [copied, setCopied] = useState(false);
  const reset = useRef<ReturnType<typeof setTimeout>>(undefined);
  useEffect(() => () => clearTimeout(reset.current), []);
  const copy = async () => {
    const text = typeof value === "string" ? value : await value();
    if (text === undefined) return;
    await copyToClipboard(text, { sensitive });
    setCopied(true);
    clearTimeout(reset.current);
    reset.current = setTimeout(() => setCopied(false), 1500);
  };
  return (
    <span className={copied ? "copy-button copied" : "copy-button"}>
      <IconButton
        icon={copied ? check : contentCopy}
        iconSize={copied ? 24 : 20}
        label={copied ? t({ id: "copied" }) : (label ?? t({ id: "copy" }))}
        onPress={copy}
      />
      <span role="status" className="visually-hidden">
        {copied ? t({ id: "copied" }) : ""}
      </span>
    </span>
  );
}
