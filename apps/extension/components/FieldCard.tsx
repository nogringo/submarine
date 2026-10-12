import visibility from "@material-design-icons/svg/outlined/visibility.svg";
import visibilityOff from "@material-design-icons/svg/outlined/visibility_off.svg";
import openInNew from "@material-design-icons/svg/round/open_in_new.svg";
import { Fragment, useState } from "react";
import { useIntl } from "react-intl";
import { type FieldRow, websiteUrl } from "@/lib/item-fields";
import { IconButton, IconLink } from "./Button";
import { CopyButton } from "./CopyButton";
import { TotpTile } from "./TotpTile";
import "./FieldCard.css";

/** Rows sharing one rounded card, as the fields of an item do. */
export function FieldCard({ rows }: { rows: FieldRow[] }) {
  return (
    <div className="field-card">
      {rows.map((row, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: rows have no id of their own.
        <FieldTile key={index} row={row} />
      ))}
    </div>
  );
}

export function FieldTile({ row }: { row: FieldRow }) {
  if (row.kind === "totp") return <TotpTile label={row.label} totpKey={row.value} />;
  return <ValueTile row={row} />;
}

function ValueTile({ row }: { row: FieldRow }) {
  const { formatMessage: t } = useIntl();
  const [shown, setShown] = useState(false);
  const hidden = row.kind === "secret" || row.kind === "password";
  const website = row.kind === "url" ? websiteUrl(row.value) : undefined;
  return (
    <div className="field-tile">
      <div className="field-tile-text">
        {row.label && <span className="field-tile-label">{row.label}</span>}
        {hidden && !shown ? (
          // In the font of the value it hides, so that showing it moves nothing.
          <span
            className={`field-value ${row.kind}`}
            role="img"
            aria-label={t({ id: "hiddenValue" })}
          >
            ••••••••••••
          </span>
        ) : row.kind === "password" ? (
          <PasswordText value={row.value} />
        ) : row.kind === "url" ? (
          <UrlText value={row.value} />
        ) : (
          <span className={`field-value ${row.kind}`}>{row.value}</span>
        )}
      </div>
      {hidden && (
        <IconButton
          icon={shown ? visibilityOff : visibility}
          label={t({ id: shown ? "hide" : "show" })}
          onPress={() => setShown(!shown)}
        />
      )}
      {website && <IconLink icon={openInNew} label={t({ id: "openWebsite" })} href={website} />}
      {row.kind !== "info" && <CopyButton value={row.value} sensitive={hidden} />}
    </div>
  );
}

/** Breaks a line after a slash rather than inside a word, where the address allows it. */
function UrlText({ value }: { value: string }) {
  const parts = value.split(/(?<=\/)(?!\/)/);
  return (
    <span className="field-value url">
      {parts.map((part, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: the same part comes back in an address.
        <Fragment key={index}>
          {index > 0 && <wbr />}
          {part}
        </Fragment>
      ))}
    </span>
  );
}

const letter = /\p{L}/u;
const digit = /\p{Nd}/u;

/** Digits in signal, special characters in symbol, so that look-alike characters cannot be mistaken. */
export function PasswordText({ value }: { value: string }) {
  const characters = [...new Intl.Segmenter().segment(value)].map(({ segment }) => segment);
  return (
    <span className="field-value password">
      {characters.map((character, index) => (
        <span
          // biome-ignore lint/suspicious/noArrayIndexKey: the same character comes back in a password.
          key={index}
          className={
            digit.test(character) ? "digit" : letter.test(character) ? undefined : "symbol"
          }
        >
          {character}
        </span>
      ))}
    </span>
  );
}
