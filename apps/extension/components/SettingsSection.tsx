import chevronRight from "@material-design-icons/svg/round/chevron_right.svg";
import type { ReactNode, Ref } from "react";
import { Button } from "react-aria-components";
import { Icon } from "./Icon";
import "./SettingsSection.css";

/** A group of settings in a card, under its title and description when it has them. */
export function SettingsSection({
  title,
  description,
  children,
}: {
  title?: string;
  description?: string;
  children: ReactNode;
}) {
  return (
    <section className="settings-section">
      {title && <h2 className="settings-section-title">{title}</h2>}
      {description && <p className="settings-section-description">{description}</p>}
      <div className="field-card settings-card">{children}</div>
    </section>
  );
}

/**
 * A row of a settings card: its title, then `error` in red or else its description, `below` under
 * them, `children` at its end.
 */
export function SettingsTile({
  title,
  description,
  error,
  below,
  children,
}: {
  title: string;
  description?: string;
  error?: string;
  below?: ReactNode;
  children?: ReactNode;
}) {
  return (
    <div className="settings-tile">
      <div className="settings-tile-text">
        <span className="settings-tile-title">{title}</span>
        {error ? (
          <span className="settings-tile-description error" role="alert">
            {error}
          </span>
        ) : (
          description && <span className="settings-tile-description">{description}</span>
        )}
        {below}
      </div>
      {children && <div className="settings-tile-end">{children}</div>}
    </div>
  );
}

/** A row of a settings card that opens a page of its own, as its chevron tells. */
export function SettingsLinkTile({
  className,
  leading,
  title,
  description,
  onPress,
  ref,
}: {
  className?: string;
  leading?: ReactNode;
  title: string;
  description?: string;
  onPress: () => void;
  ref?: Ref<HTMLButtonElement>;
}) {
  return (
    <Button
      ref={ref}
      className={`settings-tile settings-link-tile ${className ?? ""}`}
      onPress={onPress}
    >
      {leading}
      <span className="settings-tile-text">
        <span className="settings-tile-title">{title}</span>
        {description && <span className="settings-tile-description">{description}</span>}
      </span>
      <Icon src={chevronRight} />
    </Button>
  );
}
