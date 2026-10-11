import { Button, type ButtonProps } from "react-aria-components";
import "./Button.css";

export function TextButton({ muted, ...props }: ButtonProps & { muted?: boolean }) {
  return <Button {...props} className={muted ? "button text muted" : "button text"} />;
}
