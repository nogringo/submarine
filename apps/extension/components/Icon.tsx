import "./Icon.css";

/**
 * A Material icon, as in the app, painted in the color of the text. The control around it says
 * what it does, so the icon stays out of the accessibility tree.
 */
export function Icon({ src, size = 24 }: { src: string; size?: number }) {
  return (
    <span
      className="icon"
      style={{ width: size, height: size, maskImage: `url("${src}")` }}
      aria-hidden="true"
    />
  );
}
