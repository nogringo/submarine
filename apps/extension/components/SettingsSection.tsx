import type { ReactNode } from "react";
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

/** A row of a settings card: its title, then `error` in red or else its description, `children` at its end. */
export function SettingsTile({
  title,
  description,
  error,
  children,
}: {
  title: string;
  description?: string;
  error?: string;
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
      </div>
      {children && <div className="settings-tile-end">{children}</div>}
    </div>
  );
}
