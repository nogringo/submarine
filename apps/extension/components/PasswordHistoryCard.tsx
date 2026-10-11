import expandMore from "@material-design-icons/svg/round/expand_more.svg";
import history from "@material-design-icons/svg/round/history.svg";
import { useState } from "react";
import { Button, Disclosure, DisclosurePanel, Heading } from "react-aria-components";
import { useIntl } from "react-intl";
import type { FieldRow } from "@/lib/item-fields";
import { FieldTile } from "./FieldCard";
import { Icon } from "./Icon";
import "./PasswordHistoryCard.css";

/** The passwords an item used before, folded under their count as in the app. */
export function PasswordHistoryCard({ rows }: { rows: FieldRow[] }) {
  const { formatMessage: t } = useIntl();
  const [expanded, setExpanded] = useState(false);
  return (
    <Disclosure
      className="field-card password-history"
      isExpanded={expanded}
      onExpandedChange={setExpanded}
    >
      <Heading level={2} className="password-history-heading">
        <Button slot="trigger" className="password-history-trigger">
          <Icon src={history} />
          <span className="password-history-title">{t({ id: "passwordHistory" })}</span>{" "}
          <span className="password-history-count">{rows.length}</span>
          <Icon src={expandMore} />
        </Button>
      </Heading>
      <DisclosurePanel>
        {/* Left out once folded, as in the app: a password shown is hidden again. */}
        {expanded &&
          rows.map((row, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: entries have no id of their own.
            <FieldTile key={index} row={row} />
          ))}
      </DisclosurePanel>
    </Disclosure>
  );
}
