import close from "@material-design-icons/svg/round/close.svg";
import search from "@material-design-icons/svg/round/search.svg";
import { useEffect, useRef } from "react";
import { SearchField as AriaSearchField, Input } from "react-aria-components";
import { useIntl } from "react-intl";
import { IconButton } from "./Button";
import { Icon } from "./Icon";
import "./SearchField.css";

/** A search box that Ctrl+F, or ⌘F on Apple devices, focuses from anywhere, and Escape clears. */
export function SearchField({
  value,
  onChange,
  autoFocus,
}: {
  value: string;
  onChange: (value: string) => void;
  autoFocus?: boolean;
}) {
  const { formatMessage: t } = useIntl();
  const input = useRef<HTMLInputElement>(null);
  useEffect(() => {
    const apple = /Mac|iPhone|iPad/.test(navigator.platform);
    const focus = (event: KeyboardEvent) => {
      const command = apple ? event.metaKey : event.ctrlKey;
      if (event.key.toLowerCase() !== "f" || !command || event.altKey || event.shiftKey) return;
      // Not under a dialog.
      if (document.querySelector("[role=dialog]")) return;
      event.preventDefault();
      input.current?.select();
    };
    document.addEventListener("keydown", focus);
    return () => document.removeEventListener("keydown", focus);
  }, []);
  return (
    <AriaSearchField
      aria-label={t({ id: "searchItems" })}
      value={value}
      onChange={onChange}
      autoFocus={autoFocus}
      className="search-field"
    >
      <Icon src={search} />
      <Input ref={input} placeholder={t({ id: "searchItems" })} className="search-field-input" />
      <IconButton icon={close} label={t({ id: "clearSearch" })} />
    </AriaSearchField>
  );
}
