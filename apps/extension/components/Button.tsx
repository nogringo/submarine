import { Button, type ButtonProps } from "react-aria-components";
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
}: Omit<ButtonProps, "children"> & { icon: string; label: string }) {
  return (
    <Button {...props} className="button icon-button" aria-label={label}>
      <Icon src={icon} />
    </Button>
  );
}
