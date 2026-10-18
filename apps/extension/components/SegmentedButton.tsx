import { ToggleButton, ToggleButtonGroup } from "react-aria-components";
import "./SegmentedButton.css";

/** One of a few `options`, as the app's SegmentedButton: equal segments in a single outline. */
export function SegmentedButton<T extends string>({
  className,
  label,
  options,
  selected,
  onChange,
}: {
  className?: string;
  label: string;
  options: { id: T; label: string }[];
  selected: T;
  onChange: (id: T) => void;
}) {
  return (
    <ToggleButtonGroup
      aria-label={label}
      selectionMode="single"
      disallowEmptySelection
      selectedKeys={[selected]}
      onSelectionChange={(keys) => {
        const chosen = options.find(({ id }) => keys.has(id));
        if (chosen) onChange(chosen.id);
      }}
      className={`segmented-button ${className ?? ""}`}
    >
      {options.map(({ id, label }) => (
        <ToggleButton key={id} id={id} className="segment">
          {label}
        </ToggleButton>
      ))}
    </ToggleButtonGroup>
  );
}
