import type { Ref } from "react";
import { Button, type ButtonProps, Link } from "react-aria-components";
import "./Button.css";
import { Icon } from "./Icon";

export function TextButton({ muted, ...props }: ButtonProps & { muted?: boolean }) {
  return <Button {...props} className={muted ? "button text muted" : "button text"} />;
}

/** The main action of a screen. */
export function FilledButton({
  icon,
  children,
  ...props
}: Omit<ButtonProps, "children"> & { icon?: string; children: string }) {
  return (
    <Button {...props} className="button filled">
      {icon && <Icon src={icon} size={20} />}
      {children}
    </Button>
  );
}

/** A button showing an icon alone, named by its label. */
export function IconButton({
  icon,
  label,
  ...props
}: Omit<ButtonProps, "children"> & { icon: string; label: string; ref?: Ref<HTMLButtonElement> }) {
  return (
    <Button {...props} className="button icon-button" aria-label={label}>
      <Icon src={icon} />
    </Button>
  );
}

/** A link showing an icon alone, named by its label, opened in a new tab. */
export function IconLink({ icon, label, href }: { icon: string; label: string; href: string }) {
  return (
    <Link
      href={href}
      target="_blank"
      rel="noreferrer"
      className="button icon-button"
      aria-label={label}
    >
      <Icon src={icon} size={20} />
    </Link>
  );
}
