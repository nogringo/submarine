import type { ReactNode } from "react";
import "./SettingsSection.css";

/** A titled group of settings, `children` in a card under its title and description. */
export function SettingsSection({
  title,
  description,
  children,
}: {
  title: string;
  description?: string;
  children: ReactNode;
}) {
  return (
    <section className="settings-section">
      <h2 className="settings-section-title">{title}</h2>
      {description && <p className="settings-section-description">{description}</p>}
      <div className="field-card settings-card">{children}</div>
    </section>
  );
}
